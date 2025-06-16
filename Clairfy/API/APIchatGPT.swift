//
//  APIchatGPT.swift
//  Clairfy
//
//  Created by Eduardo Ferrari on 14/06/25.
//
import Foundation

class APIchatGPT {
    
    private let apiKey = "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"

       // MARK: - Transcrição de áudio
       func transcreverAudio(audioFileURL: URL, completion: @escaping (String?) -> Void) {
           var request = URLRequest(url: URL(string: "https://api.openai.com/v1/audio/transcriptions")!)
           request.httpMethod = "POST"
           request.timeoutInterval = 120
           request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

           let boundary = UUID().uuidString
           request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

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

           request.httpBody = body

           URLSession.shared.dataTask(with: request) { data, response, error in
               guard let data = data,
                     let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                     let text = json["text"] as? String else {
                   completion(nil)
                   return
               }
               completion(text)
           }.resume()
       }

      
    func resumirTexto(_ texto: String, completion: @escaping (String?) -> Void) {
        let prompt = "Resuma a seguinte conversa clínica de forma clara, separando falas de médico e paciente:\n\n\(texto)"

        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": "gpt-4.1-nano-2025-04-14",
            "messages": [
                ["role": "system", "content": "Você é um assistente médico especializado em resumos clínicos."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.2
        ]

        request.httpBody = try! JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Erro ao se comunicar com a API:", error.localizedDescription)
                completion(nil)
                return
            }

            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let choices = json["choices"] as? [[String: Any]],
                  let message = choices.first?["message"] as? [String: Any],
                  let content = message["content"] as? String else {
                print("❌ Erro ao interpretar resposta da API")
                completion(nil)
                return
            }

            completion(content)
        }.resume()
    }

    
}
