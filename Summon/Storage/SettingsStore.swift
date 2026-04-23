import Foundation

@Observable
final class SettingsStore {
    var currentEndpointID: String
    var shortcutKey: String
    var windowOpacity: Double

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.currentEndpointID = defaults.string(forKey: "currentEndpointID") ?? "openai"
        self.shortcutKey = defaults.string(forKey: "shortcutKey") ?? "Cmd+Shift+Space"
        self.windowOpacity = defaults.double(forKey: "windowOpacity") != 0 ? defaults.double(forKey: "windowOpacity") : 0.95
    }

    func setCurrentEndpointID(_ id: String) {
        currentEndpointID = id
        defaults.set(id, forKey: "currentEndpointID")
    }

    func setShortcutKey(_ key: String) {
        shortcutKey = key
        defaults.set(key, forKey: "shortcutKey")
    }

    func setWindowOpacity(_ opacity: Double) {
        windowOpacity = opacity
        defaults.set(opacity, forKey: "windowOpacity")
    }
}
