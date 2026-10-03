#!/bin/sh

BASEDIR=$(
  cd "$(dirname "$0")"
  pwd
)

echo --------------------------------------------------------
echo ---- install hyprland and config in $BASEDIR...... ----
echo --------------------------------------------------------

# 1) 依赖包（官方仓库; kitty/mako/fuzzel 等; 字体含 JetBrainsMono Nerd Font）
sh $BASEDIR/../tool.sh \
  hyprland waybar hyprlock hypridle hyprpaper fuzzel \
  grim slurp wl-clipboard cliphist mako kitty libnotify \
  hyprpolkitagent xdg-desktop-portal-hyprland \
  mesa vulkan-radeon intel-media-driver sddm \
  fontconfig noto-fonts ttf-dejavu noto-fonts-cjk ttf-jetbrains-mono-nerd \
  fcitx5 fcitx5-gtk fcitx5-configtool fcitx5-chinese-addons \
  pipewire-pulse pavucontrol brightnessctl tlp rtkit

# AUR 包（tool.sh 内部统一走 yay）
sh $BASEDIR/../tool.sh mbpfan

# 1.1) Touch Bar 说明 (本机为 T1 机型, 2016/2017):
#   T1 固件存放于 ESP 的 EFI/APPLE/EMBEDDEDOS/, 全盘安装 Linux 会将其擦除。
#   擦除后 iBridge 以 05ac:1281 (recovery) 出现, Touch Bar/摄像头/ALS 全部失效,
#   且任何 Linux 驱动都无法工作 (均要求 05ac:8600)。只能由 macOS 重写固件修复。
#   检查: lsusb | grep 05ac   (8600=正常, 1281=固件缺失)
#   若固件正常, 可装 DKMS 驱动点亮 Touch Bar:
#     yay -S --needed dkms linux-headers
#     git clone https://github.com/AJ-dev-i60/t1-touchbar && cd t1-touchbar && sudo ./install.sh

# 2) 音频：pipewire-pulse 作为 pulseaudio 兼容层（pactl/pavucontrol 依赖）
systemctl --user enable --now pipewire-pulse.socket pipewire-pulse.service 2>&1

# 3) 系统服务（需要 sudo 密码; 注意 rtkit 的单元名是 rtkit-daemon）
sudo systemctl enable sddm tlp mbpfan rtkit-daemon upower 2>&1

# 4) 字体缓存（JetBrainsMono Nerd Font 刚安装后刷新）
fc-cache -f >/dev/null 2>&1

# 5) 备份式软链：已指向正确目标则跳过（幂等），旧配置先备份为 *.bak.<时间戳>
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

link_config "$BASEDIR" ~/.config/hypr
link_config "$BASEDIR/waybar" ~/.config/waybar
link_config "$BASEDIR/mako" ~/.config/mako
link_config "$BASEDIR/fuzzel" ~/.config/fuzzel
# kitty 复用 software/kitty 配置（不跑 X11 向的 software/install.sh）
link_config "$BASEDIR/../software/kitty" ~/.config/kitty

# 6) 脚本执行位兜底（压缩包/其他方式分发时 x 位可能丢失）
chmod +x "$BASEDIR"/script/*.sh

echo --------------------------------------------------------
echo ---- Done. 重启后于 SDDM 选择 Hyprland 会话 ----
echo --------------------------------------------------------
