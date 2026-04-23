import Carbon
import Foundation
import os.log

@Observable
final class ShortcutManager {
    private var hotKeyRef: EventHotKeyRef?

    var onToggle: (() -> Void)?

    private static var sharedManager: ShortcutManager?

    deinit {
        unregister()
    }

    func register(keyCode: UInt32, modifiers: UInt32) {
        unregister()

        ShortcutManager.sharedManager = self

        var hotKeyID = EventHotKeyID()
        hotKeyID.signature = 1397578836
        hotKeyID.id = 1

        let status = RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            GetEventMonitorTarget(),
            0,
            &hotKeyRef
        )

        guard status == noErr else {
            os_log("Failed to register hotkey: %d", type: .error, status)
            return
        }

        let handler: EventHandlerUPP = { _, _, _ in
            DispatchQueue.main.async {
                ShortcutManager.sharedManager?.onToggle?()
            }
            return noErr
        }

        var spec = EventTypeSpec()
        spec.eventClass = OSType(kEventClassKeyboard)
        spec.eventKind = OSType(kEventHotKeyPressed)
        InstallEventHandler(GetEventMonitorTarget(), handler, 1, &spec, nil, nil)
    }

    func unregister() {
        if let hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }
        ShortcutManager.sharedManager = nil
    }
}
