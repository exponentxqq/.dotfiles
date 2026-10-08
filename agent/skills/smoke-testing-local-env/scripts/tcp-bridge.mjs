#!/usr/bin/env node
/**
 * 跨容器 TCP 桥接：把「当前环境（通常是 dsh 容器）内的监听端口」转发到「宿主服务」。
 *
 * 使用场景：浏览器运行在容器内，而前端 apiBase 是绝对 URL 且指向 localhost，
 *           浏览器会直连容器自身的端口 —— 此时在容器侧起一个临时转发即可，
 *           对宿主机零影响，容器重启即消失。
 *
 * 用法:
 *   node tcp-bridge.mjs <listenPort> <targetHost> <targetPort> [listenHost=127.0.0.1]
 *   node tcp-bridge.mjs 8080 192.168.3.99 8080
 *   node tcp-bridge.mjs --help
 *
 * 验证:
 *   curl -s http://127.0.0.1:<listenPort>/<健康路径>
 *
 * 注意: 同一端口只起一个；重复启动会明确报 EADDRINUSE。收尾时在报告中说明本进程。
 */
import net from 'node:net';

const args = process.argv.slice(2);

if (args.includes('-h') || args.includes('--help')) {
  console.log(`用法: node tcp-bridge.mjs <listenPort> <targetHost> <targetPort> [listenHost=127.0.0.1]

参数:
  listenPort    容器内监听端口（浏览器要访问的端口，如前端 apiBase 里的 8080）
  targetHost    宿主 IP（见 docker/.env 的 DOCKER_HOST_IP）
  targetPort    宿主服务端口
  listenHost    监听地址，默认 127.0.0.1（只对本容器暴露，足够浏览器使用）

示例:
  node tcp-bridge.mjs 8080 192.168.3.99 8080
  curl -s http://127.0.0.1:8080/api/ping

排查:
  端口被占用（EADDRINUSE）→ ps aux | grep tcp-bridge（容器内无 ss/netstat/lsof）
  目标不可达 → 先用 recon.sh 做三态判定，不要叠加第二层代理
`);
  process.exit(0);
}

const [listenPortRaw, targetHost, targetPortRaw, listenHost = '127.0.0.1'] = args;

if (!listenPortRaw || !targetHost || !targetPortRaw) {
  console.error('用法: node tcp-bridge.mjs <listenPort> <targetHost> <targetPort> [listenHost=127.0.0.1]');
  console.error('帮助: node tcp-bridge.mjs --help');
  process.exit(2);
}

const listenPort = Number(listenPortRaw);
const targetPort = Number(targetPortRaw);
if (!Number.isInteger(listenPort) || listenPort <= 0 || listenPort > 65535 ||
    !Number.isInteger(targetPort) || targetPort <= 0 || targetPort > 65535) {
  console.error('错误: 端口必须是 1-65535 的整数');
  process.exit(2);
}

const stamp = () => new Date().toISOString().replace('T', ' ').slice(0, 19);
let live = 0;

const server = net.createServer((client) => {
  const upstream = net.connect({ host: targetHost, port: targetPort });
  live += 1;
  console.log(`[${stamp()}] + ${client.remoteAddress}:${client.remotePort} (live=${live})`);

  client.once('close', () => {
    live -= 1;
    console.log(`[${stamp()}] - 连接关闭 (live=${live})`);
  });

  client.pipe(upstream);
  upstream.pipe(client);
  client.on('error', () => upstream.destroy());
  upstream.on('error', (err) => {
    console.error(`[${stamp()}] 上游错误: ${err.code || err.message}`);
    client.destroy();
  });
});

server.on('error', (err) => {
  if (err.code === 'EADDRINUSE') {
    console.error(`错误: 端口 ${listenPort} 已被占用 —— 可能已有桥接在运行，勿重复启动。`);
    console.error('排查: ps aux | grep tcp-bridge（容器内无 ss/netstat/lsof，勿用它们）');
  } else {
    console.error(`监听失败: ${err.message}`);
  }
  process.exit(1);
});

// 启动前预检目标可达性，避免"桥起来了但后端没起"的假象
const probe = net.connect({ host: targetHost, port: targetPort });
probe.setTimeout(3000);
probe.on('connect', () => {
  probe.destroy();
  server.listen(listenPort, listenHost, () => {
    console.log(`桥接就绪: ${listenHost}:${listenPort} -> ${targetHost}:${targetPort}`);
    console.log(`验证: curl -s http://${listenHost}:${listenPort}/<健康路径>`);
    console.log('（Ctrl-C 结束；本进程为临时桥接，容器重启即消失）');
  });
});
probe.on('timeout', () => {
  probe.destroy();
  console.error(`目标 ${targetHost}:${targetPort} 3s 内无响应 —— 先确认服务已启动（用 recon.sh 三态判定）`);
  process.exit(1);
});
probe.on('error', (err) => {
  console.error(`目标 ${targetHost}:${targetPort} 不可达: ${err.code || err.message}`);
  console.error('提示: 端口 TCP 通但 HTTP 被 reset 时，属残留转发占用，勿在此叠加第二层代理。');
  process.exit(1);
});

const shutdown = () => {
  console.log('\n关闭桥接…');
  server.close(() => process.exit(0));
  setTimeout(() => process.exit(0), 500).unref();
};
process.on('SIGINT', shutdown);
process.on('SIGTERM', shutdown);
