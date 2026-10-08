#!/bin/bash
# waybar 输入法状态模块 (fcitx5): 流式输出 JSON, 每 0.3s 刷新
# 状态: 2=中文激活 -> 中; 1/0=英文 -> EN
# 点击状态栏切换中英文 (见 waybar config 的 on-click: fcitx5-remote -t)
# 图标用 \\uXXXX 转义输出, 避免私有区字符丢失

emit_status() {
    local state im
    state=$(fcitx5-remote 2>/dev/null)
    im=$(fcitx5-remote -n 2>/dev/null)
    [ -z "$im" ] && im="unknown"

    if [ "$state" = "2" ]; then
        printf '{"text":"\\uf1ab 中","class":"zh","alt":"%s","tooltip":"输入法: %s (中文)\\n点击或 Ctrl+Space 切换"}\n' "$im" "$im"
    else
        printf '{"text":"\\uf11c EN","class":"en","alt":"%s","tooltip":"输入法: %s (英文)\\n点击或 Ctrl+Space 切换"}\n' "$im" "$im"
    fi
}

while true; do
    emit_status
    sleep 0.3
done
