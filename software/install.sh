#!/bin/sh

BASEDIR=$(
  cd "$(dirname "$0")"
  pwd
)

echo --------------------------------------------------------
echo ----  install tool softwares and config in $BASEDIR......      ----
echo --------------------------------------------------------

sh $BASEDIR/../tool.sh terminator

if [ -d ~/.config/terminator ]; then
  rm -rf ~/.config/terminator
  ln -s $BASEDIR/software/terminator ~/.config/terminator
fi

sh $BASEDIR/../tool.sh guake

sh $BASEDIR/../tool.sh shutter
mkdir -p ~/Documents/captures

sh $BASEDIR/../tool.sh albert

sh $BASEDIR/../tool.sh alsa-utils
if [ -d ~/.asoundrc ]; then
  rm -rf ~/.asoundrc
  ln -s $BASEDIR/software/amixer/asoundrc ~/.asoundrc
fi
