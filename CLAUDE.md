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
