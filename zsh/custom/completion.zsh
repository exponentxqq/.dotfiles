# 补全配置
# 自定义补全函数放在 custom/completions/ 下，
# oh-my-zsh 已将该目录加入 fpath，compinit 会自动加载，无需手动 source
# 大小写/连字符不敏感匹配由 oh-my-zsh lib/completion.zsh 按 .zshrc 中
# 的 CASE_SENSITIVE / HYPHEN_INSENSITIVE 变量自动配置，此处无需重复

# ── 补全菜单体验 ─────────────────────────────────────────────
# Tab 呼出菜单后可用方向键移动选择（回车确认，比循环 Tab 好用得多）
zstyle ':completion:*' menu select
# 按类型分组显示，并带分组标题（命令/文件/选项……）
zstyle ':completion:*' matches group ''
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*:corrections' format '-> %d (errors: %e)'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format 'no matches: %d'
# 菜单配色复用 LS_COLORS（未设置时跳过，交给 oh-my-zsh 尾部逻辑）
[[ -n "$LS_COLORS" ]] && zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
# cd 补全时排除当前目录自身（. 与 ..）
zstyle ':completion:*:cd:*' ignore-parents parent pwd
