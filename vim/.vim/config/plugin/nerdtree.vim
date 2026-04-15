let g:NERDTreeDirArrows = 1
" 树的显示图标
let g:NERDTreeDirArrowExpandable='+'
let g:NERDTreeDirArrowCollapsible='-'
let g:NERDTreeGlyphReadOnly = "RO"
" 窗口位置
let g:NERDTreeWinPos='left'
" 窗口是否显示行号
let g:NERDTreeShowLineNumbers=1
" 窗口尺寸
let g:NERDTreeSize=30
" 显示隐藏文件和文件夹
let g:NERDTreeShowHidden = 1
" 忽略编译产物和临时文件
let NERDTreeIgnore = [
    \ '\.pyc$',
    \ '\.pyo$',
    \ '\.class$',
    \ '\.o$',
    \ '\.a$',
    \ '\.so$',
    \ '\.dll$',
    \ '\.bin$',
    \ '\..bundle$',
    \ '\.cache$',
    \ '__pycache__/',
    \ '.pytest_cache/',
    \ '.vscode/',
    \ '.idea/',
    \ 'node_modules/',
    \ 'dist/',
    \ 'build/',
    \ 'target/',
    \ '\.git$',
    \ '\.svn$'
    \ ]

nnoremap <leader>1 :NERDTreeToggle<CR>

augroup nerdtree
	autocmd!
	" 只有nerdtree窗口时退出vim
	autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() |quit| endif
	" 打开vim时如果没有文件自动打开nerdtree
	autocmd VimEnter * if !argc()|NERDTree|
augroup end