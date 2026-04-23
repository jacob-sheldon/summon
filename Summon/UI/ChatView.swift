import SwiftUI

struct ChatView: View {
    @Bindable var chatService: ChatService
    @Bindable var endpointManager: EndpointManager
    @Bindable var settingsStore: SettingsStore

    @State private var inputText = ""
    @State private var selectedText: String?

    var body: some View {
        VStack(spacing: 0) {
            EndpointPickerView(
                endpointManager: endpointManager,
                settingsStore: settingsStore
            )

            Divider().padding(.vertical, 8)

            // Messages area
            if chatService.messages.isEmpty && chatService.currentResponse.isEmpty {
                placeholderView
            } else {
                messageListView
            }

            Divider()

            // Input area
            inputAreaView
        }
        .frame(minWidth: 500, minHeight: 350)
        .background(Color(NSColor.windowBackgroundColor))
    }

    private var placeholderView: some View {
        VStack(spacing: 12) {
            Image(systemName: "command.square")
                .font(.system(size: 40))
                .foregroundStyle(.secondary.opacity(0.5))
            Text("Type a message or use /translate, /summarize, /fix")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var messageListView: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 12) {
                ForEach(chatService.messages) { message in
                    messageBubble(for: message)
                }

                if !chatService.currentResponse.isEmpty {
                    messageBubble(
                        for: ChatMessage(role: .assistant, content: chatService.currentResponse)
                    )
                }
            }
            .padding()
        }
    }

    private func messageBubble(for message: ChatMessage) -> some View {
        HStack {
            if message.role == .user {
                Spacer()
            }
            Text(message.content)
                .padding(8)
                .background(message.role == .user ? Color.accentColor.opacity(0.15) : Color.secondary.opacity(0.1))
                .cornerRadius(8)
                .textSelection(.enabled)
                .frame(maxWidth: message.role == .user ? 400 : .infinity, alignment: message.role == .user ? .trailing : .leading)
            if message.role != .user {
                Spacer()
            }
        }
    }

    private var inputAreaView: some View {
        HStack(spacing: 8) {
            TextEditor(text: $inputText)
                .frame(minHeight: 40, maxHeight: 120)
                .padding(4)
                .background(Color(NSColor.textBackgroundColor))
                .cornerRadius(6)
                .onSubmit {
                    if !inputText.isEmpty {
                        send()
                    }
                }

            Button(action: send) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
            }
            .buttonStyle(.plain)
            .disabled(inputText.isEmpty || chatService.isStreaming)
        }
        .padding(8)
    }

    private func send() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        inputText = ""

        // Check for prompt templates
        let prefix = text.components(separatedBy: " ").first ?? ""
        if let expanded = chatService.expandTemplate(prefix) {
            let remaining = text.dropFirst(prefix.count).trimmingCharacters(in: .whitespaces)
            Task {
                await chatService.sendMessage(expanded + remaining, selectedText: selectedText)
            }
        } else {
            Task {
                await chatService.sendMessage(text, selectedText: selectedText)
            }
        }
    }

    func setSelectedText(_ text: String?) {
        selectedText = text
    }
}
