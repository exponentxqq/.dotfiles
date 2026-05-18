#!/bin/sh

a=$(uname -a)

echo $1
if [[ $a =~ "Darwin" ]]; then
  echo "mac"
  brew install $1
elif [[ $a =~ "arch" ]]; then
  echo "arch"
  # 强制安装，不需要确认
  yay -S --noconfirm $1
else
  echo ubuntu
  sudo apt-get install -y $1
fi
