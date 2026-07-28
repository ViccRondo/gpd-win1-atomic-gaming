# GPD Win 1 Atomic Gaming

面向第一代 GPD Win 的社区游戏系统适配：在 Fedora Kinoite 上提供横屏
Steam Gamepad UI、手柄优先启动、Decky、硬件音量键、亮度控制和睡眠修正。

本项目在一台 Atom x7-Z8700、4 GB 内存、64 GB eMMC、原生竖屏
720×1280 DSI 面板的 GPD Win 1 上进行了实机调试。它不是 SteamOS，也不是
GPD、Valve、Fedora、Universal Blue 或 Bazzite 的官方项目。

> **当前推荐安装方式是：先安装官方 Fedora Kinoite，再运行本仓库脚本。**
> 仓库中的 OCI/ISO 构建仍属实验性，尚未完成干净安装验收。安装前请备份
> 全部数据，并准备 Fedora 恢复 U 盘。

## 当前体验

已经在实机确认：

- 开机自动进入横屏 Steam Gamepad UI；
- 手柄、键盘、鼠标、声音和 GPD 音量按键可用；
- 按 `F11` 可在游戏内调出 Steam/Decky 侧边栏；
- Win1 Decky 插件可调亮度并控制 MangoHud 性能信息；
- 电量和部分 CPU 温度可显示；
- Steam 菜单中的关机、重启可传递到系统；
- 电源键和盒盖睡眠包含针对 Win 1 固件行为的保护逻辑；
- Proton 7 可用于部分只支持 Vulkan 1.2 的游戏。

仍需接受的限制：

- 长时间或多次睡眠后，Cherryview i915 仍可能黑屏或整机卡死；
- 这台 GPU 只提供 Vulkan 1.2，很多要求 Vulkan 1.3 的新游戏无法正常运行；
- 直接 KWin 比嵌套 Gamescope 更流畅，但不具备 SteamOS 原生的全部合成器能力；
- 原生 SteamOS 性能面板不可用，使用本项目的 Decky + MangoHud 替代；
- HLTB for Deck `v2.0.9` 在测试机上可复现延迟数分钟后的整机冻结，**不要安装**；
- 64 GB 存储非常紧张，不建议同时保留多个不用的 Proton 和大型游戏。

详见 [已知问题](docs/known-issues.md)。

## 安装前准备

你需要：

1. 第一代 GPD Win（不是 Win 2、Win Max 或后续型号）；
2. 一个至少 8 GB 的 U 盘和完整数据备份；
3. 可用网络；
4. 外接键盘会让首次安装和故障恢复更方便；
5. 一台可制作 Fedora 安装盘的电脑。

下载官方 [Fedora Kinoite](https://fedoraproject.org/atomic-desktops/kinoite/download/)，
使用 Fedora Media Writer 制作启动 U 盘。通过机器固件的启动菜单选择 U 盘，
安装 Kinoite。不同批次固件的启动热键可能不同，本项目不假定固定按键。

安装 Fedora 会覆盖目标磁盘。开始分区前，再次确认目标确实是 Win 1 的内部
64 GB eMMC，而不是装有其他数据的外接磁盘。

## 详细安装步骤

### 1. 完成 Kinoite 初始设置

进入桌面、连接 Wi-Fi，打开 Konsole：

```bash
sudo rpm-ostree upgrade
sudo systemctl reboot
```

重启后安装 Git（如果系统还没有）：

```bash
sudo rpm-ostree install git
sudo systemctl reboot
```

### 2. 下载并检查本项目

```bash
git clone https://github.com/ViccRondo/gpd-win1-atomic-gaming.git
cd gpd-win1-atomic-gaming
./scripts/hardware-check.sh
```

首次运行硬件检查时，Steam 尚未安装导致一项失败是正常的；DSI-1、Intel
Graphics、KWin、音量 GPIO 和电池设备应该能够被识别。请先阅读脚本，再安装：

```bash
less scripts/install.sh
sudo ./scripts/install.sh --user "$USER"
sudo systemctl reboot
```

安装器会：

- 安装用户级 Flatpak Steam 和 MangoHud Vulkan Layer；
- 添加 `GPD Win 1 Gaming Mode` Wayland 会话并默认自动登录；
- 让 KWin 直接管理旋转后的内屏，再启动 Steam Gamepad UI；
- 安装音量键、F11 侧边栏、关机/重启和盒盖睡眠辅助服务；
- 添加 `reboot=pci` 与 `i915.disable_power_well=0` 内核参数；
- 仅给亮度和电源两个经过参数校验的辅助程序设置免密 sudo。

安装器不会复制 Steam、Wi-Fi 或 SSH 凭据，也不会给用户开放通用免密 sudo。
若不希望自动登录，改用：

```bash
sudo ./scripts/install.sh --user "$USER" --no-autologin
```

### 3. 首次进入 Steam

重启后应自动进入横屏 Steam 界面。首次加载 Web UI 在 Atom CPU 上可能需要
较长时间。完成 Steam 登录，然后在“设置 → 兼容性”中按游戏选择 Proton。

建议先以 Proton 7 测试旧游戏。不要把 Proton 7 理解为所有游戏都能运行：
游戏本身、DXVK 版本和 Vulkan 扩展要求仍可能超过 Cherryview 的能力。

### 4. 安装 Decky Loader

只使用 Decky 官方安装器。下载
[SteamDeckHomebrew/decky-installer](https://github.com/SteamDeckHomebrew/decky-installer)
的当前版本，先阅读其脚本，再按上游说明安装。Decky 会以系统服务运行，属于
高权限第三方组件，请不要从不明镜像下载。

Decky 安装完成后，回到本仓库执行：

```bash
./scripts/install-decky-plugin.sh
```

重新打开 Steam 侧边栏，在 Decky 中应看到“Win1 性能面板”。它负责：

- 将 Steam 亮度滑块接到 Win 1 的内核背光设备；
- 切换 MangoHud 性能信息级别；
- 显示电池百分比和可获取的温度数据。

不要连续重启 Decky/Steam WebHelper；在 4 GB 机器上这会造成明显内存压力。
已安装 HLTB for Deck `v2.0.9` 的用户，应先按
[恢复文档](docs/recovery.md#decky-插件导致卡死)将其隔离。

## 日常操作

- `F11`：将 Steam/Decky 快捷侧边栏置于当前游戏之上；
- GPD 音量 `+/-`：控制 PipeWire 系统音量；
- Steam 电源菜单：睡眠、关机或重启；
- 亮度：使用 Steam 快捷设置中的亮度滑块；
- 维护桌面：退出自动登录，或从登录界面选择正常 Plasma 会话。

由于没有嵌套 Gamescope，F11 的覆盖效果由 KWin 窗口聚焦辅助实现；它接近
SteamOS 的使用方式，但不是 SteamOS 原生 overlay plane。

## 可选：i915 黑屏看门狗

只有在你理解风险后才启用：

```bash
sudo ./scripts/install.sh --user "$USER" --enable-i915-watchdog
```

它在日志检测到特定 i915/DSI 超时后保存内核和显示寄存器快照，再强制重启
机器。诊断记录保存在 `/var/lib/win1-i915-diagnostics`。看门狗可能避免永久
黑屏，但会让未保存的数据丢失；它不能修复 GPU 驱动，也不能保证游戏状态在
睡眠后恢复。

针对已经复现的 Cherryview DSI pipe B 唤醒故障，项目提供了一个可回滚的
[测试内核补丁和验证流程](docs/kernel-resume-test.md)。它目前仍是实验修复，
必须通过实机多轮睡眠测试后才能写入正式镜像。

## 验证安装

```bash
./scripts/hardware-check.sh
systemctl --no-pager --full status \
  win1-lid-event-guard \
  win1-volume-keys \
  win1-decky-hotkey
rpm-ostree kargs
```

还应在实机完成 [硬件验收清单](docs/testing.md)。日志或进程存在并不等于显示、
睡眠和手柄体验已经通过。

## 卸载和恢复

从正常 Plasma 会话或 SSH 运行：

```bash
cd gpd-win1-atomic-gaming
sudo ./scripts/uninstall.sh
sudo systemctl reboot
```

卸载脚本保留 Steam 游戏、账号和用户数据。它也会保留内核参数，手动移除方法
以及黑屏、Decky 卡死处理见 [恢复文档](docs/recovery.md)。

## OCI 镜像和安装 ISO

主分支工作流可构建并签名：

```text
ghcr.io/viccrondo/gpd-win1-atomic-gaming:latest
```

发布工作流也能生成 raw、qcow2 或 Anaconda ISO，并为拆分文件生成 SHA-256。
这些产物用于开发和验收，不是当前推荐安装方式。旧 `v0.1.0` 产物仍基于之前
的嵌套 Gamescope 架构，不能代表本文档所述的当前实机配置。

> Anaconda ISO 可能自动重分区它发现的第一块磁盘。只有在已备份的 Win 1 或
> 专用测试机上使用，并断开其他磁盘。镜像通过构建/签名不等于通过实机安装。

详见 [架构说明](docs/architecture.md)、[测试清单](docs/testing.md)和
[恢复文档](docs/recovery.md)。

## 参与贡献

欢迎提交可复现日志、具体游戏兼容性、睡眠循环结果和小型上游修复。优先方向：

- Cherryview i915/DSI 睡眠恢复；
- MangoHud 对 `max170xx_battery` 的上游支持；
- 低内存条件下的 Steam/Decky 稳定性；
- Vulkan 1.2 设备的 Proton 兼容性记录；
- 在不牺牲旋转和流畅度的情况下改善 Gamescope 支持。

提交问题时请附上系统版本、内核、Decky/插件版本、游戏、Proton 版本和相关日志，
但不要上传 Steam 登录信息、Wi-Fi 密码或 SSH 私钥。

本项目使用 Apache-2.0 许可证。第三方软件继续遵循各自许可证和商标规则。
