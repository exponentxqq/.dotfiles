#!/bin/bash
# waybar 电池图标点击: fuzzel 菜单展示各软件耗电估算
# 原理: 间隔 SAMPLE_SECS 采样两次 /proc/<pid>/stat 的 CPU 时间 (进程组聚合),
#       按可执行文件归并到"软件", 再按 CPU 份额把整机功率分摊给各软件。
# 总功率: 放电时读电池 current_now*voltage_now (实测); 插电/充电时电池读数无意义,
#         用固定模型估算 (IDLE_W 空载 + CPU_FULL_W * busy 比例), 菜单中标注来源。
# 限制: 非 root 只能归因 CPU; GPU/外设功耗无法按进程归因 (独显仅显示全局电源状态);
#       结果用于量级参考, 与 powertop 的 PW Estimate 同思路但更简化。
# 依赖: fuzzel (菜单), notify-send/mako (无 fuzzel 时兜底), 无其他依赖。
# 调试: power-menu.sh --list  只打印菜单不调 fuzzel (无需图形环境)

set -u

SAMPLE_SECS=0.8     # 采样窗口(秒); 调大更稳但点击后等待更久
TOP_N=10            # 单独展示的软件数, 其余合并为"其他软件"
IDLE_W=10           # 插电估算: 整机空载功率(W)
CPU_FULL_W=30       # 插电估算: CPU 满载在空载之上的功率(W)
BAR_WIDTH=10        # 耗电条字符数

CLK_TCK=$(getconf CLK_TCK)
NCPU=$(nproc)

# 常见软件名美化 (可自行扩充): 可执行文件名 -> 显示名
declare -A NAME_MAP=(
    [code]="VS Code"        [code-oss]="VS Code"    [codium]="VS Code"
    [google-chrome]="Chrome"
    [firefox]="Firefox"
    [Hyprland]="Hyprland"
    [Xwayland]="Xwayland"
)

# 采样一次全部进程的 CPU 时间(ticks): 输出 "pid ticks", ticks 为 utime+stime
# /proc/<pid>/stat 是整组聚合值(含已退出线程), 不会与线程重复计数
read_ticks() {
    local stat line pid rest
    local -a f
    for stat in /proc/[0-9]*/stat; do
        { IFS= read -r line < "$stat"; } 2>/dev/null || continue   # 进程可能瞬间消失
        pid=${line%% *}
        rest=${line##*) }          # 去掉 "pid (comm) " 前缀; comm 可能含空格/paren, 取最后一个 ")"
        read -r -a f <<< "$rest"   # 剩余字段: state=0 ... utime=11, stime=12
        printf '%s %s\n' "$pid" "$(( ${f[11]:-0} + ${f[12]:-0} ))"
    done
}

# 进程 -> 软件名: 优先 exe 文件名(可区分 Firefox 各子进程), 退化到 comm(内核线程/root 进程)
app_name() {
    local pid=$1 exe name
    exe=$(readlink "/proc/$pid/exe" 2>/dev/null) || exe=""
    if [ -n "$exe" ]; then
        exe=${exe% " (deleted)"}
        name=${exe##*/}
    else
        { name=$(< "/proc/$pid/comm"); } 2>/dev/null || name="未知"
        name=${name%%/*}           # kworker/0:1 -> kworker
    fi
    printf '%s' "${NAME_MAP[$name]:-$name}"
}

# 电池实测功率(pW, 1e-12 W): 仅放电时有效; 非放电/无电池输出空并返回 1
battery_pw() {
    local bat status cur vol
    bat=$(ls -d /sys/class/power_supply/BAT* 2>/dev/null | head -n1)
    [ -n "$bat" ] || return 1
    { status=$(< "$bat/status"); } 2>/dev/null || return 1
    [ "$status" = "Discharging" ] || return 1
    { cur=$(< "$bat/current_now"); } 2>/dev/null || return 1
    { vol=$(< "$bat/voltage_now"); } 2>/dev/null || return 1
    [ "$cur" -lt 0 ] && cur=$(( -cur ))    # 电流方向约定不一, 取绝对值
    printf '%s' "$(( cur * vol ))"
}

# 独显(AMD)电源状态: D0=活跃耗电, D3=休眠
gpu_state() {
    local c v s
    for c in /sys/class/drm/card*/device; do
        { v=$(< "$c/vendor"); } 2>/dev/null || continue
        [ "$v" = "0x1002" ] || continue
        { s=$(< "$c/power_state"); } 2>/dev/null || s="?"
        case "$s" in
            D0)  printf '独显 D0(活跃)' ;;
            D3*) printf '独显 %s(休眠)' "$s" ;;
            *)   printf '独显 %s' "$s" ;;
        esac
        return 0
    done
    printf '独显 未知'
}

# 生成菜单文本(每行一个菜单项)
build_menu() {
    local pid prev d name total=0 pw p_w mode busy
    local -A first=() by_name=() cnt=()
    local sorted top rest rest_ticks=0 rest_cnt=0

    while read -r pid d; do first[$pid]=$d; done < <(read_ticks)
    sleep "$SAMPLE_SECS"
    while read -r pid d; do
        prev=${first[$pid]:-}
        [ -n "$prev" ] || continue
        d=$(( d - prev ))
        [ "$d" -gt 0 ] || continue
        total=$(( total + d ))
        name=$(app_name "$pid")
        by_name[$name]=$(( ${by_name[$name]:-0} + d ))
        cnt[$name]=$(( ${cnt[$name]:-0} + 1 ))
    done < <(read_ticks)

    # 总功率: 优先电池实测(pW -> W), 否则按 busy 比例估算
    if pw=$(battery_pw) && [ "$pw" -gt 0 ]; then
        p_w=$(awk -v u="$pw" 'BEGIN{printf "%.2f", u/1e12}')
        mode="电池实测"
    else
        p_w=$(awk -v t="$total" -v s="$SAMPLE_SECS" -v c="$CLK_TCK" -v n="$NCPU" \
                   -v i="$IDLE_W" -v f="$CPU_FULL_W" \
              'BEGIN{r=t/(s*c*n); if(r>1)r=1; printf "%.2f", i+r*f}')
        mode="插电估算"
    fi
    busy=$(awk -v t="$total" -v s="$SAMPLE_SECS" -v c="$CLK_TCK" -v n="$NCPU" \
           'BEGIN{r=100*t/(s*c*n); if(r>100)r=100; printf "%.0f", r}')

    printf '%s\n' "总功率 ${p_w} W (${mode}) · CPU busy ${busy}% · $(gpu_state)"
    if [ "$total" -eq 0 ]; then
        printf '%s\n' "采样窗口内无 CPU 活动"
        return 0
    fi
    printf '%s\n' "按 CPU 份额分摊功率, 仅供参考"

    # 软件行: "ticks \t 名称 \t 进程数", 按 ticks 降序
    sorted=""
    for name in "${!by_name[@]}"; do
        # 直接拼接而非 $(printf ...): 命令替换会去掉行尾换行导致多行粘连
        sorted+="${by_name[$name]}"$'\t'"$name"$'\t'"${cnt[$name]}"$'\n'
    done
    sorted=$(printf '%s' "$sorted" | sort -rn)
    top=$(printf '%s\n' "$sorted" | head -n "$TOP_N")
    rest=$(printf '%s\n' "$sorted" | tail -n "+$((TOP_N + 1))")
    if [ -n "$rest" ]; then
        rest_ticks=$(cut -f1 <<< "$rest" | awk '{s+=$1} END{print s+0}')
        rest_cnt=$(wc -l <<< "$rest")
    fi

    printf '%s\n' "$top" | awk -F'\t' -v P="$p_w" -v T="$total" -v W="$BAR_WIDTH" \
                           -v RT="$rest_ticks" -v RC="$rest_cnt" '
        function bar(n) {
            s = ""
            for (j = 0; j < n; j++) s = s "▇"
            for (j = n; j < W; j++) s = s " "
            return s
        }
        NR == 1 { max = $1 }
        {
            share = $1 / T
            n = int($1 / max * W + 0.5); if (n < 1) n = 1; if (n > W) n = W
            printf "%6.2f W │ %5.1f%% │ %s │ %s (%d 进程)\n", P*share, share*100, bar(n), $2, $3
        }
        END {
            if (RT > 0) {
                share = RT / T
                n = int(RT / max * W + 0.5); if (n < 1) n = 1; if (n > W) n = W
                printf "%6.2f W │ %5.1f%% │ %s │ 其他软件 (%d 项)\n", P*share, share*100, bar(n), RC
            }
        }'
}

menu=$(build_menu)

if [ "${1:-}" = "--list" ]; then
    printf '%s\n' "$menu"
    exit 0
fi

if command -v fuzzel >/dev/null 2>&1; then
    # --width: 菜单最长行(含中文双宽)约 64 字符, 取 72 留余量; 覆盖 fuzzel.ini 的 width=42
    printf '%s\n' "$menu" | fuzzel --dmenu --prompt "各软件耗电: " --lines 13 --minimal-lines \
        --width=72 --line-height=30 >/dev/null 2>&1 || true
else
    notify-send -a "power-menu" "各软件耗电" "$(printf '%s\n' "$menu" | head -n 4)"
fi
