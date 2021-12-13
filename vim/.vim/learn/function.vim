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

" 全局函数必须以大驼峰命名
" range声明函数是个范围函数，可以传递诸如`1,5`、`1,$`之类的指定文本范围的参数
function! TestRange() abort range
    let l:line = getline('.')
    let l:line = line('.') . ' ' . l:line
    call setline('.', l:line)
endfunction

" 可变参数
function! UseVarargin(named, ...)
    echo 'named argin: ' . string(a:named)
    if a:0 >= 1
        echo 'first varargin: ' . string(a:1)
    endif
    if a:0 >= 2
        echo 'second varargin: ' . string(a:2)
    endif

    echo 'have varargin: ' . a:0
    for l:arg in a:000
        echo 'iterate varargin: ' . string(l:arg)
    endfor
endfunction

" 闭包函数
function! Foo()
    let x = 0
    function! Bar() closure
        let x += 1
        return x
    endfunction
    return funcref('Bar')
endfunction

function! BufLoaded() abort
    let l:lsBufShow = []
    for i in range(1, tabpagenr('$'))
        call extend(l:lsBufShow, tabpagebuflist(i))
    endfor
    return l:lsBufShow
endfunction

finish

测试行1
测试行2
测试行3
测试行4
测试行5
