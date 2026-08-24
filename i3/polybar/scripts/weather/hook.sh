#!/bin/sh
# $1: 0=compact, 1=expanded
SCRIPT=$HOME/.config/polybar/scripts/weather/main.py

if [ "$1" = "1" ]; then
    out=$(python3 "$SCRIPT" -u metric -c Yuhang -l zh_cn -e 2>/dev/null)
    [ -z "$out" ] && out="获取失败 点击重试"
    echo "%{A1:polybar-msg action "#weather.hook.0":}%{T12}${out}%{T-}%{A}"
else
    out=$(python3 "$SCRIPT" -u metric -c Yuhang 2>/dev/null)
    [ -z "$out" ] && out="--"
    echo "%{A1:polybar-msg action "#weather.hook.1":}%{T2}${out}%{T-}%{A}"
fi
