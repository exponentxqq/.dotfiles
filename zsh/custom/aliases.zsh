# 自定义别名
alias zshconfig="vim ~/.zshrc"
alias ohmyzsh="vim ~/.oh-my-zsh"
alias rootless=csrutil
alias allow-all="sudo spctl --master-disable" # 允许所有来源
# 依赖外部命令的别名做存在性保护：本机未安装时不再报 command not found
(( $+commands[fastfetch] )) && alias s='fastfetch'
alias weather="curl http://wttr.in/hangzhou"
alias t="taskit fzf"

# ── shell / docker / 插件维护 ────────────────────────────────
alias reload='exec zsh'         # 重载 shell 配置（instant prompt 下秒开）
alias dco='docker compose'      # docker compose v2 快捷方式

# 更新 custom/ 下的插件与主题（各自 git pull；ZSH_CUSTOM 由 .zshrc 指向本目录）
update-zsh-plugins() {
  local base=${ZSH_CUSTOM:-$HOME/develop/dotfiles/zsh/custom}
  local repo
  for repo in $base/plugins/*(N/) $base/themes/*(N/); do
    if [[ -d $repo/.git ]]; then
      print -P "%F{cyan}==>%f ${repo:t}"
      git -C "$repo" pull --ff-only
    fi
  done
}
