
a=`uname  -a`

echo $1
if [[ $a =~ "Darwin" ]];then
    echo "mac"
    brew install $1
elif [[ $a =~ "arch" ]];then
    echo "arch"
    yay -S $1
else
    echo ubuntu
    sudo apt-get install -y $1
fi

