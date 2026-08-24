#!/bin/sh

BASEDIR=$(
  cd "$(dirname "$0")"
  pwd
)

echo --------------------------------------------------------
echo ---- install wireplumber force-analog hooks in $BASEDIR...... ----
echo --------------------------------------------------------

# 备份式软链：已指向正确目标则跳过（幂等），旧配置先备份为 *.bak.<时间戳>
link_config() {
  target=$1
  link_path=$2
  if [ -L "$link_path" ] && [ "$(readlink "$link_path")" = "$target" ]; then
    echo "skip  : $link_path 已指向 $target"
    return 0
  fi
  if [ -e "$link_path" ] || [ -L "$link_path" ]; then
    backup="$link_path.bak.$(date +%Y%m%d%H%M%S)"
    mv "$link_path" "$backup"
    echo "backup: $link_path -> $backup"
  fi
  ln -s "$target" "$link_path"
  echo "link  : $link_path -> $target"
}

# 1) lua 脚本链到官方脚本搜索路径（XDG_DATA_HOME，conf 中裸文件名即可解析）
mkdir -p ~/.local/share/wireplumber/scripts
link_config "$BASEDIR/scripts/force-analog.lua" \
  ~/.local/share/wireplumber/scripts/force-analog.lua

# 2) conf 片段链到官方配置搜索路径（XDG_CONFIG_HOME）
mkdir -p ~/.config/wireplumber/wireplumber.conf.d
link_config "$BASEDIR/wireplumber.conf.d/51-force-analog.conf" \
  ~/.config/wireplumber/wireplumber.conf.d/51-force-analog.conf

# 3) 清理旧布局（曾把脚本放在 ~/.config/wireplumber/scripts/ + conf 写绝对路径；
#    仅删除残留的真实文件，软链目标变化由上面 link_config 处理）
if [ -d ~/.config/wireplumber/scripts ]; then
  rm -rf ~/.config/wireplumber/scripts
  echo "clean : 移除旧脚本目录 ~/.config/wireplumber/scripts"
fi

# 4) 重启生效并提示验证
systemctl --user restart wireplumber

echo "验证："
echo "  journalctl --user -u wireplumber --since '-30 sec' | grep force"
echo "  pactl list cards | grep 'Active Profile'   # 期望 output:analog-stereo+..."
