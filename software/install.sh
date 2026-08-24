#!/bin/sh

BASEDIR=$(
  cd "$(dirname "$0")"
  pwd
)

echo --------------------------------------------------------
echo ---- install tool softwares and config in $BASEDIR...... ----
echo --------------------------------------------------------

sh $BASEDIR/../tool.sh kitty copyq flameshot
if [ -d ~/.config/kitty ]; then
  rm -rf ~/.config/kitty
fi
ln -s $BASEDIR/kitty ~/.config/kitty

sh $BASEDIR/../tool.sh tdrop

sh $BASEDIR/../tool.sh shutter
mkdir -p ~/Documents/captures

sh $BASEDIR/../tool.sh albert

sh $BASEDIR/../tool.sh alsa-utils
if [ -d ~/.asoundrc ]; then
  rm -rf ~/.asoundrc
  ln -s $BASEDIR/amixer/asoundrc ~/.asoundrc
fi

sh "$BASEDIR/ranger/install.sh"

# wireplumber 未安装时跳过（全新机器上 pipewire-pulse 由 i3/install.sh 稍后安装）
command -v wireplumber >/dev/null 2>&1 && sh "$BASEDIR/wireplumber/install.sh"
