
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
	nnoremap <S-up> :res +1<CR>
	nnoremap <S-down> :res -1<CR>
	nnoremap <S-left> :vertical resize-1<CR>
	nnoremap <S-right> :vertical resize+1<CR>
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
	nnoremap H ^
	nnoremap L $
    vnoremap J 5j
    vnoremap K 5k
    vnoremap H ^
    vnoremap L $
    nnoremap <leader>j  :<c-u>execute 'move +'. v:count1<cr>
    nnoremap <leader>k  :<c-u>execute 'move -1-'. v:count1<cr>
" }}}
" 保存退出快捷键 {{{
    noremap <leader>q <Esc>:q<CR>
    noremap <leader>s <Esc>:w<CR>
	noremap <leader>x <Esc>:x<CR>
	noremap <leader>Q <Esc>:q!<CR>
	noremap <leader>S <Esc>:w!<CR>
	noremap <leader>X <Esc>:x!<CR>
" }}}
" 编辑相关配置 {{{
    " Operater-pending模式{{{
        onoremap q i"
    " }}}
    " insert模式 {{{
        inoremap jk <Esc><right>
        inoremap <Esc> <Esc><right>
        inoremap <C-x> <Esc>:
        inoremap ;f <Esc>/<++><CR>:nohlsearch<CR>i<Del><Del><Del><Del>
        nnoremap <leader>f /<++><CR>:nohlsearch<CR>i<Del><Del><Del><Del>
        inoremap <C-d> <Esc>yyp
        inoremap ;s <++><Esc>F<i
        inoremap ;ge <Esc>A
        inoremap ;o <Esc>o
    " }}}
    " normal模式 {{{
        noremap <CR> o<Esc>
        noremap <C-CR> O<Esc>
        noremap U <C-r>
        noremap <leader>t :terminal<CR>
    " }}}
    " abbreviate模式, 输入后按<space>可触发，使用<C-v>||<Esc>可取消触发 {{{
        abbreviate higth hight
        abbreviate inc# #include
        abbreviate <expr> today strftime("%Y/%m/%d")
    " }}}
" }}}
" 代码块收起/展开 {{{
	noremap + za
" }}}
nnoremap <silent><leader><leader> :nohl<CR>
vnoremap <silent><leader>y "+y

