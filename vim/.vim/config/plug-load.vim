function! SourcePluginConfig()
	for config_file in readdir($HOME."/.vim/config/plugin")
	    exec "source ".$HOME."/.vim/config/plugin/".config_file
	endfor
endfunction

call SourcePluginConfig()

call plug#begin('~/.vim/plugged')

" 状态栏效果插件
Plug 'vim-airline/vim-airline'
" 可视化显示缩进级别
Plug 'nathanaelkane/vim-indent-guides'
" 目录插件
Plug 'preservim/nerdtree'
" nerdtree插件：显示文件、文件夹图标
Plug 'ryanoasis/vim-devicons'
" git插件
Plug 'Xuyuanp/nerdtree-git-plugin'
" 注释插件
Plug 'preservim/nerdcommenter'
" markdown预览插件
" Plug 'instant-markdown/vim-instant-markdown', {'for': 'markdown', 'do': 'yarn install'}
" 文件查找插件
Plug '/usr/local/opt/fzf'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
" 查看历史操作（相当于jetbrains的local history）
Plug 'mbbill/undotree'
" 列操作
Plug 'mg979/vim-visual-multi'
" 查看vim寄存器
Plug 'junegunn/vim-peekaboo'
" 高亮复制的文本
Plug 'machakann/vim-highlightedyank'
" 快速插入成对符号
Plug 'tpope/vim-surround'
" 彩虹括号
Plug 'kien/rainbow_parentheses.vim'
" 强化<C-a> <C-x>，可以对日期进行increment、decrement
Plug 'tpope/vim-speeddating'
" emmet html
Plug 'mattn/emmet-vim'

call plug#end()

