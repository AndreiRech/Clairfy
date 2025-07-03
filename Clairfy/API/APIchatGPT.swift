import Foundation

class APIchatGPT {
    private let secureProvider = SecureData()

    func transcreverAudio(audioFileURL: URL, completion: @escaping (String?) -> Void) {
        secureProvider.fetchAPIKey { [weak self] apiKey in
            guard let apiKey = apiKey else {
                completion(nil)
                return
            }

            let boundary = UUID().uuidString
            let body = self?.createBody(boundary: boundary, audioFileURL: audioFileURL)

            let request = self?.createRequest(
                url: "https://api.openai.com/v1/audio/transcriptions",
                method: "POST",
                headers: [
                    "Authorization": "Bearer \(apiKey)",
                    "Content-Type": "multipart/form-data; boundary=\(boundary)"
                ],
                body: body
            )

            if let request = request {
                self?.sendRequest(request: request) { json in
                    completion(json?["text"] as? String)
                }
            } else {
                completion(nil)
            }
        }
    }

    func resumirTexto(_ text: String, category: String, completion: @escaping (String?) -> Void) {
        secureProvider.fetchAPIKey { [weak self] apiKey in
            guard let apiKey = apiKey else {
                completion(nil)
                return
            }

            self?.secureProvider.fetchPrompts { prompts in
                guard let promptDict = prompts?.first(where: { $0["category"] as? String == category }), let prompt = promptDict["prompt"] as? String else {
                        completion(nil)
                        return
                }

                let jsonBody = self?.createJsonBody(text: text, prompt: prompt)
                let request = self?.createRequest(
                    url: "https://api.openai.com/v1/chat/completions",
                    method: "POST",
                    headers: [
                        "Authorization": "Bearer \(apiKey)",
                        "Content-Type": "application/json"
                    ],
                    jsonBody: jsonBody
                )

                if let request = request {
                    self?.sendRequest(request: request) { json in
                        let content = ((json?["choices"] as? [[String: Any]])?.first?["message"] as? [String: Any])?["content"] as? String
                        completion(content)
                    }
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    private func createBody(boundary: String, audioFileURL: URL) -> Data {
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"audio.m4a\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: audio/m4a\r\n\r\n".data(using: .utf8)!)
        body.append(try! Data(contentsOf: audioFileURL))
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"model\"\r\n\r\n".data(using: .utf8)!)
        body.append("whisper-1\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        return body
    }
    
    private func createJsonBody(text: String, prompt: String) -> [String: Any] {
        let jsonBody: [String: Any] = [
            "model": "gpt-4.1-mini-2025-04-14",
            "messages": [
                ["role": "system", "content": prompt],
                ["role": "user", "content": text]
            ],
            "temperature": 0.1
        ]
        
        return jsonBody
    }
    
    private func createRequest(url: String, method: String, headers: [String: String], body: Data? = nil, jsonBody: [String: Any]? = nil) -> URLRequest {
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = method
        request.timeoutInterval = 120
        
        headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        if let body = body {
            request.httpBody = body
        } else if let jsonBody = jsonBody {
            request.httpBody = try? JSONSerialization.data(withJSONObject: jsonBody)
        }
        
        return request
    }
    
    private func sendRequest(request: URLRequest, completion: @escaping ([String: Any]?) -> Void) {
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                completion(nil)
                return
            }
            completion(json)
        }.resume()
    }
}
