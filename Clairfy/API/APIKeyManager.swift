import Foundation

struct APIKeyManager {
    static func getAPIKey() -> String {
        return loadTextFile(named: "apiKey.txt") ?? ""
    }
    
    private static func loadTextFile(named fileName: String) -> String? {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: nil) else {
            print("❌ Arquivo \(fileName) não encontrado no bundle.")
            return nil
        }
        
        do {
            let content = try String(contentsOf: url, encoding: .utf8)
            return content.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            print("❌ Erro ao ler o arquivo \(fileName): \(error)")
            return nil
        }
    }
}
