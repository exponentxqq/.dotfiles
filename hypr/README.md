# Hyprland 配置模块

MacBook Pro 2016 15" (MacBookPro13,3, T1 芯片) 的 Hyprland / Wayland 桌面配置。

> **机型更正**: 早期文档误记为 MacBookPro14,2 (那是 13" 2017 款)。本机为 15" + 双显卡
> (Intel HD530 + AMD Polaris), 实为 **MacBookPro13,3** (15" 2016, A1707)。
> 核对: `cat /sys/class/dmi/id/product_name`。

## 组件与部署

| 文件 | 部署位置 | 说明 |
|---|---|---|
| `hyprland.conf` | `~/.config/hypr/` | 主配置 (Retina 2x 缩放, `$mod`=Super/cmd⌘, vim 风格键位, 对齐 i3) |
| `hyprlock.conf` | 同上 | 锁屏 (`Super+Ctrl+L`) |
| `hypridle.conf` | 同上 | 5min 锁屏 / 6min 息屏 / 30min 挂起 |
| `hyprpaper.conf` | 同上 | 壁纸 (复用 `../i3/wallpaper/`) |
| `waybar/` | `~/.config/waybar` | 状态栏 (Tokyo Night 配色, 输入法状态 `custom/fcitx`) |
| `mako/` | `~/.config/mako` | 通知 |
| `fuzzel/` | `~/.config/fuzzel` | 应用启动器 (`Super+D`) |
| `script/` | (随主目录软链) | `screenshot.sh` 截图 / `dropterm.sh` 下拉终端 / `restart-waybar.sh` 重启状态栏 / `clipboard.sh` 剪贴板历史 / `fcitx-status.sh` 输入法状态 / `wifi-menu.sh` WiFi 菜单 |

安装 (幂等, 自动备份旧配置):

```bash
sh install.sh
```

## T1 固件 (iBridge)

### 本机状态: 已恢复 ✓ (2026-10-03)

- `lsusb` = `05ac:8600 iBridge`, **Touch Bar 点亮** (Esc/媒体键可用), 重启后持久;
  ESP 已有 `EMBEDDEDOS/`
- 恢复方式: t1-revive (本机未物理关机也跑通; 关键前置: `acpi_call` 模块必须已加载)
- 固件备份: `~/t1-firmware-backup-2026-10-03.tar.gz` — **务必另存到机器之外**
- Touch Bar 驱动: 已装 t1bridge (+ Touch ID/fprintd); 摄像头恢复

### 恢复前的症状 (作为诊断参考)

- `lsusb` 显示 `05ac:1281 Apple Mobile Device [Recovery Mode]` — **T1 固件缺失**
- `/boot/EFI/APPLE/` 下只剩 `LOG/` 与 `CACHES/`, `EMBEDDEDOS/` (固件本体, ~30MB) 已被全盘安装擦除
- 但 Apple EFI 固件层仍在活动: `LOG/BOOT-*.LOG` 在本机安装 Arch 后仍持续写入,
  且日志显示曾成功进入 Apple 网络恢复并连上 `osrecovery.apple.com` — 固件层网络路径通畅

影响 (固件缺失时):
- Touch Bar 黑屏 — 同时失去物理 Esc / F1-F12 / 音量 / 亮度触控键
- FaceTime HD 摄像头、环境光传感器失效
- Touch ID 见下方 "Touch ID" 小节

诊断:

```bash
lsusb | grep 05ac
# 05ac:8600 -> 正常 iBridge, 固件已加载
# 05ac:1281 -> 固件缺失 (recovery 模式)
```

**任何 Linux 驱动程序都无法在 05ac:1281 状态下工作** — 固件是"不存在"而不是"没绑定",
必须先恢复固件本身。

### 恢复途径 (按推荐顺序)

#### 途径 1 (首选): t1-revive — 纯 Linux, 无需 macOS

社区项目 [niconistal/t1-revive](https://github.com/niconistal/t1-revive) 驱动 Apple
官方恢复协议, 让 T1 芯片**直接从 Apple 服务器获取 Apple 签名的固件数据**并写回 ESP,
全程在 Linux 下完成 (原理上等于 Apple Configurator 的 Revive, 但不需要第二台 Mac):

```bash
git clone https://github.com/niconistal/t1-revive ~/t1-revive && cd ~/t1-revive
bash build.sh                    # 构建补丁版 libimobiledevice 工具到 prefix/
sudo bin/t1-revive preflight     # 只读检查 (自动安装 acpi_call-dkms 与 headers)
sudo bin/t1-revive regenerate    # 约 5 分钟, 每个设备操作前会询问
```

条件与注意:
- 需要**接电源**、能访问 Apple 服务器的网络、全程人在键盘前 (会询问确认)
- 前置: 装好 `acpi_call-dkms` + `linux-headers` 且 `modprobe acpi_call` 成功
  (检查 `/proc/acpi/call` 存在); 否则 reset 步骤会 STOPPED — 本机实际踩过此坑,
  修复: `sudo pacman -S acpi_call-dkms linux-headers && sudo modprobe acpi_call`
- 失败续跑: 完全关机, 等 20 秒, 开机后 `sudo bin/t1-revive regenerate --from <step>`
  (本机实测: 未物理关机、直接 `--from reset-1` 也一次跑通 — FRST 复位足够, 关机只是保险)
- 成功后 `lsusb` 显示 `05ac:8600 iBridge`, 且重启持久 (社区实测重启后直接枚举 8600)
- **运行前完整阅读它的 README** — 它会写 T1 芯片

#### 途径 2 (备选): Apple Configurator (需另一台 Mac)

- 辅助 Mac (macOS 10.12+) 安装 Apple Configurator 2, USB-C 数据线连接本机左侧端口
- 本机完全关机 → 进入 DFU → Apple Configurator 中操作 **设备 → 高级 → Revive Bridge OS** (不抹数据)
- ⚠️ DFU 按键组合以 Apple Configurator / 官方当前文档为准 (原 HT208066 文章已下架)
- ⚠️ `Restore Bridge OS` 会擦除整个 SSD — 仅在 Revive 无效且已有备份时使用

#### 途径 3 (备选): 安装一次 macOS

> 仅进入 Recovery 界面 (Cmd+R) 不会写回固件 — **必须完成一次安装**。

- ⚠️ 推荐装到**外置盘** (32GB+ USB3/SSD): 不触碰内置 Arch, 固件仍会写回内置 ESP
  (cschaba 案例证实); 内置盘重装会动 Arch 所在磁盘, 不推荐
- 顺路福利: macOS 就绪后从 `/usr/share/firmware/brcm/` 拷走 `BCM20703A2_*.hcd`
  (蓝牙 patch 固件, 见蓝牙章节)

> 零成本兜底: Apple Store 天才吧可代做 bridgeOS 恢复。

### 恢复成功后: 立即备份 ESP 固件

固件按**芯片个性化签名** (别人的备份无法通用), 且依赖 Apple 持续签发。
恢复成功后第一件事:

```bash
# 方式一: creolben 脚本
~/macbook-t1-touchbar/standalone/t1-touchbar.sh backup-firmware
# 方式二: 手动打包 (ESP 挂在 /boot)
sudo tar -C /boot -czf ~/t1-firmware-backup-$(date +%F).tar.gz EFI/APPLE/EMBEDDEDOS
```

把备份拷到机器之外 (U 盘/另一台电脑)。若 Apple 将来停止签发, 备份是唯一退路。

### 恢复后的 Touch Bar 驱动 (二选一, 互斥)

| 驱动 | Touch Bar | Touch ID | 说明 |
|---|---|---|---|
| [creolben/macbook-t1-touchbar](https://github.com/creolben/macbook-t1-touchbar) | Esc+媒体键, Fn=F1-F12 | ❌ | 轻量: DKMS 三个模块 + 启动服务, 附固件备份/诊断脚本 |
| [standardagents/t1bridge](https://github.com/standardagents/t1bridge) | 自带渲染 | ✅ fprintd | 全量 T1 栈, 指纹支持 sudo/polkit/锁屏 |

creolben 路线:

```bash
git clone https://github.com/creolben/macbook-t1-touchbar ~/macbook-t1-touchbar
cd ~/macbook-t1-touchbar/standalone
./t1-touchbar.sh status              # 只读诊断 (固件/USB/HID/驱动/DKMS)
sudo ./bootstrap-t1-touchbar.sh      # 前置依赖 + 打补丁 + DKMS + 启动服务 + initramfs
./t1-touchbar.sh audit-boot          # 验证重启后能否自启
```

**已知坑** (社区实测, 恢复后设备编号会变化): handover 脚本硬编码了
`0003:05AC:8600.0001`, 恢复后实际是 `.0002/.0003`, 导致脚本报 "T1 not ready" 且
Touch Bar 保持黑屏。修复: 编辑 `/usr/local/sbin/apple-touchbar-handover`, 将
`if [[ ! -e /sys/bus/hid/devices/0003:${VIDPID}.0001 ]]; then` 改为 `if [[ ! -e $1 ]]; then`。

参考: [seatrips/macbook-pro-t1-touchbar-linux](https://github.com/seatrips/macbook-pro-t1-touchbar-linux)
(MacBookPro13,3/14,3 端到端记录, 含 Hyprland 键鼠配置合集)。

### Touch ID

- 旧结论 "T1 Touch ID 无 Linux 支持" 已**过时**: [t1bridge](https://github.com/standardagents/t1bridge)
  通过 fprintd 提供指纹支持 (sudo / polkit / 锁屏)
- creolben 驱动不含 Secure Enclave 代码, 无法使用指纹

## 蓝牙 (BCM20703A2)

### 诊断结论 (本机实测)

- 芯片: **BCM20703A2** (Apple 定制 UART 版), 挂 PCH 的 `dw-apb-uart.2` (ttyS5), **不经过 T1**
  - 即: T1 固件缺失**不影响**蓝牙; 蓝牙修复也不必等 T1 恢复
- 内核 `hci_uart_bcm` 驱动绑定成功, 芯片 ROM 固件 (001.002.109) 应答正常
- 缺 patch 固件: 内核按 `brcm/BCM.hcd` 查找未命中 (linux-firmware 不含 Apple 专用固件)
- 用户空间 bluez 未安装

### 修复步骤 (本机已完成 ✓)

**第一步** (实测足够 — 本机只做了这一步, 蓝牙完全可用):

```bash
sudo pacman -S bluez bluez-utils blueman
sudo systemctl enable --now bluetooth
bluetoothctl power on
bluetoothctl scan on     # 测试能否发现设备
```

本机实测 (2026-10-03): `hci0` 正常上电 (Powered: yes), 15 秒扫描发现 2 个设备,
收发正常。内核日志仍有 `Patch file not found` (brcm/BCM.hcd) 但**无害** —
ROM 固件足够, **不需要**第二步的 patch 固件。

**第二步** (本机未用到; 仅当 hci0 无法 up / 不稳定): 补 patch 固件

- 来源: 任何一台 2016/2017 MBP 的 macOS `/usr/share/firmware/brcm/BCM20703A2_*.hcd`,
  或 GitHub 搜索流传版本 (版权属 Apple/Broadcom, 自行斟酌)
- 放置 (内核日志显示按此名查找):

  ```bash
  sudo cp BCM20703A2*.hcd /usr/lib/firmware/brcm/BCM.hcd
  sudo reboot
  # 验证: journalctl -b | grep hci0  应无 "Patch file not found"
  ```

已知限制与提示:
- A2DP 蓝牙音频可能断续 (上游已知问题, 见 Dunedan/mbp-2016-linux)
- 安全: 避免安装 `bt-agent -c NoInputNoOutput` 类工具 — 它会静默接受一切配对请求,
  附近的人可偷配假键盘; 需要配对时用 `bluetoothctl` / `blueman` 手动确认

### 状态栏菜单 (waybar)

点击 waybar 蓝牙图标 → fuzzel 菜单 (`script/bt-menu.sh`, 与 WiFi 菜单同一交互模式):

- **扫描新设备 (10 秒)**: 完成后自动重开菜单显示新发现设备
- **打开 blueman 管理器**: 图形界面兜底 (复杂配对 / PIN 输入 / 传文件)
- **关闭 / 开启蓝牙**: 按当前状态切换 (关闭会断开所有设备)
- **设备列表**: 已连接 → 点击断开 · 已配对 → 点击连接 · 新设备 → 点击配对+信任+连接
- 操作结果均有 mako 通知; 配对失败可改用 blueman 完成

## WiFi (BCM43602): 缺 NVRAM 校准文件

### 症状与根因 (本机实测)

```bash
ip link show wlp3s0 | grep ether
#   permaddr 00:90:4c:0d:f4:3e   <- Broadcom 占位符 = NVRAM 未加载
iw phy | grep -c Band            # 只有 1 个 (仅 2.4GHz)
```

NVRAM 缺失导致: **无 5GHz、信号极差** ("聋": 扫描看不到几个 AP、传输失败) —
这很可能是本机之前依赖 USB 网卡的原因。

> 注意区分: `link/ether` 是本机随机化 MAC (NetworkManager), `permaddr` 才是芯片真实值 —
> 占位符 `00:90:4c` 开头即确诊。

### 修复 (现成文件 + 替换打码 MAC, 两步)

```bash
curl -LO https://raw.githubusercontent.com/nohzafk/omarchy-macbookpro-t1/main/firmware/brcmfmac43602-pcie.txt
# ⚠️ 关键: 该文件里 macaddr 是发布者打的码 (xx:xx:xx:xx:xx:xx), 必须替换为有效 MAC!
# 用本机蓝牙 MAC 的相邻地址 (保持 Apple OUI): 蓝牙 78:4F:43:A2:9E:99 -> WiFi 用 :98
sed 's/^macaddr=.*/macaddr=78:4F:43:A2:9E:98/' brcmfmac43602-pcie.txt | \
  sudo tee /usr/lib/firmware/brcm/brcmfmac43602-pcie.txt >/dev/null
sudo reboot    # 驱动被 NetworkManager 持有, 无法热重载; 只能重启生效
iw phy | grep Band               # 应出现 Band 2 (5GHz)
```

> ⚠️ **不替换 MAC 会翻车** (本机实测): 无效 MAC 让固件初始化崩溃 —
> `Retrieving cur_etheraddr failed, -5` → `Dongle setup failed` → **接口完全消失** (比修复前更糟)。
> 回退: `sudo rm /usr/lib/firmware/brcm/brcmfmac43602-pcie.txt` + 重载驱动/重启。

本机实测 (2026-10-03): 修复后 `permaddr 78:4f:43:a2:9e:98`, **2 Band (2.4G + 5G)**,
5GHz AP 满信号可见。社区收益 (同款机型): 信号 -74 → -42 dBm, 速率 ~324 Mbps。
文件不属于任何包, 系统更新不会覆盖 (卸载: `sudo rm /usr/lib/firmware/brcm/brcmfmac43602-pcie.txt`)。

补充:
- `no clm_blob available` 报错是红鲱鱼 — 别伪造 clm_blob 文件 (有崩溃报告), 属正常现象
- 5GHz 偏好: NetworkManager 里给 5G 连接设 `autoconnect-priority 10` 即可;
  **不要** pin band/bssid (会失去 2.4GHz 回退, 可能把自己锁在离线状态)

### 状态栏 WiFi 菜单 (waybar)

点击 waybar 网络图标 → fuzzel 菜单 (由 `script/wifi-menu.sh` 提供):
- 顶部两个特殊项: 刷新列表 / 断开当前连接
- 列表按信号排序, 同 SSID 去重; 锁图标 = 加密, 勾图标 = 已连接
- 选择后直连 (已保存的 profile 免密); 新网络弹 fuzzel 密码框; 结果显示为 mako 通知

调试: `~/.config/hypr/script/wifi-menu.sh --list` (无需图形环境, 只打印菜单文本)

## 其他硬件备注

- 音频: Cirrus CS8409; 若扬声器无声, 用 [davidjo/snd_hda_macbookpro](https://github.com/davidjo/snd_hda_macbookpro)
  (DKMS, 支持当前内核; 13,3/14,2/14,3 实测可行 — 内核自带 quirk 只针对 Dell 子系统)
- 风扇: `mbpfan` 已启用 (服务); 社区指出 `applesmc` 读到的 `fan*_manual=0` 表示 SMC
  固件自管风扇, mbpfan 并非必需 (保留现状, 不冲突)
- 休眠: 仅 suspend (S3); 不使用 hibernate
- 双显卡: Intel HD530 + AMD Polaris, Hyprland 自动选择主 GPU
- 挂起恢复: 社区提示恢复需按键唤醒 (~15s, 单独开盖不会完成唤醒);
  Thunderbolt xHCI 复位问题可用内核参数 `pcie_ports=compat` (本项目暂未配置)
- 参考仓库: [Dunedan/mbp-2016-linux](https://github.com/Dunedan/mbp-2016-linux) (机型状态总表),
  [nohzafk/omarchy-macbookpro-t1](https://github.com/nohzafk/omarchy-macbookpro-t1) (Omarchy 全套笔记),
  [seatrips/macbook-pro-t1-touchbar-linux](https://github.com/seatrips/macbook-pro-t1-touchbar-linux) (T1 恢复+Touch Bar 端到端)
