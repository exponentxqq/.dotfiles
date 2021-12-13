" 在文件末尾插入'Hello World!'文本，共row行，每行col个
function! HelloWorld(row, col)
    normal G " 跳到文件末尾
    let l:word = 'Hello World!'
    for i in range(a:row)
        normal! o
        execute 'normal! ' . a:col . 'a' . l:word
    endfor
endfunction
" call HelloWorld(100, 20)

" 把类似于`LET x = y = z = 1`解析成正常的vimscript并执行
function! ParseLet(args)
    let l:lsMatch = split(a:args, '\s*=\s*')
    if len(l:lsMatch) < 2
        return ''
    endif
    let l:value = remove(l:lsMatch, -1)
    let l:lsCmd = []
    for l:var in l:lsMatch
        let l:cmd = 'let ' . l:var . ' = ' . l:value
        call add(l:lsCmd, l:cmd)
    endfor
    return join(l:lsCmd, ' | ')
endfunction
command! -nargs=+ LET execute ParseLet(<q-args>)

