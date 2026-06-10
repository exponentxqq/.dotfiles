# API keys (local secrets file, not tracked in git)
[[ -f ~/.secrets ]] && source ~/.secrets

# 加载 powerlevel10k 配置
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
