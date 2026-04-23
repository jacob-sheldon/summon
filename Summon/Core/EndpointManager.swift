import Foundation

@Observable
final class EndpointManager {
    var endpoints: [EndpointConfig]
    var selectedEndpoint: EndpointConfig?

    private let fileURL: URL

    init() {
        let supportDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Summon", isDirectory: true)
        try? FileManager.default.createDirectory(at: supportDir, withIntermediateDirectories: true)
        let url = supportDir.appendingPathComponent("endpoints.json")
        self.fileURL = url

        if let data = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode([EndpointConfig].self, from: data) {
            self.endpoints = decoded
        } else {
            self.endpoints = [EndpointConfig.defaultOpenAI]
        }
        if endpoints.isEmpty {
            endpoints = [EndpointConfig.defaultOpenAI]
        }
        saveEndpoints(endpoints)
    }

    func selectEndpoint(id: String) {
        selectedEndpoint = endpoints.first(where: { $0.id == id })
    }

    func addEndpoint(_ config: EndpointConfig) {
        endpoints.append(config)
        saveEndpoints(endpoints)
    }

    func removeEndpoint(id: String) {
        endpoints.removeAll(where: { $0.id == id })
        saveEndpoints(endpoints)
    }

    private func loadEndpoints() -> [EndpointConfig] {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([EndpointConfig].self, from: data) else {
            return []
        }
        return decoded
    }

    private func saveEndpoints(_ endpoints: [EndpointConfig]) {
        guard let encoded = try? JSONEncoder().encode(endpoints) else { return }
        try? encoded.write(to: fileURL)
    }
}
