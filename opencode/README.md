# opencode Configuration

Global opencode configuration.

## Files

| File | Description |
|------|-------------|
| `opencode.jsonc` | Global opencode config (symlinked to `~/.config/opencode`) |
| `agents/` | Global agents (symlinked to `~/.config/opencode/agents`) |
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

`package.json`, `package-lock.json`, and `node_modules/` are auto-managed by
opencode to match the installed binary version. They are gitignored by
`.gitignore` and should not be committed.
