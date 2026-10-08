# opencode Configuration

Global opencode configuration.

## Files

| File | Description |
|------|-------------|
| `opencode.jsonc` | Global opencode config (symlinked to `~/.config/opencode`) |
| `agents/` | Global agents (symlinked to `~/.config/opencode/agents`) |
| `service.json` | opencode v2 本地后台服务凭据（自动生成，gitignored，各机独立） |
| `package.json` | opencode plugin SDK dependency (auto-managed by opencode) |
| `package-lock.json` | Lockfile (auto-managed by opencode) |
| `node_modules/` | Installed SDK (auto-managed by opencode) |

## Setup on a new machine

From the dotfiles repo root:

```bash
./opencode/install.sh
```

Then restart opencode.

## Note

`package.json`, `package-lock.json`, `node_modules/`, and `service.json` are
auto-managed by opencode. They are gitignored by `.gitignore` and should not
be committed.

## V1 / V2

配置保持 opencode v1 语法（`agent`、`permission`、`mcp` 直接挂服务名等），
v1 和 v2 都能直接读取；不要在 `opencode.jsonc` 里写 v2 原生字段
（`agents`、`providers`、`permissions`、`mcp.servers`），v1 是严格校验，
未知键会导致配置整体拒绝加载。

v2 与 v1 的固有差异（配置无法弥补）：

- 不运行 LSP（`lsp` 段会被接受但忽略）；
- agent 级 `temperature` 保留但不发送；
- MCP 默认走 Code Mode，权限动作名仍为 `<server>_<tool>`。
