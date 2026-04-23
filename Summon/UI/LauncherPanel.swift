import AppKit
import SwiftUI

final class LauncherPanel: NSPanel {
    static let shared = LauncherPanel()

    private var chatView: ChatView?

    private init() {
        let screenFrame = NSScreen.main?.visibleFrame ?? .zero
        let width: CGFloat = 640
        let height: CGFloat = 420
        let x = (screenFrame.width - width) / 2 + screenFrame.origin.x
        let y = (screenFrame.height - height) * 0.65 + screenFrame.origin.y

        super.init(
            contentRect: NSRect(x: x, y: y, width: width, height: height),
            styleMask: [.titled, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        isMovableByWindowBackground = true
        collectionBehavior = [.transient, .ignoresCycle]
        isFloatingPanel = true
        level = .floating
        backgroundColor = NSColor.windowBackgroundColor.withAlphaComponent(0.95)
        isOpaque = false
        hasShadow = true
        animationBehavior = .utilityWindow
    }

    func setContent<Content: View>(_ view: Content) {
        if let chatView = view as? ChatView {
            self.chatView = chatView
        }
        let hosting = NSHostingView(rootView: view)
        contentView = hosting
    }

    func show() {
        makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func hide() {
        orderOut(nil)
    }

    func toggle() {
        if isVisible {
            hide()
        } else {
            show()
        }
    }

    func setSelectedText(_ text: String) {
        chatView?.setSelectedText(text)
    }
}
