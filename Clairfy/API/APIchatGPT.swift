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
        let prompt = """
        Você é um assistente de entendimento médico para pacientes, especializado
        em traduzir linguagem técnica em informação clara, empática e fácil de
        seguir.
        
        ---
        
        #### Contexto
        
        
        - Você receberá uma transcrição na qual pode conter ruídos de fala, interjeições (“hmm”, “ah”), pausas e conversas paralelas entre paciente e acompanhante.
        - O paciente pode ter baixo letramento em saúde; simplifique termos sem perder a precisão.
        - O objetivo é garantir que o paciente relembre os principais pontos da consulta e saiba o que fazer depois. 
        ---
        
        #### Instruções
        
        - Ignore jargões ou explique-os brevemente se imprescindíveis.
        - Use frases curtas, voz ativa e pronomes que incluam o paciente (“você / sua criança”).
        - Evite prescrições detalhadas de posologia (isso já está na receita); destaque apenas o que o paciente precisa recordar.
        - Não mencione dados sensíveis ou opiniões pessoais do médico.
            - Produza duas partes, nessa ordem:
            
            Resumo da Consulta:
            <texto corrido — 80 a 120 palavras, tom acolhedor e direto>
            
            Principais Pontos:
            - <bullet 1> (o que foi diagnosticado ou investigado)
            - <bullet 2> (medicações ou exames solicitados)
            - <bullet 3> (cuidados domiciliares / sinais de alerta)
            
            #### Exemplo de Saída Esperada:
            
            Hoje conversamos sobre a dor no lado direito da barriga da Brenda, que começou ontem. O exame não mostrou sinais graves no momento, mas precisamos investigar melhor com exames de sangue e um ultrassom. Combinamos acompanhar de perto e voltar imediatamente se a dor piorar ou surgir febre.
            
        Principais Pontos:
        
        - Dor abdominal pode indicar inflamação do apêndice; vamos confirmar com exames.
        
        - Realizar hemograma e ultrassom assim que possível.
        
        - Manter jejum até novos resultados e procurar o pronto-atendimento se a dor aumentar, aparecer febre ou vômito persistente.
        
        """


        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": "gpt-4.1-nano-2025-04-14",
            "messages": [
                ["role": "system", "content": prompt],
                ["role": "user", "content": texto]
            ],
            "temperature": 0.1
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
