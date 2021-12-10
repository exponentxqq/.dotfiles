
BASEDIR=$(
  cd "$(dirname "$0")"
  pwd
)

echo ------------------------------------------
echo ---- starting install vim in $BASEDIR ----
echo ------------------------------------------

command -v vim >/dev/null 2>&1 || { sh $BASEDIR/../tool.sh vim >&2; }

rm -rf ~/.vimrc
if [ ! -d ~/.vim ]; then
    ln -s $BASEDIR/.vim ~/.vim
fi

if [ ! -d ~/.vim/backup ]; then
    mkdir ~/.vim/backup
    mkdir ~/.vim/swp
    mkdir ~/.vim/undo
fi
