# 自定义快捷键
bindkey '`' 'autosuggest-accept'

# tasklist: Ctrl+R 快速搜索任务
tasklist() {
  zle -I
  </dev/tty >/dev/tty 2>/dev/tty taskit fzf
  zle reset-prompt
}
zle -N tasklist && bindkey ^R tasklist
