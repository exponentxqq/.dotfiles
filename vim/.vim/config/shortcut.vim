
" 配置buffer快捷切换方式，使用:ls可以查看所有的buffer {{{
    nnoremap <leader>b1 :1b<CR>
    nnoremap <leader>b2 :2b<CR>
    nnoremap <leader>b3 :3b<CR>
    nnoremap <leader>b4 :4b<CR>
    nnoremap <leader>b5 :5b<CR>
    nnoremap <leader>b6 :6b<CR>
    nnoremap <leader>bs :buffers<CR>
    nnoremap <leader>bc :bdelete<CR>
    nnoremap <leader>bn :bnext<CR>
    nnoremap <leader>bp :bprev<CR>
    nnoremap <leader>bb :bfirst<CR>
    nnoremap <leader>bl :blast<CR>
" }}}
" 分屏连续键设置{{{
    nnoremap <leader>wl :set splitright<CR>:vsplit<CR>
	nnoremap <leader>wh :set nosplitright<CR>:vsplit<CR>
	nnoremap <leader>wk :set nosplitbelow<CR>:split<CR>
	nnoremap <leader>wj :set splitbelow<CR>:split<CR>
    nnoremap <leader>wn :vnew<CR>
	nnoremap <C-j> <C-w>j
	nnoremap <C-k> <C-w>k
	nnoremap <C-h> <C-w>h
	nnoremap <C-l> <C-w>l
	nnoremap <up> :res +1<CR>
	nnoremap <down> :res -1<CR>
	nnoremap <left> :vertical resize-1<CR>
	nnoremap <right> :vertical resize+1<CR>
" }}}
" 缩进连续键设置：使用tab键缩进 {{{
    nnoremap <Tab> V>
    nnoremap <s-Tab> V<
    vnoremap <Tab> >gv
    vnoremap <s-Tab> <gv
" }}}
" tab连续键设置 {{{
	noremap te :tabnew<CR>
	noremap tp :tabprev<CR>
	noremap tn :tabnext<CR>
	noremap tc :tabclose<CR>
    noremap to :tabonly<CR>
" }}}
" 移动键设置 {{{
	nnoremap J 5j
	nnoremap K 5k
	nnoremap H 5h
	nnoremap L 5L
	noremap E $
	noremap F ^
" }}}
" 保存退出快捷键 {{{
    noremap <leader>q <Esc>:q<CR>
    noremap <leader>s <Esc>:w<CR>
	noremap <leader>x <Esc>:x<CR>
	noremap <leader>Q <Esc>:q!<CR>
	noremap <leader>S <Esc>:w!<CR>
" }}}
" 编辑相关配置 {{{
	noremap <CR> o<Esc>
	noremap <C-CR> O<Esc>
	noremap U <C-r>
    noremap <leader>t :terminal<CR>
	inoremap jk <Esc><right>
    inoremap <Esc> <Esc><right>
	inoremap <C-x> <Esc>:
    inoremap <C-d> <Esc>yyp
	inoremap ( ()<left>
    inoremap { {}<left>
    inoremap [ []<left>
    inoremap < <><left>
    inoremap ' ''<left>
    inoremap " ""<left>
	inoremap ;f <Esc>/<++><CR>:nohlsearch<CR>i<Del><Del><Del><Del>
    inoremap ;s <++><Esc>F<i
    inoremap ;d <Esc>A
" }}}
" 代码块收起/展开 {{{
	noremap + za
" }}}
nnoremap <silent><leader><leader> :nohl<CR>
vnoremap <silent><leader>y "+y

