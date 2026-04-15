
" 配置buffer快捷切换方式，使用:ls可以查看所有的 buffer {{{
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

" 分屏快捷键设置 {{{
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

" 缩进快捷键设置：使用 tab 键缩进 {{{
    nnoremap <Tab> V>
    nnoremap <s-Tab> V<
    vnoremap <Tab> >gv
    vnoremap <s-Tab> <gv
" }}}

" tab 快捷键设置 {{{
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
    " Operater-pending 模式 {{{
        onoremap q i"
    " }}}

    " insert 模式 {{{
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

    " normal 模式 {{{
        noremap <CR> o<Esc>
        noremap <C-CR> O<Esc>
        noremap U <C-r>
        noremap <leader>t :terminal<CR>
    " }}}

    " abbreviate 模式, 输入后按<space>可触发 {{{
        abbreviate higth hight
        abbreviate inc# #include
        abbreviate <expr> today strftime("%Y/%m/%d")
    " }}}
" }}}

" 代码块收起/展开 {{{
    noremap + za
" }}}

" 全局快捷键 {{{
    nnoremap <silent><leader><leader> :nohl<CR>
    vnoremap <silent><leader>y "+y
" }}}


" 搜索高亮管理 {{{
nnoremap <silent> <leader><space> :set hlsearch! hlsearch?<CR>
" }}}

" 会话管理 {{{
nnoremap <leader>ss :mksession!<CR>
nnoremap <leader>sl :source $VIMHOME/sessions/Default.vim<CR>
" }}}

" 插件快捷键 {{{
" NERDTree
nnoremap <leader>e :NERDTreeToggle<CR>
nnoremap <leader>pv :NERDTreeCurrentDir<CR>

" FZF
nnoremap <leader>ff :Files<CR>
nnoremap <leader>fb :Buffers<CR>
nnoremap <leader>fh :History<CR>
nnoremap <leader>fg :GFiles<CR>
nnoremap <leader>fl :Lines<CR>

" Undotree
nnoremap <leader>u :UndotreeToggle<CR>

" Vim-Airline
nnoremap <leader>wp :AirlinePasteToggle<CR>
" }}}
