import AppKit

// Accessory + nonactivating panel: confirmation never takes the dictation input's focus.
@main
enum VoiceEngineHUD {
    static func main() {
        let engine = CommandLine.arguments[1]
        let name: String
        switch engine {
        case "vocotype": name = "VocoType"
        case "wetype": name = "微信"
        default: fatalError("Unknown voice engine: \(engine)")
        }

        let app = NSApplication.shared
        app.setActivationPolicy(.accessory)
        let size = NSSize(width: 360, height: 130)
        let panel = NSPanel(contentRect: NSRect(origin: .zero, size: size),
                            styleMask: [.borderless, .nonactivatingPanel],
                            backing: .buffered, defer: false)
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.ignoresMouseEvents = true
        panel.hidesOnDeactivate = false
        panel.level = .screenSaver
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .ignoresCycle]

        let card = NSVisualEffectView(frame: NSRect(origin: .zero, size: size))
        card.material = .hudWindow
        card.state = .active
        card.wantsLayer = true
        card.layer?.cornerRadius = 24
        card.layer?.masksToBounds = true
        let title = NSTextField(labelWithString: "已切换到\(name)")
        title.font = .systemFont(ofSize: 26, weight: .semibold)
        title.alignment = .center
        title.frame = NSRect(x: 12, y: 68, width: 336, height: 34)
        card.addSubview(title)
        let subtitle = NSTextField(labelWithString: "Siri 遥控器语音输入")
        subtitle.font = .systemFont(ofSize: 15)
        subtitle.textColor = .secondaryLabelColor
        subtitle.alignment = .center
        subtitle.frame = NSRect(x: 12, y: 32, width: 336, height: 22)
        card.addSubview(subtitle)
        panel.contentView = card
        panel.center()
        panel.orderFrontRegardless()
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in app.terminate(nil) }
        app.run()
    }
}
