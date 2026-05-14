#!/bin/sh

BASEDIR=$(
  cd "$(dirname "$0")"
  pwd
)

echo --------------------------------------------------------
echo ----  install i3 and config in $BASEDIR......      ----
echo --------------------------------------------------------

sh $BASEDIR/../tool.sh i3lock i3status picom dunst polybar variety

if [ -d ~/.config/i3 ]; then
  rm -rf ~/.config/i3
  ln -s $BASEDIR/i3 ~/.config/i3
fi

if [ -d ~/.config/polybar ]; then
  rm -rf ~/.config/polybar
  ln -s $BASEDIR/i3/polybar ~/.config/polybar
fi

if [ -d ~/.config/variety/Favorites ]; then
  rm -rf ~/.config/variety/Favorites
  ln -s $BASEDIR/i3/wallpaper ~/.config/variety/Favorites
fi
