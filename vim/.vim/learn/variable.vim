" list相关
" let list = [0, 1, 2, 3, 4]
let list = range(5)
echo list
call add(list, 5)
call add(list, 6)
echo list
call remove(list, -1)
echo list
call remove(list, 1)
echo list
unlet list[0]
echo list

" mao 相关
let dict = {'x': 1, 'y': 2, 'z': 3}
echo dict
echo dict['x']
echo dict.y
let var = 'z'
echo dict[var]
let dict['u'] = 4
let dict.v = 5
echo dict
unlet dict.x
echo dict
" 删除不存在的索引时会报错，可以使用!抑制错误
unlet dict.j
echo dict

" 类型判断
" 判断一个变量是否时list可以用以下三种方式
" if type(var) == v:t_list
" if type(var) == 3
" if type(var) == type([])

