# ~/.zshenv — 软链自 ~/develop/dotfiles/zsh/.zshenv
# 所有 zsh 调用（交互/非交互/登录/脚本）都会加载本文件，保持精简：
# 只放环境级变量（PATH 等），勿放 zle/补全/别名等交互特性。
# （原写在 .zshrc 里的 PATH 移到这里：非交互 zsh 脚本与 AI Agent
#   也能拿到 ~/develop/docker/bin 等包装脚本，而不是只有交互式 shell。）

# typeset -U 让 path 数组自动去重（重复路径只保留首次出现），
# 因此重复 source / 嵌套 zsh 不会堆积 PATH
typeset -U path PATH

path=(
  $HOME/develop/docker/bin
  $HOME/.bun/bin
  $HOME/.local/bin
  $HOME/develop/dotfiles/bin
  /usr/local/bin
  $path
)
export PATH
