#!/bin/bash
# waybar 蓝牙图标点击: fuzzel 菜单管理蓝牙 (BlueZ / bluetoothctl)
# 依赖: bluetoothctl (bluez-utils), fuzzel, notify-send (mako); blueman 为复杂配对兜底
# 菜单: [扫描] [blueman] [开关] 特殊项 + 设备列表 (已连接/已配对/新发现)
# 操作: 已连接=断开, 已配对=连接, 新设备=配对+信任+连接
# 调试: bt-menu.sh --list  只打印菜单不调 fuzzel (无需图形环境)

set -u
SCAN_SECS=10
TMP=$(mktemp /tmp/bt-menu.XXXXXX)     # 行号 -> "动作\tMAC\t名称"
trap 'rm -f "$TMP"' EXIT

notify() { notify-send -a "bt-menu" "$@"; }
trim()   { local s="${1:-}"; s="${s#"${s%%[![:space:]]*}"}"; s="${s%"${s##*[![:space:]]}"}"; printf '%s' "$s"; }
powered() { bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; }
is_connected() { bluetoothctl info "$1" 2>/dev/null | grep -q "Connected: yes"; }

# 菜单行统一编号写 TMP 映射, 主循环按编号取动作 (避免设备名前缀撞文字匹配)
gen=0
emit() {  # emit 图标字符 显示文本 动作 MAC 名称
    gen=$((gen + 1))
    printf '%s\t%s\t%s\n' "$3" "$4" "$5" >> "$TMP"
    printf '%d\t%s %s\n' "$gen" "$1" "$2"
}

build_list() {
    : > "$TMP"; gen=0
    if powered; then
        emit $'\uf002' "扫描新设备 ($SCAN_SECS 秒)" scan - -
        emit $'\uf013' "打开 blueman 管理器" blueman - -
        emit $'\uf011' "关闭蓝牙" power-off - -
    else
        emit $'\uf011' "开启蓝牙" power-on - -
    fi

    local -A is_conn=() is_pair=()
    local m
    while read -r m; do [ -n "$m" ] && is_conn[$m]=1; done < <(bluetoothctl devices Connected 2>/dev/null | awk '{print $2}')
    while read -r m; do [ -n "$m" ] && is_pair[$m]=1; done < <(bluetoothctl devices Paired 2>/dev/null | awk '{print $2}')

    local line mac name
    while IFS= read -r line; do
        case "$line" in ("Device "*) ;; (*) continue ;; esac
        mac="${line#Device }"; mac="${mac%% *}"
        name=$(trim "${line#"Device $mac"}")     # 去 "Device MAC" 前缀, 余下即名称(可能空)
        [ -n "$name" ] || name="$mac"
        if [ -n "${is_conn[$mac]:-}" ]; then
            emit $'\uf00c' "$name · 已连接" disconnect "$mac" "$name"
        elif [ -n "${is_pair[$mac]:-}" ]; then
            emit $'\uf10c' "$name · 已配对" connect "$mac" "$name"
        else
            emit $'\uf067' "$name · 新设备" pair "$mac" "$name"
        fi
    done < <(bluetoothctl devices 2>/dev/null)
}

do_scan() {
    notify $'\uf002 扫描中' "约 ${SCAN_SECS} 秒, 完成后重新打开菜单查看"
    timeout $((SCAN_SECS + 5)) bluetoothctl --timeout "$SCAN_SECS" scan on >/dev/null 2>&1
}

do_connect() {
    local mac="$1" name="$2"
    if timeout 25 bluetoothctl connect "$mac" >/dev/null 2>&1 && is_connected "$mac"; then
        notify $'\uf00c 已连接' "$name"
        return 0
    fi
    notify $'\uf00d 连接失败' "$name · 可尝试 blueman 管理器"
    return 1
}

do_pair() {
    local mac="$1" name="$2"
    notify $'\uf067 配对中' "$name"
    if timeout 30 bluetoothctl pair "$mac" >/dev/null 2>&1 \
       && bluetoothctl info "$mac" 2>/dev/null | grep -q "Paired: yes"; then
        bluetoothctl trust "$mac" >/dev/null 2>&1     # 信任: 免下次连接时的确认
        do_connect "$mac" "$name"
    else
        notify $'\uf00d 配对失败' "$name · 请用 blueman 管理器"
        return 1
    fi
}

do_disconnect() {
    bluetoothctl disconnect "$1" >/dev/null 2>&1
    notify $'\uf127 已断开' "$2"
}

main() {
    local choice nr action mac name
    while :; do
        choice=$(build_list | fuzzel --dmenu --prompt "蓝牙: ") || exit 0
        [ -z "$choice" ] && exit 0
        nr="${choice%%$'\t'*}"
        case "$nr" in (''|*[!0-9]*) exit 0 ;; esac     # 容错: 非编号行不处理
        IFS=$'\t' read -r action mac name < <(sed -n "${nr}p" "$TMP")
        case "${action:-}" in
            scan)      do_scan; continue ;;
            blueman)   setsid -f blueman-manager >/dev/null 2>&1; exit 0 ;;
            power-off) bluetoothctl power off >/dev/null 2>&1
                       notify $'\uf011 已关闭' "蓝牙已关闭, 设备已断开"
                       continue ;;
            power-on)  bluetoothctl power on >/dev/null 2>&1
                       if powered; then notify $'\uf011 已开启' "蓝牙已开启"
                       else notify $'\uf00d 开启失败' "无可用蓝牙控制器 (bluetooth.service?)"; fi
                       continue ;;
            disconnect) do_disconnect "$mac" "$name"; exit 0 ;;
            connect)    do_connect "$mac" "$name" && exit 0 ;;
            pair)       do_pair "$mac" "$name" && exit 0 ;;
            *) exit 0 ;;
        esac
    done
}

if [ "${1:-}" = "--list" ]; then build_list; exit 0; fi
main
