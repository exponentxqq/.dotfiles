let list = [1, 2, 3, 4, 5]
echo 'foreach list'
for item in list
    echo item
endfor

echo '-----------------------'

let dict = {'a': 1, 'y': 2, 'z': 3, 'u': 4, 'v': 5, 'w': 6}
echo 'foreach dict with items'
for [key, val] in items(dict)
    echo key . '=>' . val
endfor

echo 'foreach dict with keys'
for key in keys(dict)
    echo key . '=>' . dict[key]
endfor

echo 'foreach dict with values'
for val in values(dict)
    echo val
endfor

echo '-----------------------------'
echo 'while'
let i = 1
while i < 5
    echo i
    let i += 1
endwhile

