//
//  AnalysisActions.swift
//  Clairfy
//
//  Created by Bernardo Garcia Fensterseifer on 20/06/25.
//

import AVFoundation
import UIKit

// MARK: - Actions
extension AnalysisViewController { 
    @objc internal func gerarAnalise() {
        guard let audioPath = consultation?.audio?.audioPath else {
            print("❌ Caminho do áudio não encontrado. \(consultation?.audio?.audioPath ?? "Nenhum")")
            return
        }

        isLoading = true

        let fileManager = FileManager.default
        let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let originalURL = documentsDir.appendingPathComponent(audioPath)
        let destinationURL = documentsDir.appendingPathComponent("audioTranscricao.m4a")

        do {
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            try fileManager.copyItem(at: originalURL, to: destinationURL)
            print("📥 Áudio copiado para: \(destinationURL.path)")
        } catch {
            print("❌ Erro ao copiar o áudio:", error.localizedDescription)
            isLoading = false
            return
        }

        let api = APIchatGPT()
        print("🎙️ Iniciando transcrição...")

        api.transcreverAudio(audioFileURL: destinationURL) { [weak self] transcricao in
            guard let self = self else { return }

            DispatchQueue.main.async {
                guard let transcricao = transcricao, !transcricao.isEmpty else {
                    print("❌ Transcrição vazia ou nula.")
                    self.isLoading = false
                    return
                }

                print("📝 Transcrição recebida:")
                print(transcricao)

                print("💬 Enviando para resumo...")

                // cpa eh aqui q nn ta adicionando no paciente?? mas o didctarized eh feito tmb, nn faz sentido!! vsf to bugado
                api.resumirTexto(transcricao, type: "doctor") { resultDoctor in
                    DispatchQueue.main.async {
                        guard let resultDoctor = resultDoctor, let jsonDoctorData = resultDoctor.data(using: .utf8) else {
                            print("❌ Erro ao receber ou converter o resumo do doctor.")
                            self.isLoading = false
                            return
                        }

                        var summary: String?
                        var keyWords: [String] = []

                        do {
                            let decoder = JSONDecoder()
                            let apiResponseDoctor = try decoder.decode(DoctorResponse.self, from: jsonDoctorData)
                            summary = apiResponseDoctor.summary
                            keyWords = apiResponseDoctor.keyWords
                            print("✅ Doctor Summary: \(summary ?? "Nenhum")")
                            print("✅ Doctor Keywords: \(keyWords)")
                        } catch {
                            print("❌ Erro ao decodificar JSON do doctor: \(error.localizedDescription)")
                            self.isLoading = false
                            return
                        }

                        // aqui seria o do paciente, entao pq nn ta atualizando?
                        api.resumirTexto(transcricao, type: "patient") { resultPatient in
                            DispatchQueue.main.async {
                                guard let resultPatient = resultPatient, let jsonPatientData = resultPatient.data(using: .utf8) else {
                                    print("❌ Erro ao receber ou converter o resumo do patient.")
                                    self.isLoading = false
                                    return
                                }

                                var didctarized: String?
                                var actionPoints: [String] = []

                                do {
                                    let decoder = JSONDecoder()
                                    let apiResponsePatient = try decoder.decode(PatientResponse.self, from: jsonPatientData)
                                    didctarized = apiResponsePatient.didctarized
                                    actionPoints = apiResponsePatient.actionPoints
                                    print("✅ Patient Didctarized: \(didctarized ?? "Nenhum")")
                                    print("✅ Patient ActionPoints: \(actionPoints)")
                                } catch {
                                    print("❌ Erro ao decodificar JSON do patient: \(error.localizedDescription)")
                                    self.isLoading = false
                                    return
                                }

                                // Se chegou aqui, tudo foi bem com as duas APIs.
                                guard let summary = summary, let didctarized = didctarized else {
                                    print("❌ Dados incompletos após os dois resumos.")
                                    self.isLoading = false
                                    return
                                }

                                let transcricaoModel = TranscriptionModel(
                                    id: UUID(),
                                    transcription: transcricao,
                                    summary: summary,
                                    didctarized: didctarized,
                                    keyWords: keyWords,
                                    actionPoints: actionPoints
                                )

                                Persistence.shared.createTranscription(transcricaoModel)

                                guard let consultation = self.consultation else {
                                    print("❌ Consulta não encontrada.")
                                    self.isLoading = false
                                    return
                                }

                                _ = Persistence.shared.updateConsultation(consultation, transcription: transcricaoModel, audio: nil)
                                
                                self.consultation = Persistence.shared.getConsultation(by: consultation.id)
                                
                                self.isLoading = false
                                self.analysisGenerated = true
                            }
                        }
                    }
                }
            }
        }
    }
    
    @objc internal func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0: // Médico
            self.doctorView.isHidden = false
            self.patientView.isHidden = true
        case 1: // Paciente
            self.doctorView.isHidden = true
            self.patientView.isHidden = false
        default:
            break
        }
        
        self.view.layoutIfNeeded()
    }
    
//    internal func updatePlayIcon(to state: PlayButtonState) {
//        let iconName: String
//        
//        switch state {
//        case .play:
//            iconName = "play.fill"
//            let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
//            let image = UIImage(systemName: iconName, withConfiguration: config)
////            audioComponent.playButtonIconColor = .tertiarySystemBackground
////            audioComponent.playButtonView.backgroundColor = .clairBlue
////            audioComponent.playButton.setImage(image, for: .normal)
//        case .pause:
//            iconName = "pause.fill"
//            let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
//            let image = UIImage(systemName: iconName, withConfiguration: config)
////            audioComponent.playButtonIconColor = .tertiarySystemBackground
////            audioComponent.playButtonView.backgroundColor = .clairBlue
////            audioComponent.playButton.setImage(image, for: .normal)
////            audioComponent.playButton.tintColor = .tertiarySystemBackground
//        }
//    }
    
    @objc internal func playButtonTapped() {
        if let player = audioPlayer {
            if player.isPlaying {
                player.pause()
                audioComponent.playButtonState = .play
                print("⏸ Áudio pausado")
            } else {
                player.play()
                audioComponent.playButtonState = .pause
                print("▶️ Áudio retomado")
            }
            return
        }

        guard let fileName = consultation?.audio?.audioPath else { return }
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = documents.appendingPathComponent(fileName)

        if !FileManager.default.fileExists(atPath: url.path) {
            print("❌ Arquivo de áudio não encontrado no caminho: \(url.path)")
            return
        }
        
        let attributes = try? FileManager.default.attributesOfItem(atPath: url.path)
        print("📏 Tamanho do arquivo:", attributes?[.size] ?? "Desconhecido")

        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try audioSession.setActive(true)
        } catch {
            print("❌ Erro ao configurar AVAudioSession:", error)
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            audioComponent.playButtonState = .pause
            print("🎵 Tocando áudio: \(url.path)")
        } catch {
            print("❌ Erro ao tocar o áudio: \(error.localizedDescription)")
        }
    }

    @objc internal func trashButtonTapped() {
        print("Trash button tapped")
    }

    @objc internal func shareButtonTapped() {
        print("Share button tapped")
    }
    
    enum PlayButtonState {
        case play
        case pause
    }
    
}
