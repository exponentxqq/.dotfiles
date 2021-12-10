
function! Count(pattern,startline)
    let l:cnt = 0
    silent! exe a:startline . ',.s/' . a:pattern . '/\=execute(''let l:cnt += 1'')/gn'
    return l:cnt
endfunction

" 自动插入注脚
inoremap <expr>;<F12> eval(Count('\[\^\d\+\]',1)+1)
imap ;n [^;<F12><Esc>ya[Go<C-O>p: <++<Esc><C-o>A

inoremap ;mb **** <++><Esc>F*;i
inoremap ;ms ~~~~ <++><Esc>F~;i
inoremap ;mh ------<Enter><Enter>
inoremap ;mt \| <++> \| <++> \|<Enter>\| ---- \| ---- \|<Enter>\| <++> \| <++> \|<Esc>kk0/<++><CR>:nohlsearch<CR>d4li
inoremap ;ml [](<++>)<Esc>F]i
inoremap ;mp ![](<++>)<Esc>F]i
inoremap ;mc ```<Enter><++><Enter>```<Enter><++><Esc>3kA
inoremap ;mv `` <++><Esc>F`i
inoremap ;m1 #<Space><Enter><Enter><++><Esc>2kA
inoremap ;m2 ##<Space><Enter><Enter><++><Esc>2kA
inoremap ;m3 ###<Space><Enter><Enter><++><Esc>2kA
inoremap ;m4 ####<Space><Enter><Enter><++><Esc>2kA
inoremap ;m5 #####<Space><Enter><Enter><++><Esc>2kA
inoremap ;m6 ######<Space><Enter><Enter><++><Esc>2kA

