#!/bin/sh

BASEDIR=$(
  cd "$(dirname "$0")"
  pwd
)

echo --------------------------------------------------------
echo ---- install range and config in $BASEDIR...... ----
echo --------------------------------------------------------

sh $BASEDIR/../../tool.sh ranger

if [ -d ~/.config/ranger ]; then
  rm -rf ~/.config/ranger
fi
ln -s $BASEDIR/ranger ~/.config/ranger
