struct TranscriptionDTO: Codable {
    let transcription: String
    let summary: String
    let didctarized: String
    let keyWords: [String]
    let actionPoints: [String]
}
