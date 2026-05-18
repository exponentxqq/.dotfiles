#!/bin/sh

BASEDIR=$(
  cd "$(dirname "$0")"
  pwd
)

echo start config docker in "$BASEDIR......"

sh "$BASEDIR/../tool.sh" docker docker-compose docker-buildx
