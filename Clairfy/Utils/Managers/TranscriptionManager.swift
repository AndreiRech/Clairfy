import Foundation
import UIKit

final class TranscriptionManager {
    weak var delegate: TranscriptionManagerDelegate?
    private var api = APIchatGPT()
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

        api.transcreverAudio(audioFileURL: destinationURL) { [weak self] transcricao in
            self?.handleTranscriptionResult(transcricao, for: consultation)
        }
    }

    private func handleTranscriptionResult(_ transcricao: String?, for consultation: ConsultationModel?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            guard let transcricao = transcricao, !transcricao.isEmpty else {
                self.handleTranscriptionError()
                return
            }
                
            self.processDoctorSummary(transcricao, consultation: consultation)
        }
    }
        
    private func processDoctorSummary(_ transcricao: String, consultation: ConsultationModel?) {
        api.resumirTexto(transcricao, type: "doctor") { [weak self] resultDoctor in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                guard let resultDoctor = resultDoctor,
                        let jsonDoctorData = resultDoctor.data(using: .utf8),
                        let doctorResponse = try? JSONDecoder().decode(DoctorResponse.self, from: jsonDoctorData)
                else {
                    self.handleTranscriptionError()
                    return
                }
                    
                self.processPatientSummary(transcricao, consultation: consultation, doctorResponse: doctorResponse)
            }
        }
    }
        
    private func processPatientSummary(_ transcricao: String, consultation: ConsultationModel?, doctorResponse: DoctorResponse) {
        api.resumirTexto(transcricao, type: "patient") { [weak self] resultPatient in
            guard let self = self else { return }
                
            DispatchQueue.main.async {
                guard let resultPatient = resultPatient,
                        let jsonPatientData = resultPatient.data(using: .utf8),
                        let patientResponse = try? JSONDecoder().decode(PatientResponse.self, from: jsonPatientData)
                else {
                    self.handleTranscriptionError()
                    return
                }
                    
                self.finalizeTranscription(transcricao: transcricao, consultation: consultation, doctorResponse: doctorResponse, patientResponse: patientResponse)
            }
        }
    }
        
    private func finalizeTranscription(transcricao: String, consultation: ConsultationModel?, doctorResponse: DoctorResponse, patientResponse: PatientResponse) {
        let transcricaoModel = TranscriptionModel(
            id: UUID(),
            transcription: transcricao,
            summary: doctorResponse.summary,
            didctarized: patientResponse.didctarized,
            keyWords: doctorResponse.keyWords,
            actionPoints: patientResponse.actionPoints
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
