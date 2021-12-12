" 错误不会终止函数运行
function! s:foo()
    echomsg 'before error'
    echomsg error
    echomsg 'after error'
endfunction
call s:foo()

" abort声明函数遇到错误立即终止，一般建议所有函数定义都加上abort声明
function! s:foo() abort
    echomsg 'before error'
    echomsg error
    echomsg 'after error'
endfunction
call s:foo()

" range声明函数是个范围函数，可以传递诸如`1,5`、`1,$`之类的指定文本范围的参数
function! g:test_range() range
    let l:line = getline('.')
    let l:line = line('.') . ' ' . l:line
    call setline('.', l:line)
endfunction

finish

测试行1
测试行2
测试行3
测试行4
测试行5
