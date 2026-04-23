import SwiftUI

struct StreamingTextView: View {
    let text: String
    let isStreaming: Bool

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                Text(text)
                    .textSelection(.enabled)
                    .font(.system(.body, design: .default))
                    .padding()
                    .id("bottom")
            }
            .onChange(of: text) { _, _ in
                proxy.scrollTo("bottom", anchor: .bottom)
            }
        }
        .overlay(alignment: .bottomTrailing) {
            if isStreaming {
                HStack(spacing: 4) {
                    ForEach(0..<3) { i in
                        Circle()
                            .fill(.secondary)
                            .frame(width: 4, height: 4)
                            .opacity(0.3 + Double(i) * 0.3)
                    }
                }
                .padding(8)
            }
        }
    }
}
