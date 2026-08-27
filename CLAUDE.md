# CLAUDE.md

This file provides guidance to Claude Code when working with code in this repository.

## Project Overview

Personal dotfiles managed with GNU Stow.

## Repository Structure

- `zsh/` — Z shell configuration
- `tmux/` — Tmux configuration
- `vim/` — Vim configuration
- `i3/` — i3 window manager configuration
- `software/` — Additional software configs (amixer, kitty, ranger, wireplumber: force-analog ALC887 jack 误报 workaround)
- `kitty/` — Kitty terminal emulator configuration
- `opencode/` — opencode configuration
- `software/` — Additional software configs (amixer, etc.)
- `install.sh` — Main installation script

## Commands

```bash
# Install all dotfiles
./install.sh

# Install specific component
./tool.sh zsh
```

## skctl

```bash
# 测试
~/develop/docker/run.sh node "cd /home/xuqinqin/develop/dotfiles/tools/skctl && pnpm install --silent && node --test 'test/*.test.ts'"
# 类型检查
~/develop/docker/run.sh node "cd /home/xuqinqin/develop/dotfiles/tools/skctl && pnpm exec tsc --noEmit"
# Lint
~/develop/docker/run.sh node "cd /home/xuqinqin/develop/dotfiles/tools/skctl && pnpm exec eslint src test"
# 格式化
~/develop/docker/run.sh node "cd /home/xuqinqin/develop/dotfiles/tools/skctl && pnpm exec prettier --write src test"
```
