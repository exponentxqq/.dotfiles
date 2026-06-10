# 自定义快捷键
bindkey '`' 'autosuggest-accept'

# tasklist: Ctrl+R 快速搜索任务
tasklist() {
    taskit fzf
}
zle -N tasklist && bindkey ^R tasklist
