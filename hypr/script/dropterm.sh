#!/bin/bash
# 下拉终端 (替代 i3 的 tdrop): 无则创建, 有则切换特殊工作区显隐
# 窗口规则见 hyprland.conf: class^(dropterm)$ -> special:dropterm (silent)
if hyprctl clients -j | grep -q '"class": "dropterm"'; then
  hyprctl dispatch togglespecialworkspace dropterm
else
  kitty --class dropterm &
  sleep 0.4
  hyprctl dispatch togglespecialworkspace dropterm
fi
