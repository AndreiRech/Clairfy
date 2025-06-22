import Foundation
import UIKit
import AVFAudio

class AudioRecordManager {
    // MARK: Propierties
    var timer: Timer?
    var elapsedTime: TimeInterval = 0
    var recordingState: RecordingState = .stopped
    var recordingAnimationTimer: Timer?
    let recordingImages = [UIImage(named: "rec1"), UIImage(named: "rec3")]
    var currentImageIndex = 0
    var audioRecorder: AVAudioRecorder?
    var audioURL: URL?
    var recordings: [URL] = []
    var audioID: UUID?
    var voiceRecordVC: VoiceRecordingViewController
    
    init(voiceRecordVC: VoiceRecordingViewController) {
        self.voiceRecordVC = voiceRecordVC
    }
    
    // MARK: Functions
    private func createURL() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try audioSession.setActive(true)
            
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            audioURL = documentsPath.appendingPathComponent("audio_\(Date().timeIntervalSince1970).m4a")
            print("Audio Salvo com o nome: \(String(describing: audioURL))")
        } catch {
            print("Erro ao iniciar gravação: \(error.localizedDescription)")
        }
    }
    
    func startRecording() {
        createURL()
        
        recordingState = .recording
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 16000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
            
        do {
            guard let audioURL else { return }
            audioRecorder = try AVAudioRecorder(url: audioURL, settings: settings)
            audioRecorder?.delegate = voiceRecordVC
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.prepareToRecord()
            audioRecorder?.record()
         
            self.startWaveformMetering()

        } catch {
            print("erro")
        }
            
        // Atualiza o ícone do botão
        updateRecordButtonIcon()
            
        timer = Timer.scheduledTimer(
            timeInterval: 0.01,
            target: voiceRecordVC,
            selector: #selector(voiceRecordVC.updateTimer),
            userInfo: nil,
            repeats: true
        )
        
        startRecordingAnimation()
    }
    
    func pauseRecording() {
        recordingState = .paused
        updateRecordButtonIcon()
        
        timer?.invalidate()
        timer = nil
        stopRecordingAnimation()
    }
        
    func stopRecording() {
        self.stopWaveformMetering()
        
        audioRecorder?.stop()
        recordingState = .stopped
        timer?.invalidate()
        timer = nil
            
        updateRecordButtonIcon()
        stopRecordingAnimation()
    }
        
    func updateRecordButtonIcon() {
        let iconName: String
        let iconColor: UIColor = .systemBackground
            
        switch recordingState {
        case .stopped:
            iconName = "stop.fill"
        case .recording:
            iconName = "pause.fill"
        case .paused:
            iconName = "play.fill"
        }
            
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
                
            let iconSize = voiceRecordVC.recordButton.bounds.width * 0.4
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: iconSize, weight: .bold)
            let iconImage = UIImage(systemName: iconName, withConfiguration: symbolConfig)
                
            voiceRecordVC.recordButton.setImage(iconImage, for: .normal)
            voiceRecordVC.recordButton.tintColor = iconColor
        }
    }
    
    func updateTimerLabel() {
        let hours = Int(elapsedTime) / 3600
        let minutes = (Int(elapsedTime) % 3600) / 60
        let seconds = Int(elapsedTime) % 60
            
        DispatchQueue.main.async {
            self.voiceRecordVC.timerLabel.text = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
    }
    
    func resetRecording() {
        stopRecording()
        
        elapsedTime = 0
        
        updateTimerLabel()
    }
    
    func showFinishConfirmationAlert() {
        let alert = UIAlertController(
            title: "Finalizar Gravação",
            message: "Você deseja finalizar a gravação?",
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .default)
        let finishAction = UIAlertAction(title: "Finalizar", style: .cancel) { [weak self] _ in
            self?.handleFinishRecording()
        }
        
        finishAction.setValue(UIColor.systemGreen, forKey: "titleTextColor")
        
        alert.addAction(cancelAction)
        alert.addAction(finishAction)
        
        voiceRecordVC.present(alert, animated: true)
    }
    
    func showDeleteConfirmationAlert() {
        let alert = UIAlertController(
            title: "Deletar Áudio",
            message: "Tem certeza de que deseja deletar esse áudio?",
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .default)
        let deleteAction = UIAlertAction(title: "Deletar", style: .cancel) { [weak self] _ in
            self?.resetRecording()
        }
        
        deleteAction.setValue(UIColor.systemRed, forKey: "titleTextColor")
        
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        
        voiceRecordVC.present(alert, animated: true)
    }
    
    func handleFinishRecording() {
        stopRecording()
            
        saveAudioRecording()
            
        resetRecording()
        
        changeScreen()
    }
    
     func changeScreen() {
        let renameVC = RenameViewController()
        renameVC.audioID = self.audioID
        
        let navController = UINavigationController(rootViewController: renameVC)

        if let sheet = navController.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }

        navController.modalPresentationStyle = .pageSheet
        voiceRecordVC.present(navController, animated: true)
    }
    
    func saveAudioRecording() {
        guard let audioURL = audioURL else {
            print("Erro ao criar URL para o áudio.")
            return
        }
        
        let audio = AudioFileModel(id: UUID(), audioPath: audioURL.lastPathComponent)
        audioID = audio.id
            
        Persistence.shared.createAudio(audio)
    }
    
    func startRecordingAnimation() {
        currentImageIndex = 0
        voiceRecordVC.recordingImage.image = recordingImages[currentImageIndex]
        
        // Configura o timer para trocar as imagens a cada 0.5 segundos
        recordingAnimationTimer = Timer.scheduledTimer(withTimeInterval: 0.6, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            self.currentImageIndex = (self.currentImageIndex + 1) % self.recordingImages.count
            
            UIView.transition(with: voiceRecordVC.recordingImage,
                              duration: 0.4,
                              options: .transitionCrossDissolve,
                              animations: {
                                self.voiceRecordVC.recordingImage.image = self.recordingImages[self.currentImageIndex]
                              },
                              completion: nil)
        }
    }
    
    func stopRecordingAnimation() {
        recordingAnimationTimer?.invalidate()
        recordingAnimationTimer = nil
        
        // Volta para a imagem inicial (ou outra de sua escolha)
        UIView.transition(with: voiceRecordVC.recordingImage,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: {
                            self.voiceRecordVC.recordingImage.image = .emptyRec
                          },
                          completion: nil)
    }
}

import AVFoundation

extension AudioRecordManager {
    
    // MARK: – Waveform metering
    private struct Metering {
        static var timerKey   = "meteringTimer"
        static var delegate   = "audioMeteringDelegate"
        static var amplitudes = "amplitudesDuringRecording"
    }
    
    /// quem recebe as amplitudes (ex.: AudioVisualizerView)
    weak var audioMeteringDelegate: AudioMeteringDelegate? {
        get { objc_getAssociatedObject(self, &Metering.delegate) as? AudioMeteringDelegate }
        set { objc_setAssociatedObject(self, &Metering.delegate, newValue, .OBJC_ASSOCIATION_ASSIGN) }
    }
    
    /// últimos valores (caso você queira salvar)
    var amplitudesDuringRecording: [Double] {
        get { (objc_getAssociatedObject(self, &Metering.amplitudes) as? [Double]) ?? [] }
        set { objc_setAssociatedObject(self, &Metering.amplitudes, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    private var meteringTimer: Timer? {
        get { objc_getAssociatedObject(self, &Metering.timerKey) as? Timer }
        set { objc_setAssociatedObject(self, &Metering.timerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    /// inicie logo depois de `audioRecorder?.record()`
    func startWaveformMetering() {
        audioRecorder?.isMeteringEnabled = true
        
        meteringTimer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true) { [weak self] _ in
            guard let self, let recorder = self.audioRecorder else { return }
            recorder.updateMeters()
            let avg = recorder.averagePower(forChannel: 0)
            let amp = max(0, min(1, 1.1 * pow(10, avg / 20)))

            self.audioMeteringDelegate?.audioMeter(didUpdateAmplitude: amp)
            self.amplitudesDuringRecording.append(Double(amp))
            //Não Apaga isso aqui
//            let avg = recorder.averagePower(forChannel: 0)
//            let minDb: Float = -50
//            let clipped = max(minDb, avg)
//            let normalized = 1 - (abs(clipped) / abs(minDb))
//
//            self.audioMeteringDelegate?.audioMeter(didUpdateAmplitude: normalized)
//            self.amplitudesDuringRecording.append(Double(normalized))

        }
        meteringTimer?.fire()
    }
    
    func stopWaveformMetering() {
        meteringTimer?.invalidate()
        meteringTimer = nil
    }
}

