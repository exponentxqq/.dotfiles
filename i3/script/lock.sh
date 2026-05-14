#!/bin/bash

blank='#00000000'
background='#1A5E81AC'
foreground='#D8DEE9FF'

primary='#82b1ff'
alert='#EBCB8BFF'
verifying='#A3BE8CFF'

i3lock \
    --screen 1 \
    --force-clock \
    --blur 5 \
    \
    --clock \
    --time-align=0 \
    --date-align=0 \
    --layout-align=0 \
    --verif-align=0 \
    --wrong-align=0 \
    --modif-align=0 \
    \
    --time-font=noto-sans \
    --date-font=noto-sans \
    --keylayout 2 \
    \
    --time-color="${foreground}" \
    --date-color="${foreground}" \
    --layout-color="${foreground}" \
    --verif-color="${verifying}" \
    --wrong-color="${alert}" \
    --modif-color="${foreground}" \
    \
    --inside-color="${background}" \
    --insidever-color='#A3BE8C33' \
    --insidewrong-color='#EBCB8B33' \
    \
    --ring-color="${primary}" \
    --ringver-color="${verifying}" \
    --ringwrong-color="${alert}" \
    \
    --keyhl-color="${primary}" \
    --bshl-color="${alert}" \
    --separator-color="${primary}" \
    --line-color="${blank}"
