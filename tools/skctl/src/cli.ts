#!/usr/bin/env node
const USAGE = `skctl - skill manager

Usage: skctl <command> [options]

Commands:
  list [--all]          List skills
  info <name>           Show skill details
  install <src> [--subdir DIR]   Install skill (git URL | zip URL | local dir)
  uninstall <name> [-y] Remove skill
  enable <name>         Enable skill
  disable <name>        Disable skill
  update [<name>...]    Update git-sourced skills
  doctor                Check and repair store
  migrate               Migrate from dotfiles/agent/skills
  --help, -h            Show this help
`;

const args = process.argv.slice(2);
if (args.length === 0 || args[0] === "--help" || args[0] === "-h") {
  console.log(USAGE);
}