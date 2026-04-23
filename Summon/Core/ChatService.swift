import Foundation

@Observable
final class ChatService {
    private let client: OpenAICompatibleClient
    private let endpointManager: EndpointManager
    private let chatStore: ChatStore

    var isStreaming = false
    var currentResponse = ""
    var messages: [ChatMessage] { chatStore.messages }

    init(client: OpenAICompatibleClient = OpenAICompatibleClient(), endpointManager: EndpointManager, chatStore: ChatStore) {
        self.client = client
        self.endpointManager = endpointManager
        self.chatStore = chatStore
    }

    func sendMessage(_ content: String, selectedText: String? = nil) async {
        guard let endpoint = endpointManager.selectedEndpoint else { return }

        var fullContent = content
        if let selectedText = selectedText, !selectedText.isEmpty {
            fullContent = "Selected text: \"\(selectedText)\"\n\n\(content)"
        }

        let userMessage = ChatMessage(role: .user, content: fullContent)
        chatStore.append(userMessage)

        isStreaming = true
        currentResponse = ""

        let messages = chatStore.messages
        let stream = client.chat(endpoint: endpoint, messages: messages)

        for await token in stream {
            currentResponse += token
        }

        isStreaming = false

        if !currentResponse.isEmpty {
            let assistantMessage = ChatMessage(role: .assistant, content: currentResponse)
            chatStore.append(assistantMessage)
        }
    }

    var promptTemplates: [String: String] {
        [
            "/translate": "Translate the following to English: ",
            "/summarize": "Summarize the following: ",
            "/fix": "Fix any issues in the following: ",
        ]
    }

    func expandTemplate(_ prefix: String) -> String? {
        promptTemplates[prefix]
    }
}
