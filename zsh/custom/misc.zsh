# API keys (local secrets file, not tracked in git)
[[ -f ~/.secrets ]] && source ~/.secrets

# powerlevel10k 配置由主题自身自动加载 ~/.p10k.zsh
# （软链自本仓库 zsh/.p10k.zsh），此处不再手动 source，避免 91KB 文件被解析两次
