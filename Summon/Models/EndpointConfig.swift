import Foundation

struct EndpointConfig: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let baseURL: String
    let apiKey: String
    let model: String
    let isOfficial: Bool

    enum CodingKeys: String, CodingKey {
        case id, name, baseURL = "base_url", apiKey = "api_key", model, isOfficial = "is_official"
    }

    static let defaultOpenAI = EndpointConfig(
        id: "openai",
        name: "OpenAI",
        baseURL: "https://api.openai.com/v1",
        apiKey: "",
        model: "gpt-4o",
        isOfficial: true
    )
}
