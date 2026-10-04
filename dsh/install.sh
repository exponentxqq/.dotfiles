#!/bin/sh

BASEDIR=$(
  cd "$(dirname "$0")"
  pwd
)

# 与 docker 仓库 .env 的 DSH_HOST_DATA_PATH 对应（默认 /data/dsh）
DSH_DATA="${DSH_HOST_DATA_PATH:-/data/dsh}"

echo --------------------------------------------------------
echo ---- install dsh config from "$BASEDIR" ----
echo --------------------------------------------------------

# 目录保障
mkdir -p "$BASEDIR/profiles" "$BASEDIR/plugins"

# 纳管旧布局：profiles 曾直接放在 $DSH_DATA 下（未版本管理），
# 把尚未纳入 dotfiles 的 profile 目录整体移入本仓库（含插件依赖产物）。
if [ -d "$DSH_DATA/profiles" ]; then
  for d in "$DSH_DATA/profiles"/*/; do
    [ -d "$d" ] || continue
    name=$(basename "$d")
    if [ ! -e "$BASEDIR/profiles/$name" ]; then
      mv "$d" "$BASEDIR/profiles/$name"
      echo "migrated profile: $name"
    else
      echo "skip profile $name: already managed in dotfiles"
      echo "  note: leftover in $d may be produced by a broken profiles mount; safe to delete"
    fi
  done
fi

[ -d "$DSH_DATA" ] || mkdir -p "$DSH_DATA"

# 确保嵌套挂载点目录存在。
# $DSH_DATA/profiles 是容器内 ~/.dsh/profiles 的子挂载落点，容器运行期间宿主侧必须
# 保留该目录：删除会使容器内的 profiles 挂载失效（profile 回落到宿主目录，并可能在
# 下次使用时被 dsh 按模板重新初始化到宿主机）。Docker 仅在容器启动时自动创建，这里主动保障。
mkdir -p "$DSH_DATA/profiles"

echo ""
echo "dsh profiles are managed in this repo and mounted by compose:"
echo "  $BASEDIR/profiles  ->  /home/docker/.dsh/profiles"
echo ""
echo "If the dsh container is already running, apply the volume change with:"
echo "  cd ~/develop/docker && docker compose up -d dsh"
