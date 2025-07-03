import Foundation
import UIKit

final class TranscriptionManager {
    weak var delegate: TranscriptionManagerDelegate?
    private var api = ApiConnect()
    private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid

    func gerarAnalise(for consultation: ConsultationModel?, completion: @escaping (Bool) -> Void) {
        self.backgroundTaskID = UIApplication.shared.beginBackgroundTask(withName: "Trasncription") {
            UIApplication.shared.endBackgroundTask(self.backgroundTaskID)
            self.backgroundTaskID = .invalid
        }
        
        guard let audioPath = consultation?.audio?.audioPath else { return }
            
        delegate?.didChangeLoadingState(true)
            
        let fileManager = FileManager.default
        let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let originalURL = documentsDir.appendingPathComponent(audioPath)
        let destinationURL = documentsDir.appendingPathComponent("audioTranscricao.m4a")

        do {
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            try fileManager.copyItem(at: originalURL, to: destinationURL)
        } catch {
            handleTranscriptionError()
            return
        }

        api.getResponse(audioFileURL: destinationURL) { [weak self] response in
            guard let response = response else {
                self?.handleTranscriptionError()
                return
            }
            self?.finalizeTranscription(response: response, consultation: consultation)
        }
    }
        
    private func finalizeTranscription(response: TranscriptionDTO, consultation: ConsultationModel?) {
        let transcricaoModel = TranscriptionModel(
            id: UUID(),
            transcription: response.transcription,
            summary: response.summary,
            didctarized: response.didctarized,
            keyWords: response.keyWords,
            actionPoints: response.actionPoints
        )
            
        Persistence.shared.createTranscription(transcricaoModel)
            
        guard let consultation = consultation else {
            handleTranscriptionError()
            return
        }
            
        _ = Persistence.shared.updateConsultation(consultation, transcription: transcricaoModel, audio: nil)
    
        delegate?.didChangeConsultation(Persistence.shared.getConsultation(by: consultation.id))
        delegate?.didChangeLoadingState(false)
        delegate?.didFinishTranscription(success: true)
        
        if self.backgroundTaskID != .invalid {
            UIApplication.shared.endBackgroundTask(self.backgroundTaskID)
            self.backgroundTaskID = .invalid
        }
    }
        
    private func handleTranscriptionError() {
        delegate?.didChangeLoadingState(false)
        delegate?.didFinishTranscription(success: false)
        delegate?.didErrorHappend()
        
        if self.backgroundTaskID != .invalid {
            UIApplication.shared.endBackgroundTask(self.backgroundTaskID)
            self.backgroundTaskID = .invalid
        }
    }
}
