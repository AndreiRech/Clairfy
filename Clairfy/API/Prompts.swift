import Foundation

struct Prompts {
    static let doctor = Prompts.getPrompt(for: .doctor)
    static let patient = Prompts.getPrompt(for: .patient)

    static func getPrompt(for type: PromptType) -> String {
        let filename = "\(type.rawValue).txt"
        return loadTextFile(named: filename) ?? ""
    }

    private static func loadTextFile(named fileName: String) -> String? {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: nil) else {
            print("❌ Arquivo \(fileName) não encontrado no bundle.")
            return nil
        }

        do {
            let content = try String(contentsOf: url, encoding: .utf8)
            return content
        } catch {
            print("❌ Erro ao ler o arquivo \(fileName): \(error)")
            return nil
        }
    }
    
}
