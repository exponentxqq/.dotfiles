#!/bin/sh

BASEDIR=$(
  cd "$(dirname "$0")"
  pwd
)

echo --------------------------------------------------------
echo ----  install zsh and config in $BASEDIR......      ----
echo --------------------------------------------------------

sh $BASEDIR/../tool.sh zsh

if [ -d ~/.oh-my-zsh ]; then
    rm -rf ~/.oh-my-zsh
fi
# sudo sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" || echo "oh-my-zsh installed"
wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | sh

echo --------------------------------------------------------
echo ----         start install zsh plugin               ----
echo --------------------------------------------------------

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k
git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone --depth=1 https://github.com/g-plane/pnpm-shell-completion.git ~/.oh-my-zsh/custom/plugins/pnpm-shell-completion

if [ -f ~/.zshrc ]; then
    rm -rf ~/.zshrc
    ln -s $BASEDIR/.zshrc ~/.zshrc
fi

