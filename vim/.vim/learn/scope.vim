let s:hello = 1
let s:world = 2
let s:hello_world = s:hello + s:world
echo s:

" 进入ex模式，执行如下命令会是以下结果
    " `s:`变量只能用于当前脚本内，其他任何地方都无法再访问
" :source %
" {'hello': 1, 'hello_world': 3, 'world': 2}
" :echo s:
" E121: Undefined variable: s:
" :echo s:hello
" E121: Undefined variable: s:hello

