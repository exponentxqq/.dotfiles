#!/bin/sh

BASEDIR=$(
  cd "$(dirname "$0")"
  pwd
)

echo --------------------------------------------------------
echo ---- install zsh and config in $BASEDIR...... ----
echo --------------------------------------------------------

sh $BASEDIR/../tool.sh zsh

if [ -d ~/.oh-my-zsh ]; then
  rm -rf ~/.oh-my-zsh
fi
wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | sh

# 插件与主题直接安装到 $BASEDIR/custom/ 下（.zshrc 中 ZSH_CUSTOM 指向该目录）。
# 不再把 ~/.oh-my-zsh/custom 软链到 dotfiles：软链在重装/更新 oh-my-zsh 后
# 容易丢失，导致插件"消失"（zsh-autosuggestions 等找不到但不报错）。
# oh-my-zsh 会自动 source $ZSH_CUSTOM/*.zsh，因此 custom 下的 .zsh 文件无需额外配置
mkdir -p $BASEDIR/custom/plugins $BASEDIR/custom/themes

echo --------------------------------------------------------
echo ---- start install zsh plugin ----
echo --------------------------------------------------------

# 已存在（且是完整 git 仓库）则跳过，脚本可幂等重跑
clone_if_absent() {
  if [ -d "$2/.git" ]; then
    echo "已存在，跳过: $2"
  else
    rm -rf "$2"
    git clone --depth=1 "$1" "$2"
  fi
}

clone_if_absent https://github.com/romkatv/powerlevel10k.git $BASEDIR/custom/themes/powerlevel10k
clone_if_absent https://github.com/zsh-users/zsh-syntax-highlighting.git $BASEDIR/custom/plugins/zsh-syntax-highlighting
clone_if_absent https://github.com/zsh-users/zsh-autosuggestions.git $BASEDIR/custom/plugins/zsh-autosuggestions

# 软链配置文件：已是正确软链则跳过，否则替换（软链或普通文件）
ensure_link() {
  if [ "$(readlink -f "$1" 2>/dev/null)" = "$2" ]; then
    echo "软链已存在: $1 -> $2"
  else
    rm -rf "$1"
    ln -s "$2" "$1"
  fi
}

# p10k 配置收进 dotfiles 管理：~/.p10k.zsh 若为普通文件则接管原内容
if [ -f ~/.p10k.zsh ] && [ ! -L ~/.p10k.zsh ] && [ ! -f $BASEDIR/.p10k.zsh ]; then
  mv ~/.p10k.zsh $BASEDIR/.p10k.zsh
fi
ensure_link ~/.p10k.zsh $BASEDIR/.p10k.zsh

ensure_link ~/.zshrc $BASEDIR/.zshrc
ensure_link ~/.zshenv $BASEDIR/.zshenv
