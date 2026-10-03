# MacBookPro13,3 Arch 蓝牙 (BCM20703A2) 配置与键盘配对

> 本机实战记录 (2026-10-03): bluez 安装、状态栏菜单、Filco 蓝牙键盘配对全过程。
> 状态栏蓝牙菜单见 `hypr/script/bt-menu.sh` (文档: `hypr/README.md`);
> WiFi 专题见同目录 `arch_wifi.md`。

## 硬件背景

- 芯片: Broadcom **BCM20703A2** (Apple 定制 UART 版), 挂 PCH 的 `dw-apb-uart.2` (ttyS5)
  - **不经过 T1**: T1 固件缺失不影响蓝牙, 蓝牙修复也不必等 T1 恢复
- 内核 `hci_uart_bcm` 驱动自动绑定, ROM 固件 (001.002.109) 应答正常
- 缺 patch 固件: 内核按 `brcm/BCM.hcd` 查找未命中 → 日志 `Patch file not found`
  - **无害 (本机实测)**: ROM 固件足够, 不需要补 patch 固件
- Controller MAC: `78:4F:43:A2:9E:99` (WiFi 用相邻的 :98, 见 arch_wifi.md)

## 症状自查

```bash
# 1. 控制器是否上电
bluetoothctl show | grep -E "Controller|Powered"
#   正常: Powered: yes

# 2. 能否发现设备
bluetoothctl scan on     # 15 秒后 Ctrl-C, 看是否出现周边设备

# 3. 服务与驱动日志
systemctl status bluetooth
journalctl -u bluetooth --since "-10 min"
journalctl -k | grep -iE "hci_uart|bcm|bluetooth" | tail -20
```

## 修复步骤 (一次性)

```bash
sudo pacman -S bluez bluez-utils blueman
sudo systemctl enable --now bluetooth
bluetoothctl power on
bluetoothctl scan on        # 验证能发现设备 (15s 后 Ctrl-C)
```

本机实测 (2026-10-03): `hci0` 正常上电, 15 秒发现 2 个设备, 收发正常。
日志中的 `Patch file not found` (brcm/BCM.hcd) 无需处理。

<details>
<summary>仅当 hci0 无法 up / 不稳定时: 补 patch 固件 (本机未用到)</summary>

- 来源: 任何 2016/2017 MBP 的 macOS `/usr/share/firmware/brcm/BCM20703A2_*.hcd`
- 放置: `sudo cp BCM20703A2*.hcd /usr/lib/firmware/brcm/BCM.hcd && sudo reboot`
- 验证: `journalctl -b | grep hci0` 应无 "Patch file not found"
</details>

## 蓝牙键盘配对实战 (Filco, 2026-10-03 踩坑记录)

Filco Convertible 系列 (含 67 键 Minila-R, MAC `00:18:00:3C:B6:6C`) 用**传统 PIN 配对**:
电脑屏幕显示 PIN → 在键盘上输入 + 回车 (屏幕无回显, ~30 秒内完成)。

### 正确流程

**1. 键盘进配对模式** (关键: 组合键要**按住不松**再按数字):

```
按住 Ctrl + Alt + Fn  →  点按数字 1~4 选通道  →  松开全部
蓝灯持续快闪 = 配对等待模式
```

**2. 电脑侧完整配对** (必须走有 PIN 交互的路径):

```bash
bluetoothctl
[bluetooth]# scan on
[bluetooth]# pair 00:18:00:3C:B6:6C     # 显示 PIN → 立刻在键盘敲 PIN + 回车
[bluetooth]# trust 00:18:00:3C:B6:6C
[bluetooth]# connect 00:18:00:3C:B6:6C
[bluetooth]# info 00:18:00:3C:B6:6C     # 确认 Paired/Trusted/Connected 全 yes
```

配对成功后, 日常用 waybar 菜单点连/断即可 (已配对设备免 PIN 直连)。

### 踩过的坑

| 现象 | 根因 | 处理 |
|---|---|---|
| 连接成功但打字无反应, 一会儿自动断开 | `Paired: no` — pair 没完成 (无 bond/密钥), bluez 拒绝建立 HID 会话 | 两侧清干净重配: `bluetoothctl remove <MAC>` + 键盘换通道 (`Ctrl+Alt+Fn` → 换个数字) + 完整 pair/trust/connect |
| 日志: `hidp_add_connection() Rejected connection from !bonded device` | 同上, 上一条的日志证据 | 同上 |
| 按 `Ctrl+Alt+Fn` 只亮蓝灯不闪, 松开就灭 | 正常 — 已进"装置切换模式", 但**没按数字就松手** = 退出 | 按住组合键不放, 另一手按数字, 再松开 |
| 菜单/非交互 `bluetoothctl pair` 失败 | Filco 的 PIN 交互拿不到提示 | 用交互式 bluetoothctl (终端能看到 PIN) 或 blueman-manager |
| 配对超时失败 | PIN 环节动作太慢 / 通道有残留 key | 30 秒内输完; 或换个没用过的通道 (1~4) |

### 判别要点

- **HID 键盘必须 `Paired: yes` 才能输入**: `Trusted: yes` 只是免连接确认, 不建立加密链路
- `Connected: yes` 但打字无反应 → 十有八九是 `Paired: no`, 看 `bluetoothctl info <MAC>` 确认

## 连接故障排查

```bash
# 设备状态 (Paired/Trusted/Connected/UUID)
bluetoothctl info <MAC>

# 服务日志 (断开原因、HID 拒绝)
journalctl -u bluetooth --since "-15 min"

# 驱动/固件层
journalctl -k | grep -iE "hci|brcm|bluetooth" | tail -20
```

## 日常使用

### 状态栏菜单 (waybar)

点击 waybar 蓝牙图标 → fuzzel 菜单 (`hypr/script/bt-menu.sh`):

- **扫描新设备 (10 秒)**: 完成后自动重开菜单显示新发现设备
- **打开 blueman 管理器**: 图形界面兜底 (复杂配对 / PIN 输入 / 传文件)
- **关闭 / 开启蓝牙**: 按当前状态切换 (关闭会断开所有设备)
- **设备列表**: 已连接 → 点击断开 · 已配对 → 点击连接 · 新设备 → 点击配对+信任+连接
- 操作结果均有 mako 通知; 配对失败可改用 blueman 完成
- 注意: 需 PIN 交互的键盘类设备, 首次配对走上文 bluetoothctl/blueman, 之后用菜单

### bluetoothctl 速查

```bash
bluetoothctl devices                                  # 已知设备
bluetoothctl info <MAC>                               # 设备详情
bluetoothctl connect <MAC>                            # 连接 (已配对设备)
bluetoothctl disconnect <MAC>                         # 断开
bluetoothctl power off                                # 关蓝牙 (断开全部设备)
bluetoothctl remove <MAC>                             # 删除配对记录
bluetoothctl --timeout 10 scan on                     # 定时扫描 10 秒 (不留扫描状态)
```

## 已知限制与安全提示

- A2DP 蓝牙音频可能断续 (上游已知问题, 见 Dunedan/mbp-2016-linux)
- **不要**安装 `bt-agent -c NoInputNoOutput` 类工具 — 它会静默接受一切配对请求,
  附近的人可偷配假键盘; 需要配对时用 `bluetoothctl` / `blueman` 手动确认
- 配对完成后若 `scan on` 忘了关 (`bluetoothctl show` 显示 `Discovering: yes`),
  `bluetoothctl scan off` 关掉, 省电且避免日志刷屏
