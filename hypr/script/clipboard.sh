#!/bin/bash
# 剪贴板历史选择 (Super+Shift+V): cliphist + fuzzel, 选中项复制回剪贴板
selection=$(cliphist list | fuzzel --dmenu --prompt " ⌛ " --width 60)
[ -n "$selection" ] && printf '%s' "$selection" | cliphist decode | wl-copy
