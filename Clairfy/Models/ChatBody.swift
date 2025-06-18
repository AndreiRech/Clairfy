import UIKit

struct ChatBody: Encodable {
    let model: String
    let messages: [ChatMessage]
    let temperature: Double
}
