function! SourcePluginConfig()
    for config_file in readdir($VIMHOME."/config/plugin")
        exec "source ".$VIMHOME."/config/plugin/".config_file
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
" nerdtree 插件：显示文件、文件夹图标
Plug 'ryanoasis/vim-devicons'
" git 插件
Plug 'Xuyuanp/nerdtree-git-plugin'
" 注释插件
Plug 'preservim/nerdcommenter'
" 文件查找插件
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
" 查看历史操作（相当于 jetbrains 的 local history）
Plug 'mbbill/undotree'
" 列操作
Plug 'mg979/vim-visual-multi'
" 查看 vim 寄存器
Plug 'junegunn/vim-peekaboo'
" 高亮复制的文本
Plug 'machakann/vim-highlightedyank'
" 快速插入成对符号
Plug 'tpope/vim-surround'
" 彩虹括号
Plug 'kien/rainbow_parentheses.vim'
" 强化 <C-a> <C-x>，可以对日期进行 increment、decrement
Plug 'tpope/vim-speeddating'
" emmet html
Plug 'mattn/emmet-vim'
" 自动填充成对匹配的符号
Plug 'jiangmiao/auto-pairs'

call plug#end()
