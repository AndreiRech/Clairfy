import Foundation

class SecureData {
    private let baseURL = "https://clairfy-backend.onrender.com"

    func fetchToken(completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "\(baseURL)/auth/token") else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

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

            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any], let token = json["token"] as? String {
                KeychainHelper.shared.save(token, forKey: "clarify_jwt_token")
                completion(token)
            } else {
                print("Resposta não pôde ser convertida: \(String(data: data, encoding: .utf8) ?? "desconhecida")")
                completion(nil)
            }
        }.resume()
    }
    
    func fetchResponse(audioFileURL: URL, completion: @escaping (TranscriptionDTO?) -> Void) {
        guard let url = URL(string: "\(baseURL)/summarize/health") else {
            completion(nil)
            return
        }
        
        guard let token = KeychainHelper.shared.read(forKey: "clarify_jwt_token") else {
            print("Problema no token")
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        let filename = audioFileURL.lastPathComponent
        let mimetype = "audio/m4a"
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"audio\"; filename=\"\(filename)\"\r\n")
        body.append("Content-Type: \(mimetype)\r\n\r\n")
        
        if let fileData = try? Data(contentsOf: audioFileURL) {
            body.append(fileData)
        }
            
        body.append("\r\n")
        body.append("--\(boundary)--\r\n")
        
        request.httpBody = body

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

            if let decoded = try? JSONDecoder().decode(TranscriptionDTO.self, from: data) {
                completion(decoded)
            } else {
                print("Resposta: \(String(data: data, encoding: .utf8) ?? "desconhecida")")
                completion(nil)
            }
        }.resume()
    }
}
