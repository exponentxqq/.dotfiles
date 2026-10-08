#!/bin/bash
# waybar 网络图标点击: fuzzel 菜单选择并连接 WiFi (NetworkManager)
# 依赖: nmcli, fuzzel, notify-send (mako)
# 菜单: 顶部 [刷新] [断开] 特殊项 + 按信号排序的 AP 列表 (同 SSID 去重, 已连接/加密有标记)
# 连接: 已有 profile 直接连; 需要密码时弹 fuzzel 密码输入框; 失败可回菜单重选
# 调试: wifi-menu.sh --list  只打印菜单不调 fuzzel (无需图形环境)

set -u
IFACE=wlp3s0
TMP=$(mktemp /tmp/wifi-menu.XXXXXX)     # 行号 -> SSID 映射表
trap 'rm -f "$TMP"' EXIT

notify() { notify-send -a "wifi-menu" "$@"; }
trim()   { local s="${1:-}"; s="${s#"${s%%[![:space:]]*}"}"; s="${s%"${s##*[![:space:]]}"}"; printf '%s' "$s"; }

# 构建 fuzzel 菜单 + TMP 映射 (编号 = TMP 行号)
# multiline 输出每记录顺序: IN-USE -> SIGNAL -> SECURITY -> SSID (SSID 最后)
build_list() {
    printf '\uf021  刷新列表\n'
    printf '\uf127  断开当前连接\n'
    : > "$TMP"
    nmcli dev wifi rescan ifname "$IFACE" >/dev/null 2>&1     # 异步触发重扫, 本次用缓存
    local sig="" sec="" ssid="" inuse="" n=0 mark lock
    local -A seen=()
    while IFS= read -r line; do
        case "$line" in
            "SIGNAL:"*)   sig=$(trim "${line#SIGNAL:}") ;;
            "SECURITY:"*) sec=$(trim "${line#SECURITY:}") ;;
            "IN-USE:"*)   inuse=$(trim "${line#IN-USE:}") ;;
            "SSID:"*)
                ssid=$(trim "${line#SSID:}")
                if [ -z "$ssid" ] || [ "$ssid" = "--" ] || [ -n "${seen[$ssid]:-}" ]; then
                    continue
                fi
                seen[$ssid]=1
                n=$((n + 1))
                printf '%s\n' "$ssid" >> "$TMP"
                lock=""; [ -n "$sec" ] && [ "$sec" != "--" ] && lock=$' \uf023'
                mark=""; [ -n "$inuse" ] && mark=$' \uf00c'
                printf '%d\t%s%%\t%s%s%s\n' "$n" "$sig" "$ssid" "$lock" "$mark"
                ;;
        esac
    done < <(nmcli -m multiline -f IN-USE,SIGNAL,SECURITY,SSID dev wifi list ifname "$IFACE" 2>/dev/null)
}

connect_wifi() {
    local ssid="$1" pw
    if nmcli --wait 15 dev wifi connect "$ssid" ifname "$IFACE" >/dev/null 2>&1; then
        notify $'\uf00c 已连接' "$ssid"
        return 0
    fi
    # 直连失败 (新网络/缺密码): 弹密码框 (--prompt-only: 不读 stdin 的纯输入框,
    # 避开 fuzzel.ini 的 exit-immediately-if-empty 导致空列表秒退)
    pw=$(fuzzel --dmenu --prompt-only "密码 ($ssid): " --password) \
        || { notify $'\uf127 已取消' "未输入密码"; return 1; }
    [ -z "$pw" ] && return 1
    if nmcli --wait 25 dev wifi connect "$ssid" password "$pw" ifname "$IFACE" >/dev/null 2>&1; then
        notify $'\uf00c 已连接' "$ssid"
        return 0
    fi
    notify $'\uf00d 连接失败' "$ssid: 密码错误或信号不足"
    return 1
}

main() {
    local choice nr ssid
    while :; do
        choice=$(build_list | fuzzel --dmenu --prompt "WiFi: ") || exit 0
        [ -z "$choice" ] && exit 0
        case "$choice" in
            *刷新*) continue ;;
            *断开*) nmcli dev disconnect "$IFACE" >/dev/null 2>&1
                    notify $'\uf127 已断开' "当前 WiFi 连接已断开"
                    exit 0 ;;
        esac
        nr="${choice%%$'\t'*}"
        case "$nr" in (''|*[!0-9]*) exit 0 ;; esac     # 容错: 非编号行不处理
        ssid=$(sed -n "${nr}p" "$TMP")
        [ -n "$ssid" ] || exit 0
        connect_wifi "$ssid" && exit 0                 # 失败则回菜单重选
    done
}

if [ "${1:-}" = "--list" ]; then build_list; exit 0; fi
main
