# A2854 在 VocoType 与微信输入法之间切换

单独长按 Siri 会切到 Codex，并用当前选中的语音输入方案转写；短按删除光标前一个词。在其他应用先按住 TV、再按住 Siri 说话，文字进入当前应用的输入框；先松 Siri 停止，再松 TV。TV 单击发送、双击中断的原有动作保留。在 Codex 中按住 Play/Pause 至少 0.5 秒再松开，切换 VocoType 与微信输入法；Play/Pause 短按仍显示或隐藏边栏。返回键和圆盘映射相同。

两套方案都使用系统音频设备 `Siri Remote Mic`。先按 [A2854 遥控器麦克风配置](A2854-vocotype-setup.md)装好 HyperVibe、HAL、采集服务与 VocoType。

微信模式使用 HyperVibe 的 `holdToTalk` 动作。安装本仓库当前版本的 HyperVibe 后再启用下面的配置；更换应用构建后，在 macOS「输入监控」和「设备控制和数据访问」中重新授权 HyperVibe，并重启应用。

## 微信输入法设置

1. 安装并启用微信输入法的 macOS 输入源；本机验证版本为 2.2.3。
2. 在「系统设置 → 隐私与安全性 → 设备控制和数据访问」中，给微信输入法开启辅助功能权限。回到微信输入法的「语音输入」设置，启用「启动语音输入」；键盘备用热键可保留 **Fn+空格**，「按住说话」保留 Fn。
3. 将该页底部「麦克风」选为 **Siri Remote Mic**。VocoType 也继续使用这个输入设备，其 **Backslash** 热键不变。

微信输入法模式中，HyperVibe 在 Siri 长按时按住 Fn，松开 Siri 时释放 Fn，调用微信输入法的「按住说话」。VocoType 模式在 Siri 长按的开始和结束时各发送一次 Backslash。一次 Siri 长按只触发选中的方案。TV+Siri 使用同一语音方案，但保留当前应用前台和当前输入焦点；遥控器真实麦克风仍需要按住实体 Siri 键。

## 安装切换配置

在仓库根目录执行：

```sh
mkdir -p ~/.config/siriremote
cp ~/.config/siriremote/config.jsonc ~/.config/siriremote/config.before-dual-voice.jsonc
cp examples/codex-remote-vocotype.jsonc ~/.config/siriremote/config-vocotype.jsonc
cp examples/codex-remote-wetype.jsonc ~/.config/siriremote/config-wetype.jsonc
install -m 755 scripts/toggle-voice-engine.sh ~/.config/siriremote/toggle-voice-engine.sh
zsh scripts/build-voice-engine-hud.sh
printf 'vocotype\n' > ~/.config/siriremote/voice-engine
cp ~/.config/siriremote/config-vocotype.jsonc ~/.config/siriremote/config.jsonc
```

HyperVibe 会热加载 `config.jsonc`。Play/Pause 长按切换只在 Codex 前台生效，其他应用的播放控制保持原样。按住时显示目标方案，松开后屏幕中央显示「已切换到微信」或「已切换到 VocoType」2 秒；提示不抢输入焦点，不依赖 macOS 通知权限。提示程序单独构建，无需更换 HyperVibe 的签名或权限。当前方案也可用 `cat ~/.config/siriremote/voice-engine` 查看。

两份配置设置 `holdCancelGrace: 0`，因此按住至少 0.5 秒后松开即可切换，没有最长按住时间。原先默认的 1 秒取消宽限会让超过 1.5 秒的长按变成取消。当前两份配置只有 Play/Pause 和返回键使用分阶段长按；Siri 语音、TV 组合键和其他映射保持原样。日后修改共享键位和圆盘参数时，要同步修改两个配置文件。

## 实机验收

1. 在 VocoType 模式，分别在 Codex 主聊天和侧边聊天按住 Siri 说话，确认 VocoType 转写落在当前输入框。
2. 在 Codex 按住 Play/Pause 至少 0.5 秒并松开；确认 `voice-engine` 为 `wetype`。
3. 再次按住 Siri 说话，确认微信输入法的语音窗口出现、松开后文字落在当前输入框。
4. Siri 短按删除词、Play/Pause 短按切换边栏。再次长按 Play/Pause，确认回到 `vocotype` 并复测 Siri 长按。
5. 在其他应用点入输入框，按住 TV 再长按 Siri 说话，确认文字落在该应用且没有切回 Codex。分别在两种语音模式验收；再单独长按 Siri，确认原有切回 Codex 的动作仍有效。

## 返回键 App 选择器

两种语音模式都支持以下操作，Codex 和其他应用中均可使用：

- 短按返回键：在 Codex 与上一个 App 之间往返。
- 按住返回键至少 0.5 秒后松开：打开 macOS 原生 ⌘Tab 选择器，列出正在运行的 App。
- 方向环左／右：选择上一个／下一个 App（上／下也可用）。
- 中心键：确认选择，切换到该 App。
- 返回键或其他功能键：取消选择，保留原 App。

选择器打开期间，方向环和中心键只操作选择器；关闭后恢复原来的导航、点击和语音功能。遥控器断开、配置重载或 HyperVibe 退出时会取消选择器并释放 Command。

### 2026-10-02 本机实施状态

- 已构建并安装新版 `/Applications/HyperVibe.app`，两份本机配置均加入返回键长按选择器；保留当前 `wetype` 模式。
- HyperVibe 构建、仓库的软件验证脚本、两份配置的解析与序列化检查通过。检查确认 0.5 秒以上长按不再因取消宽限而失效。
- 更换临时签名后，旧权限开关虽开启，启动日志仍拒绝访问。仅重置 `com.hypervibe.app` 的 ListenEvent 和 Accessibility，并重新添加最终安装路径。修复版重启后，日志确认 `Input Monitoring access: granted`、`IOHIDManagerOpen success`、`MediaKeyInterceptor: event tap installed and enabled`，权限已恢复。
- 首次实体测试确认选择器出现，但方向环左右不能改变选中项；日志确认按键已收到。已将选择器内的方向键事件改为保持 Command 的 Tab／Shift+Tab，并重新构建、安装。
- **实机验收未完成**：左右选择的修复效果、中心确认、取消、短按往返、新中央语音切换提示和其他功能回归，仍需逐项确认。
- 安装前的应用与配置备份在 `~/.config/siriremote/backups/2026-10-02-before-app-switcher/`；此前语音提示改动的配置备份在 `~/.config/siriremote/backups/2026-10-02-voice-switch-feedback/`。
