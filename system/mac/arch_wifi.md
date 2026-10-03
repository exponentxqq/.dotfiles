# MacBookPro13,3 Arch WiFi (BCM43602) 修复与配置

> 本机实战记录 (2026-10-03): 从"内置网卡全聋、只能靠 USB 网卡"到 5GHz 可用。
> 状态栏 WiFi 菜单见 `hypr/script/wifi-menu.sh` (文档: `hypr/README.md`)。

## 硬件背景

- 芯片: Broadcom **BCM43602** (PCIe, `14e4:43ba`), 驱动 `brcmfmac`
- 固件 bin: linux-firmware 自带 (`brcmfmac43602-pcie.bin`, 7.35.177.61)
- **缺 NVRAM 校准文件**: macOS 全盘安装时擦除, linux-firmware 不含 Apple 定制版
  → 无 5GHz、MAC 为占位符、信号极差 ("聋")

## 症状自查

```bash
# 1. permaddr 是占位符 = NVRAM 未加载 (注意: link/ether 是 NM 随机化 MAC, 别看错)
ip link show wlp3s0 | grep -oE "permaddr [0-9a-f:]+"
#   症状: 00:90:4c:0d:f4:3e (00:90:4c = Broadcom 占位符 OUI)
#   正常: 78:4f:43:a2:9e:98 (本机真实值)

# 2. Band 数量
iw phy | grep -cE "^\s*Band [0-9]"
#   症状: 1 个 (仅 2.4GHz) / 正常: 2 个

# 3. regdomain (5GHz 发射权限)
iw reg get
#   症状: global country 00 + 5170-5250 PASSIVE-SCAN → 5G 无法关联
#   正常: phy#0 country 99 (固件自管理), 5G 频段无 passive/DFS 标记
```

## 修复步骤 (一次性)

### 1. 下载 NVRAM 模板

```bash
curl -LO https://raw.githubusercontent.com/nohzafk/omarchy-macbookpro-t1/main/firmware/brcmfmac43602-pcie.txt
```

### 2. 替换打码的 macaddr (必做!)

模板第 8 行 `macaddr=xx:xx:xx:xx:xx:xx` 是发布者脱敏的占位符。
用**本机蓝牙 MAC 的相邻地址** (保持 Apple OUI、保证全球唯一):

```bash
# 蓝牙 MAC (Apple 原厂分配):
bluetoothctl show | grep Controller        # 本机: 78:4F:43:A2:9E:99
# WiFi 用它减一:
sed -i 's/^macaddr=.*/macaddr=78:4F:43:A2:9E:98/' brcmfmac43602-pcie.txt
```

> ⚠️ **不替换会翻车** (本机实测): 无效 MAC 让固件初始化崩溃 —
> `Retrieving cur_etheraddr failed, -5` → `Dongle setup failed` → **接口完全消失** (比修复前更糟)。

### 3. 替换 ccode=00 → CN (5GHz 必做!)

模板 `ccode=00` (世界模式) 会让 5GHz 全部变成 passive/NO-IR, 无法关联:

```bash
sed -i 's/^ccode=00/ccode=CN/' brcmfmac43602-pcie.txt
```

### 4. 安装 + 重启

```bash
sudo install -o root -g root -m 644 brcmfmac43602-pcie.txt /usr/lib/firmware/brcm/
sudo reboot        # 驱动被 NetworkManager 持有, 无法热重载
```

### 5. 验证

```bash
iw phy | grep -cE "^\s*Band [0-9]"      # 2
ip link show wlp3s0 | grep permaddr     # 78:4f:43:a2:9e:98
iw reg get | grep -A6 "phy#0"           # country 99, 5G 无 passive
nmcli dev wifi list                     # 5GHz AP 可见 (5xxx MHz)
```

## 两个坑的原理

| 坑 | 机制 | 后果 |
|---|---|---|
| `macaddr=xx:xx` | dongle 拿无效 MAC 初始化崩溃 | `Dongle setup failed`, wlp3s0 消失 |
| `ccode=00` | world regdom → 5GHz 全部 NO-IR | 5G 关联无法发起 (客户端侧死锁) |
| (叠加) 路由器双频同 SSID | AP band-steering 以 `status_code=16` 拒 2.4G 关联 | 2.4G 被 AP 拒 + 5G 被客户端禁 → 双向死锁 |

## 连接故障排查

看真实失败原因 (别信 UI 提示, 日志才是真相):

```bash
# NetworkManager: 状态机 + 失败原因
journalctl -u NetworkManager --since "-15 min" | grep -iE "wlp3s0|auth|fail|secret"

# wpa_supplicant: 关联层细节 (ASSOC-REJECT 的 status_code)
journalctl -u wpa_supplicant --since "-15 min" | grep -iE "assoc|auth|reject|CTRL-EVENT"

# 驱动层: 固件加载/NVRAM
journalctl -k | grep brcmfmac
```

常见失败形态:

| 日志特征 | 含义 | 处理 |
|---|---|---|
| `ASSOC-REJECT status_code=16` | AP 侧拒绝 (常见 band-steering 引流/MAC 过滤) | 修 5G 后连 5G; 或查路由器 |
| `association took too long` + `no-secrets` | 关联超时, NM 误以为密码问题 | 看前置关联失败原因 |
| `5170-5250 PASSIVE-SCAN` | regdomain 世界模式, 5G 禁止发射 | NVRAM `ccode=CN` |
| `no clm_blob available` | **红鲱鱼, 无害** | 不用伪造 clm_blob (有崩溃报告) |

## 日常使用

### 状态栏 WiFi 菜单 (waybar)

点击 waybar 网络图标 → fuzzel 菜单 (`hypr/script/wifi-menu.sh`):
- 顶部: 刷新列表 / 断开当前连接
- 列表按信号排序、同 SSID 去重; 锁 = 加密, 勾 = 已连接
- 已保存 profile 免密直连; 新网络弹 fuzzel 密码框; 结果 mako 通知

### nmcli 速查

```bash
nmcli dev wifi connect QQ password 'xxx' ifname wlp3s0   # 连接
nmcli connection show                                     # 已存 profile
nmcli connection delete QQ_5G                             # 删幽灵 profile (SSID 已不存在)
nmcli -f SSID,BSSID,CHAN,SIGNAL dev wifi list             # 扫描 (含 BSSID/频段)
iw dev wlp3s0 link                                        # 当前连接详情 (频段/信号/速率)
```

### (可选, 未实施) 5GHz 优先双 profile

同 SSID 双频时 supplicant 按信号选, 2.4G 传播远总赢。想要 5G 优先且保留回退:

```bash
nmcli connection clone QQ QQ-5G
nmcli connection modify QQ-5G 802-11-wireless.band a connection.autoconnect-priority 10
nmcli connection modify QQ 802-11-wireless.band bg connection.autoconnect-priority 5
```

> 不要在**单个** profile 上 pin band/bssid — 5G 失联时会把自己锁死在离线状态;
> 双 profile 按优先级竞争才有回退。

## 回退

```bash
sudo rm /usr/lib/firmware/brcm/brcmfmac43602-pcie.txt
sudo reboot        # 回到无 NVRAM 状态 (2.4GHz 勉强可用, 5G 无)
```
