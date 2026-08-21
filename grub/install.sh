#!/bin/sh

BASEDIR=$(
  cd "$(dirname "$0")"
  pwd
)

echo --------------------------------------------------------
echo ---- install grub vimix theme and config in $BASEDIR......
echo --------------------------------------------------------

# 1) 首次生成主题源（若 themes/vimix 缺失或为空，之后纳入 git 无需再联网）
if [ ! -d "$BASEDIR/themes/vimix" ] || [ -z "$(ls -A "$BASEDIR/themes/vimix" 2>/dev/null)" ]; then
  tmp=$(mktemp -d)
  git clone --depth=1 https://github.com/vinceliuice/grub2-themes "$tmp"
  sh "$tmp/install.sh" -g "$BASEDIR/themes" -t vimix -s 1080p -i color
  rm -rf "$tmp"
fi

# 2) 用 grub-mkfont 从 TTF 生成 DejaVu Sans 字体（菜单 18pt + 终端 16pt）
grub-mkfont -o "$BASEDIR/themes/vimix/dejavu-18.pf2" --size=18 "$BASEDIR/fonts/DejaVuSans.ttf"
grub-mkfont -o "$BASEDIR/themes/vimix/dejavu-16.pf2" --size=16 "$BASEDIR/fonts/DejaVuSans.ttf"

# 3) 复制主题到 /boot（跨文件系统 + root 所有，不能软链，用 cp）
sudo mkdir -p /boot/grub/themes
sudo rm -rf /boot/grub/themes/vimix
sudo cp -a --no-preserve=ownership "$BASEDIR/themes/vimix" /boot/grub/themes/vimix

# 4) 部署 drop-in 配置片段（软链，配置版本化）
sudo mkdir -p /etc/default/grub.d
sudo ln -sf "$BASEDIR/config/99-grub-theme.cfg" /etc/default/grub.d/99-grub-theme.cfg

# 5) 注释 /etc/default/grub 里的 GRUB_CMDLINE_LINUX_DEFAULT（由片段接管，幂等）
if grep -q '^GRUB_CMDLINE_LINUX_DEFAULT=' /etc/default/grub; then
  sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=/#GRUB_CMDLINE_LINUX_DEFAULT=/' /etc/default/grub
fi

# 6) 重新生成 grub.cfg（主题 + 内核参数一并生效）
sudo grub-mkconfig -o /boot/grub/grub.cfg

echo --------------------------------------------------------
echo ---- Done. Reboot to see vimix theme + zswap disabled. ----
echo --------------------------------------------------------
