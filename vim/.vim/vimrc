syntax on
filetype off
filetype plugin off
filetype indent off
filetype plugin indent on

set backspace=indent,eol,start
set backupdir=~/.vim/.backup//
set directory=~/.vim/.swp//
set undodir=~/.vim/.undo//
set fileencodings=utf-8,gb2312,gbk,gb18030
set termencoding=utf-8
set encoding=utf-8
set termguicolors
set laststatus=2
" set spell spelllang=en_us,cjk
set undofile
set number
set relativenumber
set ruler
set clipboard+=unnamed
set cursorline
set nobackup
set noswapfile
set autoread
set showmatch
set matchtime=2
set textwidth=0
set nocompatible
set showcmd
set wildmenu
set novisualbell t_vb=
set shiftround
set tabstop=4
set softtabstop=4
set shiftwidth=4
set autoindent
set expandtab
set autochdir
set autoread
set nowrap
" set paste
set listchars=tab:>-,trail:-
set incsearch
set ignorecase
set smartcase
set hlsearch
set scrolloff=8
set foldmethod=indent
set foldlevel=99

noremap <leader>p :set paste!<Bar>set paste?<CR>

" 连续键配置
let mapleader=" " " 设置连续键前缀为,(默认为\)
" 快捷键载入
source $HOME/.vim/config/shortcut.vim
" 插件载入
source $HOME/.vim/config/plug-load.vim
" 自定义vim命令
source $HOME/.vim/config/command.vim

augroup default
	autocmd!
	" 更新vim配置时自动生效
	autocmd BufWritePost *.vim source $HOME/.vim/vimrc
	autocmd BufWritePost vimrc source $HOME/.vim/vimrc
augroup end
" 记住光标位置
autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exec "normal! g'\"" | endif


