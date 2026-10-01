import AppKit
import Carbon.HIToolbox

/// Keep Command held so macOS owns the running-app list and the selection UI.
final class NativeAppSwitcher {
    private var heldCommand: KeyMap.Combo?
    var isOpen: Bool { heldCommand != nil }

    func open() {
        guard !isOpen else { return }
        heldCommand = Keys.holdBegin("cmd")
        postKey(CGKeyCode(kVK_Tab))
        rmDebug("🔀 app switcher opened")
    }

    func handle(button: String) {
        switch button {
        case "ringLeft", "ringUp":
            postKey(CGKeyCode(kVK_Tab), flags: [.maskCommand, .maskShift])
            rmDebug("🔀 app switcher previous")
        case "ringRight", "ringDown":
            postKey(CGKeyCode(kVK_Tab))
            rmDebug("🔀 app switcher next")
        case "select":
            releaseCommand()
            rmDebug("🔀 app switcher confirmed")
        default: cancel()
        }
    }

    func cancel() {
        guard isOpen else { return }
        postKey(CGKeyCode(kVK_Escape))
        releaseCommand()
        rmDebug("🔀 app switcher cancelled")
    }

    private func postKey(_ key: CGKeyCode, flags: CGEventFlags = .maskCommand) {
        let source = CGEventSource(stateID: .combinedSessionState)
        for down in [true, false] {
            let event = CGEvent(keyboardEventSource: source, virtualKey: key, keyDown: down)
            event?.flags = flags
            event?.post(tap: .cghidEventTap)
        }
    }

    private func releaseCommand() {
        if let heldCommand { Keys.holdEnd(heldCommand) }
        heldCommand = nil
    }
}
