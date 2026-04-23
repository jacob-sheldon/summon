import Foundation

final class ChatStore {
    private let fileURL: URL

    init() {
        let supportDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Summon", isDirectory: true)
        try? FileManager.default.createDirectory(at: supportDir, withIntermediateDirectories: true)
        self.fileURL = supportDir.appendingPathComponent("chat_history.json")
    }

    var messages: [ChatMessage] {
        get { loadMessages() }
        set { saveMessages(newValue) }
    }

    func append(_ message: ChatMessage) {
        var msgs = loadMessages()
        msgs.append(message)
        saveMessages(msgs)
    }

    func clear() {
        saveMessages([])
    }

    private func loadMessages() -> [ChatMessage] {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([ChatMessage].self, from: data) else {
            return []
        }
        return decoded
    }

    private func saveMessages(_ messages: [ChatMessage]) {
        guard let encoded = try? JSONEncoder().encode(messages) else { return }
        try? encoded.write(to: fileURL)
    }
}
