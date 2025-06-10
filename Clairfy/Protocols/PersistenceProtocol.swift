import Foundation

protocol PersistenceProtocol {
    func createAudio(_ audio: AudioFileModel)
    func getAllAudio() -> [AudioFileModel]
    func getAudio(by id: UUID) -> AudioFileModel?
    func deleteAudio(by id: UUID) -> Bool
    
    func createConsultation(_ consultation: ConsultationModel)
    func getAllConsultations() -> [ConsultationModel]
    func getConsultation(by id: UUID) -> ConsultationModel?
    func deleteConsultation(by id: UUID) -> Bool
    func updateConsultation(_ consultation: ConsultationModel) -> Bool
    
    func createTranscription(_ transcription: TranscriptionModel)
    func getAllTranscriptions() -> [TranscriptionModel]
    func getTranscription(by id: UUID) -> TranscriptionModel?
    func deleteTranscription(by id: UUID) -> Bool
    func updateTranscription(_ transcription: TranscriptionModel) -> Bool
}
