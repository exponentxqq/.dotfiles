#!/usr/bin/env bash
# 本地环境侦察：从当前环境（通常是 dsh 容器）探测目标主机服务可达性，做三态判定。
#
# 用法:
#   recon.sh <host> <port> [port...]
#   recon.sh 8080 8090                      # host 省略，从 docker/.env 的 DOCKER_HOST_IP 读取
#   HEALTH_PATH=/api/ping recon.sh 8080
#   SCHEME=https recon.sh 443               # HTTPS 服务（自签证书自动 -k）
#   ENV_FILE=~/develop/docker/.env recon.sh 8080
#
# 退出码: 0 = 至少一个端口就绪；1 = 全部不可达；2 = 用法/参数错误
set -uo pipefail

HEALTH_PATH="${HEALTH_PATH:-/}"
SCHEME="${SCHEME:-http}"
ENV_CANDIDATES=("${ENV_FILE:-}" "${HOME:-}/develop/docker/.env" /home/xuqinqin/develop/docker/.env)

usage() {
  cat <<'USAGE'
用法: recon.sh [host] <port> [port...]

参数:
  host            目标主机；省略时从 docker/.env 的 DOCKER_HOST_IP 读取
                  （首参为纯数字时视为端口，自动走省略 host 的分支）

环境变量:
  HEALTH_PATH    健康检查路径，默认 /
  SCHEME         http（默认）| https（自动加 -k 容忍自签证书）
  ENV_FILE       指定 docker/.env 路径（默认自动探测 ~/develop/docker/.env 等）

输出判定（三态）:
  ✓ 就绪                      HTTP 2xx/3xx，或 4xx（已监听，路径可能需鉴权）
  ✗ 未监听                    TCP 拒绝
  ⚠ TCP 通但 HTTP 失败        按 curl 退出码细分：56=被 reset（残留转发占用）
                              / 28=超时 / 35=TLS 握手失败 / 其他
  ⚠ 已监听但 5xx              服务内部错误，先看服务日志

示例:
  recon.sh 8080 8090 8091
  HEALTH_PATH=/api/ping recon.sh 192.168.3.99 8080
  SCHEME=https recon.sh 192.168.3.99 443

退出码: 0 = 至少一个端口就绪；1 = 全部不可达；2 = 用法/参数错误
USAGE
}

for arg in "$@"; do
  case "$arg" in
    -h|--help) usage; exit 0 ;;
  esac
done

find_env_file() {
  local f
  for f in "${ENV_CANDIDATES[@]}"; do
    if [ -n "$f" ] && [ -f "$f" ]; then printf '%s' "$f"; return 0; fi
  done
  return 1
}

env_file="$(find_env_file || true)"

read_env() { # key
  [ -n "$env_file" ] || return 1
  grep -E "^$1=" "$env_file" | head -1 | cut -d= -f2- | tr -d '\r'
}

# ---- 参数解析：首参为纯数字则视为端口，host 从 .env 取 ----
ports=()
if [ "$#" -ge 1 ] && [[ "$1" =~ ^[0-9]+$ ]]; then
  host="$(read_env DOCKER_HOST_IP || true)"
  ports=("$@")
else
  host="${1:-}"
  [ "$#" -ge 1 ] && shift
  ports=("$@")
fi

if [ -z "${host:-}" ]; then
  echo "错误: 无法确定目标主机。请显式传入 <host>，或确保 docker/.env 中有 DOCKER_HOST_IP" >&2
  exit 2
fi
if [ "${#ports[@]}" -eq 0 ]; then
  usage >&2
  echo >&2
  echo "提示: 端口清单见项目画像 docs/smoke-test-profile.md" >&2
  exit 2
fi

tcp_ok() {
  timeout 3 bash -c "exec 3<>/dev/tcp/$1/$2" 2>/dev/null
}

PROBE_CODE=""
PROBE_RC=0
probe_http() { # host port → 设置 PROBE_CODE / PROBE_RC
  local out
  out="$(curl -s -k -o /dev/null -w '%{http_code}' --connect-timeout 3 --max-time 5 \
        "${SCHEME}://$1:$2${HEALTH_PATH}" 2>/dev/null)"
  PROBE_RC=$?
  [ -z "$out" ] && out="000"
  PROBE_CODE="$out"
}

classify() { # tcp(0=ok,1=fail)
  if [ "$1" -ne 0 ]; then printf '✗ 未监听（服务未启动或未暴露）'; return; fi
  case "$PROBE_CODE" in
    000)
      case "$PROBE_RC" in
        56) printf '⚠ TCP 通但连接被 reset（残留转发占用）' ;;
        28) printf '⚠ TCP 通但响应超时（服务挂起 / 非 HTTP）' ;;
        35) printf '⚠ TLS 握手失败（对端可能是 http，或证书链问题）' ;;
        52) printf '⚠ 空响应（对端非 HTTP，或协议不匹配）' ;;
        *)  printf '⚠ TCP 通但 HTTP 失败（curl rc=%s）' "$PROBE_RC" ;;
      esac
      [ "$SCHEME" = "http" ] && printf '；若是 HTTPS 服务请用 SCHEME=https'
      ;;
    2*|3*) printf '✓ 就绪' ;;
    4*)  printf '✓ 已监听（HTTP %s，路径可能需鉴权）' "$PROBE_CODE" ;;
    5*)  printf '⚠ 已监听但 5xx（先看服务日志）' ;;
    *)   printf '? 未知（HTTP %s）' "$PROBE_CODE" ;;
  esac
}

# ---- 输出 ----
echo "=== 环境侦察 ==="
printf '运行位置   : %s (%s)\n' "$(hostname)" "$(hostname -i 2>/dev/null | awk '{print $1}')"
printf '目标主机   : %s\n' "$host"
printf '健康路径   : %s://%s%s\n' "$SCHEME" "$host" "$HEALTH_PATH"
[ -n "$env_file" ] && printf '环境文件   : %s\n' "$env_file"
echo
printf '%-8s %-10s %-8s %s\n' PORT TCP HTTP 判定
printf '%-8s %-10s %-8s %s\n' ------ ---------- -------- ------------------------------

ready=0
for p in "${ports[@]}"; do
  if tcp_ok "$host" "$p"; then tcp_s="通"; tcp_r=0; else tcp_s="拒绝"; tcp_r=1; fi
  if [ "$tcp_r" -eq 0 ]; then probe_http "$host" "$p"; code="$PROBE_CODE"; else code="-"; fi
  verdict="$(classify "$tcp_r")"
  case "$verdict" in ✓*) ready=$((ready + 1)) ;; esac
  printf '%-8s %-10s %-8s %s\n' "$p" "$tcp_s" "$code" "$verdict"
done

echo
echo "=== 下一步 ==="
cat <<'TIP'
1. 浏览器在容器内，localhost 指容器自身。先在浏览器里交叉验证：
     http://127.0.0.1:<端口><健康路径>   （浏览器所在机）
     http://<宿主IP>:<端口><健康路径>     （服务所在机）
   后者通、前者不通 → 容器侧起桥接：
     node ~/.agents/skills/smoke-testing-local-env/scripts/tcp-bridge.mjs <端口> <宿主IP> <端口>
2. 端口 TCP 通但 HTTP 000：按上面的细分判定处置；被 reset 多为残留转发占用，勿反复重试。
3. 宿主服务日志在归属方终端，容器内看不到——需要时向用户索取。
4. 就绪后按项目画像的用例入口开始，证据按"UI + 网络 + 落库"三层收集。
TIP

if [ "$ready" -gt 0 ]; then exit 0; else exit 1; fi
