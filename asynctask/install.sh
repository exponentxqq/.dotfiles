
BASEDIR=$(
  cd "$(dirname "$0")"
  pwd
)

echo start install asynctask in $BASEDIR......

if [ ! -d $BASEDIR/asynctasks.vim ]; then
    git clone --depth 1 https://github.com/skywind3000/asynctasks.vim $BASEDIR/asynctasks.vim
fi

if [ ! -f ~/bin/asynctask ]; then
    ln -s $BASEDIR/asynctasks.vim/bin/asynctask ~/bin/asynctask
fi

if [ ! -f ~/.config/asynctask/tasks.ini ]; then
    if [ ! -d ~/.config/asynctask ]; then
        mkdir ~/.config/asynctask
    fi
    cp $BASEDIR/tasks.ini ~/.config/asynctask/tasks.ini || echo tasks.ini already exists.
fi

sh $BASEDIR/../tool.sh fzf
