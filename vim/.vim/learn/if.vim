if 1
    echo '1 is ' . v:true
endif

if 0
    echo '0 is ' . v:true
endif

if -1
    echo '-1 is ' . v:true
endif

" ==# 表示不忽略大小写
echo 'abc' ==# 'ABC'
" ==? 表示忽略大小写
echo 'abc' ==? 'ABC'

