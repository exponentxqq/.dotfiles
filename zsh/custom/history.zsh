# 历史记录增强（叠加在 oh-my-zsh lib/history.zsh 默认值之上：
# omz 已设 HISTSIZE>=50000/SAVEHIST>=10000 + share_history/extended_history/
# hist_ignore_dups/hist_ignore_space/hist_verify/hist_expire_dups_first）
HISTSIZE=100000
SAVEHIST=50000
# 不止连续重复：历史中完全重复的旧命令直接删除，常用命令永远排在最前
setopt hist_ignore_all_dups
# 写入历史文件时也去重（默认仅内存列表去重）
setopt hist_save_no_dups
# 记录前去掉命令中的多余空白
setopt hist_reduce_blanks
