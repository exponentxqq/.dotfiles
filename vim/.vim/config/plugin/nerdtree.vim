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
" 隐藏文件是否显示
let g:NERDTreeHidden=1
" nerdtree要忽略的文件
let NERDTreeIgnore=['\.pyc','\~$','\.swp']

nnoremap <C-1> :NERDTreeToggle<CR>
nnoremap <leader>dir :NERDTreeToggle<CR>
nnoremap <leader>1 :NERDTreeToggle<CR>
nnoremap <C-l> <C-w>l

augroup nerdtree
	autocmd!
	" 只有nerdtree窗口时退出vim
	autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() |quit| endif
	" 打开vim时如果没有文件自动打开nerdtree
	autocmd VimEnter * if !argc()|NERDTree|
augroup end

