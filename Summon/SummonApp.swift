import SwiftUI
import Carbon
import os.log

@main
struct SummonApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra("Summon", systemImage: "lightbulb") {
            Button("Open Launcher") {
                AppDelegate.shared?.showLauncher()
            }
            .keyboardShortcut(KeyEquivalent("l"), modifiers: [.command])
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut(KeyEquivalent("q"), modifiers: [.command])
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    static var shared: AppDelegate?

    private let panel = LauncherPanel.shared
    private let shortcutManager = ShortcutManager()

    var endpointManager: EndpointManager!
    var settingsStore: SettingsStore!
    var chatStore: ChatStore!
    var chatService: ChatService!

    override init() {
        super.init()
        AppDelegate.shared = self
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        settingsStore = SettingsStore()
        endpointManager = EndpointManager()
        chatStore = ChatStore()
        chatService = ChatService(endpointManager: endpointManager, chatStore: chatStore)

        endpointManager.selectEndpoint(id: settingsStore.currentEndpointID)

        let chatView = ChatView(
            chatService: chatService,
            endpointManager: endpointManager,
            settingsStore: settingsStore
        )
        panel.setContent(chatView)

        shortcutManager.onToggle = { [weak self] in
            self?.toggleLauncher()
        }
        shortcutManager.register(keyCode: 49, modifiers: UInt32(cmdKey | shiftKey))
    }

    func showLauncher() {
        panel.show()
    }

    func toggleLauncher() {
        panel.toggle()
        if panel.isVisible {
            if let text = SelectedTextProvider.getSelectedText(), !text.isEmpty {
                panel.setSelectedText(text)
            }
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }
}

enum SelectedTextProvider {
    static func getSelectedText() -> String? {
        let systemWide = AXUIElementCreateSystemWide()
        var focusedApp: AnyObject?
        guard AXUIElementCopyAttributeValue(systemWide, kAXFocusedApplicationAttribute as CFString, &focusedApp) == .success else { return nil }

        var focusedUI: AnyObject?
        guard AXUIElementCopyAttributeValue(focusedApp as! AXUIElement, kAXFocusedUIElementAttribute as CFString, &focusedUI) == .success else { return nil }

        var selectedTextValue: AnyObject?
        guard AXUIElementCopyAttributeValue(focusedUI as! AXUIElement, kAXSelectedTextAttribute as CFString, &selectedTextValue) == .success,
              let text = selectedTextValue as? String else { return nil }

        return text
    }
}
