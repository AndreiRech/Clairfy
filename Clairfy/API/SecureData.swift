import Foundation

class SecureData {
    private let baseURL = "https://clairfy-backend.onrender.com/secrets"
    private let accessToken = "I-Love-Bergamota-123"

    func fetchAPIKey(completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "\(baseURL)/api-key") else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(accessToken, forHTTPHeaderField: "x-token")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Erro: \(error)")
                completion(nil)
                return
            }

            guard let data = data else {
                print("Resposta vazia")
                completion(nil)
                return
            }

            if let response = response as? HTTPURLResponse {
                print("Status code: \(response.statusCode)")
            }

            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any], let apiKey = json["api_key"] as? String {
                completion(apiKey)
            } else {
                print("Resposta não pôde ser convertida: \(String(data: data, encoding: .utf8) ?? "desconhecida")")
                completion(nil)
            }
        }.resume()
    }

    func fetchPrompts(completion: @escaping ([[String: Any]]?) -> Void) {
        guard let url = URL(string: "\(baseURL)/prompts") else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(accessToken, forHTTPHeaderField: "x-token")

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
                completion(nil)
                return
            }
            completion(json)
        }.resume()
    }
}
