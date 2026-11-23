#!/bin/sh

BASEDIR=$(
  cd "$(dirname "$0")"
  pwd
)

echo --------------------------------------------------------
echo ---- install linux system configs in $BASEDIR...... ----
echo --------------------------------------------------------

# mihomo pacman hook：升级/重装后自动恢复 capability（软链，配置版本化）
sudo mkdir -p /etc/pacman.d/hooks
sudo ln -sf "$BASEDIR/pacman/hooks/mihomo.hook" /etc/pacman.d/hooks/mihomo.hook

# 自愈：当前 mihomo 二进制缺 capability 时补上（幂等）
getcap /usr/bin/mihomo | grep -q cap_net_admin || {
  sudo setcap cap_net_admin,cap_net_raw,cap_net_bind_service=+eip /usr/bin/mihomo
  systemctl --user restart mihomo
}

echo --------------------------------------------------------
echo ---- Done. mihomo capability hook deployed. ----
echo --------------------------------------------------------
