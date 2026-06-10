# Codex Configuration

Codex CLI 的自定义 provider 配置，支持 GLM (智谱) 和 DeepSeek。

## 快速开始

1. 设置环境变量 (在 `~/.secrets` 中，已由 `.zshrc` 自动加载):
   ```bash
   export GLM_API_KEY="your-glm-api-key"        # Z.AI gateway key
   export DEEPSEEK_API_KEY="your-deepseek-api-key"
   export OPENROUTER_API_KEY="your-openrouter-key"  # 可选，用于 fallback
   ```

2. 运行安装脚本:
   ```bash
   sh ~/develop/dotfiles/codex/install.sh
   ```

## 使用

```bash
codex --profile glm              # GLM (智谱)
codex --profile glm-5            # GLM-5
codex --profile deepseek         # DeepSeek V4 Pro
codex -p deepseek-flash          # DeepSeek V4 Flash
```

## 文件

| 文件 | 说明 |
|------|------|
| `config.toml` | Codex 全局配置 (symlink 到 `~/.codex/config.toml`) |
| `install.sh` | 安装脚本 |

## 兼容性说明

Codex 默认使用 OpenAI Responses API，而 GLM 和 DeepSeek 仅支持 Chat Completions API。
配置中使用 `wire_api = "chat"` 进行适配。

如果 DeepSeek 直连遇到问题 (tool_calls 消息格式错误)，可使用 OpenRouter 作为代理:

1. 注册 [OpenRouter](https://openrouter.ai/) 并获取 API key
2. 在 OpenRouter 的 BYOK 设置中添加你的 DeepSeek API key
3. 设置 `export OPENROUTER_API_KEY="your-openrouter-key"`
4. 使用 `codex --profile openrouter-deepseek`
