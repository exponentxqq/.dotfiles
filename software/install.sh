#!/bin/sh

BASEDIR=$(
  cd "$(dirname "$0")"
  pwd
)

echo --------------------------------------------------------
echo ---- install tool softwares and config in $BASEDIR...... ----
echo --------------------------------------------------------

sh $BASEDIR/../tool.sh kitty
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
  ln -s $BASEDIR/software/amixer/asoundrc ~/.asoundrc
fi
