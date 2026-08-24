#!/bin/sh

BASEDIR=$(
  cd "$(dirname "$0")"
  pwd
)

echo --------------------------------------------------------
echo ---- install i3 and config in $BASEDIR...... ----
echo --------------------------------------------------------

# 1) 依赖包（i3lock-color 提供锁屏着色参数；dex XDG 自启动；tdrop 下拉终端；
#    fcitx5 输入法；albert/copyq/flameshot/dmenu 快捷启动/剪贴板/截图；
#    pipewire-pulse+pavucontrol 音频栈；python-requests 天气脚本依赖）
sh $BASEDIR/../tool.sh i3-wm i3lock-color xss-lock dex dmenu \
  fcitx5 picom dunst polybar variety \
  pipewire-pulse pavucontrol python-requests

# 2) 音频：pipewire-pulse 作为 pulseaudio 兼容层（pactl/pavucontrol 依赖）
systemctl --user enable --now pipewire-pulse.socket pipewire-pulse.service 2>&1

# 3) 部署 polybar 图标字体（Feather + Material Icons 全系），缺失会显示豆腐块
mkdir -p ~/.local/share/fonts/polybar-icons
cp "$BASEDIR"/polybar/fonts/feather/* "$BASEDIR"/polybar/fonts/material-icons/* \
  ~/.local/share/fonts/polybar-icons/
fc-cache -f ~/.local/share/fonts >/dev/null 2>&1

# 4) 备份式软链：已指向正确目标则跳过（幂等），旧配置先备份为 *.bak.<时间戳>
link_config() {
  target=$1
  link_path=$2
  if [ -L "$link_path" ] && [ "$(readlink "$link_path")" = "$target" ]; then
    echo "skip  : $link_path 已指向 $target"
    return 0
  fi
  if [ -e "$link_path" ] || [ -L "$link_path" ]; then
    backup="$link_path.bak.$(date +%Y%m%d%H%M%S)"
    mv "$link_path" "$backup"
    echo "backup: $link_path -> $backup"
  fi
  ln -s "$target" "$link_path"
  echo "link  : $link_path -> $target"
}

link_config "$BASEDIR" ~/.config/i3
link_config "$BASEDIR/polybar" ~/.config/polybar
mkdir -p ~/.config/variety
link_config "$BASEDIR/wallpaper" ~/.config/variety/Favorites

# 5) 脚本执行位兜底（压缩包/其他方式分发时 x 位可能丢失）
chmod +x "$BASEDIR/polybar/launch.sh"
chmod +x "$BASEDIR"/polybar/scripts/weather/*.sh
chmod +x "$BASEDIR"/script/*.sh

# 6) 说明：dunst/picom 配置在 ~/.config/i3/ 内由 i3 config 直接引用，无需软链

echo "Wall Paper Url: https://wallhaven.cc/search?categories=101&purity=100&topRange=1M&sorting=toplist&order=desc"
