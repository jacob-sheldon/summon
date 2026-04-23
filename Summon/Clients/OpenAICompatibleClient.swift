import Foundation

struct ChatRequestMessage: Codable {
    let role: String
    let content: String
}

struct OpenAIRequest: Codable {
    let model: String
    let messages: [ChatRequestMessage]
    let stream: Bool
}

final class OpenAICompatibleClient {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func chat(
        endpoint: EndpointConfig,
        messages: [ChatMessage]
    ) -> AsyncStream<String> {
        AsyncStream { continuation in
            Task {
                do {
                    let request = OpenAIRequest(
                        model: endpoint.model,
                        messages: messages.map { ChatRequestMessage(role: $0.role.rawValue, content: $0.content) },
                        stream: true
                    )

                    var urlRequest = URLRequest(url: URL(string: endpoint.baseURL.appending("/chat/completions"))!)
                    urlRequest.httpMethod = "POST"
                    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    urlRequest.setValue("Bearer \(endpoint.apiKey)", forHTTPHeaderField: "Authorization")
                    urlRequest.httpBody = try JSONEncoder().encode(request)

                    let (bytes, response) = try await session.bytes(for: urlRequest)

                    guard let httpResponse = response as? HTTPURLResponse,
                          (200...299).contains(httpResponse.statusCode) else {
                        continuation.finish()
                        return
                    }

                    var buffer = ""
                    for try await line in bytes.lines {
                        buffer += line
                        buffer += "\n"

                        while let newlineIndex = buffer.firstIndex(of: "\n") {
                            let completeLine = String(buffer[..<newlineIndex])
                            buffer = String(buffer[buffer.index(after: newlineIndex)...])
                            processSSELine(completeLine, continuation: continuation)
                        }
                    }

                    // Process remaining buffer
                    if !buffer.isEmpty {
                        processSSELine(buffer.trimmingCharacters(in: .whitespacesAndNewlines), continuation: continuation)
                    }

                    continuation.finish()
                } catch {
                    continuation.yield("[Error: \(error.localizedDescription)]")
                    continuation.finish()
                }
            }
        }
    }

    private func processSSELine(_ line: String, continuation: AsyncStream<String>.Continuation) {
        guard line.hasPrefix("data: ") else { return }
        let data = String(line.dropFirst(6))
        guard data != "[DONE]" else { return }

        guard let jsonData = data.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let first = choices.first,
              let delta = first["delta"] as? [String: Any],
              let content = delta["content"] as? String else {
            return
        }

        continuation.yield(content)
    }
}
