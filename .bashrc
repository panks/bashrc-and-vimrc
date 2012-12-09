source ~/.kde-bashrc
export PATH=$PATH:~/mybins

alias lsa='ls -a'
alias agi='sudo apt-get install'
alias bl30='xbacklight -set 30'

function cdb(){

    for i in `seq 1 $1`;
        do
            cd .. 
        done 
}

function bl(){

    xbacklight -set $1
}

function pushbnv(){

    current_dir=$PWD
    cd
    cp .bashrc ./bNv/.
    cp .vimrc ./bNv/.
    cd bNv
    git commit -am "$1"
    git push
    cd $current_dir
}
