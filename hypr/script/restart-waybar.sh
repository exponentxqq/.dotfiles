#!/bin/bash
# 重启 waybar (对应 i3 的 $mod+b 重启状态栏)
# 等待旧进程完全退出再启动, 避免 layer surface 并存出现两条状态栏
pkill -x waybar 2>/dev/null
for _ in $(seq 30); do
    pgrep -x waybar >/dev/null || break
    sleep 0.1
done
pkill -KILL -x waybar 2>/dev/null      # 兜底强杀仍未退出的进程
sleep 0.2
exec waybar
