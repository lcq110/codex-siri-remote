# A2854 遥控器麦克风与 VocoType：另一台 Mac 配置

这份记录来自一台 Apple Silicon Mac 的实机配置。第三代 Siri Remote（A2854，USB-C）负责触控、按键和语音采集；HyperVibe 将语音送到系统输入设备 `Siri Remote Mic`，VocoType 再把文字写入 Codex 输入框。

源码和配置已在本仓库：[`examples/codex-remote-vocotype.jsonc`](../examples/codex-remote-vocotype.jsonc) 包含当前键位及圆盘速度曲线。基础 `codex-remote-v1.jsonc` 使用 Fn 听写，两种配置择一安装。

## 蓝牙配对与两台 Mac 切换

遥控器一次只向当前连接的主机传送按键和语音。它在 macOS 蓝牙列表中属于 HID 设备，**不会直接出现在声音输入列表**；`Siri Remote Mic` 是另行安装的虚拟音频设备。按键正常而麦克风静音时，应分别检查蓝牙连接和语音链路。

1. 在当前 Mac 的「系统设置 → 蓝牙」中断开遥控器；保留配对记录，不必关闭整台 Mac 的蓝牙。
2. 在另一台 Mac 打开「系统设置 → 蓝牙」，尝试连接已有的遥控器记录。找不到时，将遥控器靠近 Mac，按住 **返回键（<）＋音量加**约 5 秒进入配对模式，再从 Mac 连接。[Apple 的配对说明](https://support.apple.com/en-us/102569)提供了这组按键；页面以 Apple TV 为目标，这里由 Mac 完成连接。
3. 「附近的设备」可能出现多个 `Bluetooth Device`，不要按列表位置猜。连接前后对比新出现的项目；设备名称也可能是字母数字串。连接后核对：

   ```sh
   system_profiler SPBluetoothDataType | rg -i -C 12 '0x0315|siriremote|你看到的设备名称'
   ```

   目标是同一设备显示 `Connected: Yes`、Apple Vendor ID `0x004C`、Product ID `0x0315`，并且遥控器按键能产生输入。
4. 切回第一台时，先在第二台断开，再在第一台尝试连接；若旧配对记录不能直接重连，就重新进入配对模式。两台 Mac 能否长期保留配对记录尚未实测。

如果 Apple TV 抢先接管遥控器，先让遥控器远离它。遥控器卡住时，按 **TV／控制中心＋音量减**约 5 秒重启后再配对；这不是日常切换步骤。

## 安装顺序

1. 安装 Xcode Command Line Tools，并按上一节连好遥控器。先阅读本仓库的 [`README.md`](../README.md)、[`mic/README.md`](../mic/README.md)、[`dist/README.md`](../dist/README.md)。
2. 从 [Apple Developer](https://developer.apple.com/download/all/?q=Additional+Tools+for+Xcode) 下载官方 *Additional Tools for Xcode* 里的 PacketLogger，将 `PacketLogger.app` 放到 `/Applications/PacketLogger.app`。本机使用 Xcode 26.6 随附版本。
3. 从 [SiriRemoteForge 发布页](https://github.com/HOLODATA-COM/SiriRemoteForge/releases)取得适合当前架构的 **Full Setup** 并按安装器提示部署 HAL、按需采集服务和卸载器。App-only 包不含遥控器麦克风。本仓库的修复还未包含在那个上游安装包中，下面需以本仓库源码更新应用和语音服务。
4. 克隆本仓库并构建应用：

   ```sh
   git clone https://github.com/lcq110/codex-siri-remote.git
   cd codex-siri-remote
   ./tests/run-software-verification.sh
   (cd app && ./build.sh && ./create_app_bundle.sh)
   ```

   用新生成的 `app/HyperVibe.app` 更新 `/Applications/HyperVibe.app`。这版在 Siri 按下时激活 Codex 并聚焦底部输入框；否则语音可能进入前一个应用。
5. 本机 A2854 的语音通知句柄为 `0x0036`；语音解析器现同时接受 `0x0035` 与 `0x0036`。源码构建 router 需要静态 libopus：

   ```sh
   brew install opus
   (cd mic/router && ./build.sh)
   (cd mic/captured && ./build.sh)
   (cd mic/captured && ./install.sh)
   ```

   最后一个脚本需要管理员密码，会更新已有 router 与系统采集服务。执行前可查看 [`mic/captured/install.sh`](../mic/captured/install.sh)。
6. 备份第二台原有的 `~/.config/siriremote/config.jsonc`，再复制本仓库的 [`examples/codex-remote-vocotype.jsonc`](../examples/codex-remote-vocotype.jsonc) 到该路径。它设置：返回键在 Codex 与最近使用的应用间切换；TV 单击发送、双击中断；Siri **短按删除光标前一个词，按住说话**；圆盘慢转细调、快转加速。运行中的 HyperVibe 会热加载配置。
7. 在 VocoType 里选择输入设备 **Siri Remote Mic**，热键设为 **Backslash**，录音模式设为按一次开启、再按一次关闭。HyperVibe 在 Siri 按下和松开时各发一次该键。
8. 在「系统设置 → 隐私与安全性」给最终路径 `/Applications/HyperVibe.app` 开启「输入监控」和「设备控制和数据访问」（部分系统版本称「辅助功能」），允许所需蓝牙权限，然后完全退出并重新打开 HyperVibe。VocoType 还需麦克风权限。

本机重建应用后曾出现旧签名授权失效：设置里的开关显示开启，日志却报 HID 打开失败。确认是旧授权记录后，才对 `com.hypervibe.app` 重置 `ListenEvent` 与 `Accessibility`，重新添加当前应用并重启。新 Mac 首次安装应先直接授权。

## 验收

```sh
system_profiler SPBluetoothDataType
system_profiler SPAudioDataType | rg -A8 'Siri Remote Mic'
tail -f /tmp/hypervibe.log
launchctl print system/au.holodata.SiriRemoteMic.captured
```

日志应出现 `Input Monitoring access: granted`、`IOHIDManagerOpen success` 和 `MediaKeyInterceptor: event tap installed and enabled`。仅看到 `Siri Remote Mic` 名称不能证明有真实音频；本机修复后曾对 751 帧实录全部解码，随后观察到实际输入电平和 VocoType 转写。

按住 Siri 说话、松开后，确认文字落在 Codex 当前输入框且未自动发送；再分别检查 TV 发送和双击中断、返回键往返、圆盘快慢转、Siri 短按删除词。本机已确认语音落点和返回键；最新圆盘曲线与短按删除词仍待实机反馈。
