
BASEDIR=$(
  cd "$(dirname "$0")"
  pwd
)

echo install tmux in $BASEDIR......

sh $BASEDIR/../tool.sh tmux

if [ ! -f ~/.tmux.conf ]; then
    ln -s ~/.dotfiles/tmux/.tmux.conf ~/.tmux.conf
    ln -s ~/.dotfiles/tmux/.tmux.conf.local ~/.tmux.conf.local
fi

