#!/bin/sh

BASEDIR=$(
  cd "$(dirname "$0")"
  pwd
)

mkdir -p ~/.agents
rm -rf ~/.agents/skills
ln -sfn "$BASEDIR/skills" ~/.agents/skills
