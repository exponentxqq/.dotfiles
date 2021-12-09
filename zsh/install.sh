#!/bin/sh

a=`uname  -a`

if [[ $a =~ "Darwin" ]];then
    echo "mac"
elif [[ $a =~ "ubuntu" ]];then
    echo "ubuntu"
    sudo apt-get install -y zsh
else
    echo unknow system
fi

chsh -s $(which zsh)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k

