#!/bin/bash
# 截图脚本 (grim + slurp), 替代 flameshot
# 用法: screenshot.sh [region|full]
# 结果: 保存到 ~/Pictures/Screenshots/ 并复制到剪贴板
set -e

dir="${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
mkdir -p "$dir"
file="$dir/$(date +%Y%m%d-%H%M%S).png"

case "${1:-region}" in
  region)
    grim -g "$(slurp)" "$file"
    ;;
  full)
    grim "$file"
    ;;
  *)
    echo "用法: $0 [region|full]" >&2
    exit 1
    ;;
esac

wl-copy < "$file"
notify-send -i "$file" "截图已保存" "$file"
