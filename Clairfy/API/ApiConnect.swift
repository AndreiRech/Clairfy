import Foundation

class ApiConnect {
    private let secureProvider = SecureData()

    func getResponse(audioFileURL: URL, completion: @escaping (TranscriptionDTO?) -> Void) {
        secureProvider.fetchResponse(audioFileURL: audioFileURL) { response in
            guard let response = response else {
                completion(nil)
                return
            }

            return completion(response)
        }
    }
    
    func getToken(completion: @escaping (String?) -> Void) {
        secureProvider.fetchToken { token in
            guard let token = token else {
                completion(nil)
                return
            }
            
            return completion(token)
        }
    }
}
