#!/bin/sh
# Toggle mouse mode in tmux
old=$(tmux show -gv mouse)
new="on"
if [ "$old" = "on" ]; then new="off"; fi
tmux set -g mouse "$new"
