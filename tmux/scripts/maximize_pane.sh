#!/bin/sh
# Maximize/restore pane toggle for tmux
current=$(tmux display -p '#{window_width}x#{window_height}')
target=$(tmux display -p '#{pane_width}x#{pane_height}')
if [ "$current" = "$target" ]; then
    tmux last-pane -t "$1" 2>/dev/null || tmux select-pane -t "$1" -l
else
    tmux resize-pane -t "$1" -Z
fi
