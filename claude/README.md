# Claude Configuration

This directory contains Claude Code configuration for cross-machine sync.

## Setup on a new machine

1. Clone your dotfiles and run:
   ```bash
   # Backup existing config if needed
   [ -f ~/.claude/settings.json ] && mv ~/.claude/settings.json ~/.claude/settings.json.bak
   [ -d ~/.claude/skills ] && [ ! -L ~/.claude/skills ] && mv ~/.claude/skills ~/.claude/skills.bak

   # Create symlinks
   ln -sf ~/.dotfiles/claude/settings.json ~/.claude/settings.json
   ln -sf ~/.dotfiles/claude/skills ~/.claude/skills
   ```

2. Create local settings with API keys:
   ```bash
   cp ~/.dotfiles/claude/settings.local.example.json ~/.claude/settings.local.json
   vim ~/.claude/settings.local.json  # Add your API key
   ```

3. Install plugins:
   ```bash
   ~/.dotfiles/claude/install-plugins.sh
   ```

## Files

| File | Description |
|------|-------------|
| `settings.json` | Shared configuration (symlinked, version controlled) |
| `settings.local.json` | Local overrides with API keys (in `~/.claude/`, **not** synced) |
| `settings.local.example.json` | Example template for local settings |
| `skills/` | Custom skills directory (symlinked) |
| `commands/` | Custom slash commands directory (symlinked) |
| `plugins.json` | Plugin manifest for quick installation |
| `install-plugins.sh` | Script to install all plugins from manifest |

## Note

`settings.local.json` is placed in `~/.claude/` (not this directory) and is
never committed to git. This keeps your API keys secure while allowing you
to sync the rest of your configuration across machines.