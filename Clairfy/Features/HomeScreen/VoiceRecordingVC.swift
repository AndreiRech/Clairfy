//
//  VoiceRecordingViewController.swift
//  Clairfy
//
//  Created by Bernardo Garcia Fensterseifer on 10/06/25.
//

import UIKit
import AVFoundation

private enum RecordingState {
    case stopped
    case recording
    case paused
}

class VoiceRecordingViewController: UIViewController, AVAudioRecorderDelegate {
    private var timer: Timer?
    private var elapsedTime: TimeInterval = 0
    // Substitua a variável isRecording por:
    private var recordingState: RecordingState = .stopped
    var recordingAnimationTimer: Timer?
    let recordingImages = [UIImage(named: "rec1"), UIImage(named: "rec3")]
    var currentImageIndex = 0
    
    // MARK: components & variables
    private var audioRecorder: AVAudioRecorder?
    private var audioURL: URL?
    private var recordings: [URL] = []

    lazy var recordingImage: UIImageView = {
        var imageView = UIImageView()
        imageView.image = .emptyRec
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    lazy var timerLabel: UILabel = {
        var label = UILabel()
        label.text = "00:00:00"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 42, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var soundWaveImage: UIImageView = {
        var imageView = UIImageView()
        imageView.image = .soundWave
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    lazy var recordButton: UIButton = {
        var button = UIButton()
        button.backgroundColor = .clairBlue
        button.translatesAutoresizingMaskIntoConstraints = false

        /// constraints
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 92),
            button.heightAnchor.constraint(equalToConstant: 92)
        ])

        /// Força o cálculo do layout
        DispatchQueue.main.async {
            let iconSize = button.bounds.width * 0.4 // 40% do tamanho do botão
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: iconSize, weight: .heavy)
            let playImage = UIImage(systemName: "stop.fill", withConfiguration: symbolConfig)
            button.setImage(playImage, for: .normal)
        }

        button.tintColor = .systemBackground
        button.layer.cornerRadius = 46
        button.layer.masksToBounds = true

        return button
    }()
    lazy var deleteAudioButton: UIButton = {
        var button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 28 // metade do tamanho faz um círculo!
        button.layer.masksToBounds = true
        button.backgroundColor = .label
        button.tintColor = .systemBackground
        
        /// Força o cálculo do layout
        DispatchQueue.main.async {
            let iconSize = button.bounds.width * 0.5 // 50% do tamanho do botão
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: iconSize, weight: .heavy)
            let playImage = UIImage(systemName: "trash.fill", withConfiguration: symbolConfig)
            button.setImage(playImage, for: .normal)
        }
        
        /// opcional: padding
        //button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        
        /// constraints
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 56),
            button.heightAnchor.constraint(equalToConstant: 56)
        ])
        
        return button
    }()
    lazy var finishedAudioButton: UIButton = {
        var button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 28 // metade do tamanho faz um círculo!
        button.layer.masksToBounds = true
        button.backgroundColor = .label
        button.tintColor = .systemBackground
        
        /// Força o cálculo do layout
        DispatchQueue.main.async {
            let iconSize = button.bounds.width * 0.5 // 50% do tamanho do botão
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: iconSize, weight: .heavy)
            let playImage = UIImage(systemName: "checkmark", withConfiguration: symbolConfig)
            button.setImage(playImage, for: .normal)
        }
        
        /// opcional: padding
        //button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        
        /// constraints
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 56),
            button.heightAnchor.constraint(equalToConstant: 56)
        ])
        
        return button
    }()
    lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [deleteAudioButton, recordButton, finishedAudioButton])
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 40
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - "main"
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        view.backgroundColor = .secondarySystemBackground
        setupButtonActions()
        updateTimerLabel()
        title = "Gravação de Áudio"
        
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    // MARK: - functions
    private func startRecording() {
            recordingState = .recording
            
            // Atualiza o ícone do botão
            updateRecordButtonIcon()
            
            timer = Timer.scheduledTimer(
                timeInterval: 0.01,
                target: self,
                selector: #selector(updateTimer),
                userInfo: nil,
                repeats: true
            )
            startRecordingAnimation()
        }
        
    private func pauseRecording() {
            recordingState = .paused
            updateRecordButtonIcon()
            timer?.invalidate()
            timer = nil
            stopRecordingAnimation()
        }
        
    private func stopRecording() {
            recordingState = .stopped
            timer?.invalidate()
            timer = nil
            
            // Atualiza o ícone do botão de gravação
            updateRecordButtonIcon()
            stopRecordingAnimation()
        }
        
    private func updateRecordButtonIcon() {
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
                
                let iconSize = self.recordButton.bounds.width * 0.4
                let symbolConfig = UIImage.SymbolConfiguration(pointSize: iconSize, weight: .bold)
                let iconImage = UIImage(systemName: iconName, withConfiguration: symbolConfig)
                
                self.recordButton.setImage(iconImage, for: .normal)
                self.recordButton.tintColor = iconColor
            }
        }
        
    @objc private func updateTimer() {
        elapsedTime += 0.01
        updateTimerLabel()
    }
        
    private func updateTimerLabel() {
        let hours = Int(elapsedTime) / 3600
        let minutes = (Int(elapsedTime) % 3600) / 60
        let seconds = Int(elapsedTime) % 60
            
        DispatchQueue.main.async {
            self.timerLabel.text = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
    }

    private func resetRecording() {
        // Para a gravação se estiver em andamento
        stopRecording()
        
        // Reseta o timer
        elapsedTime = 0
        updateTimerLabel()
        
        // Aqui você pode adicionar qualquer outra lógica de limpeza
        // como remover o arquivo de áudio se já tiver sido salvo (ver com o Andrei)
    }
    
    private func showStartConfirmationAlert() {
        let alert = UIAlertController(
            title: "Nova Gravação",
            message: "Deseja iniciar uma nova gravação?",
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel)
        let startAction = UIAlertAction(title: "Iniciar Gravação", style: .default) { [weak self] _ in
            self?.resetRecording() // Zera o timer antes de começar
            self?.startRecording()
        }
        
        startAction.setValue(UIColor.systemGreen, forKey: "titleTextColor")
        alert.addAction(cancelAction)
        alert.addAction(startAction)
        
        present(alert, animated: true)
    }

    
    private func showFinishConfirmationAlert() {
        let alert = UIAlertController(
            title: "Finalizar Gravação",
            message: "Você deseja finalizar a gravação?",
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .default)
        let finishAction = UIAlertAction(title: "Finalizar", style: .cancel) { [weak self] _ in
            self?.handleFinishRecording()
        }
        
        // Define a cor verde para o botão Finalizar
        finishAction.setValue(UIColor.systemGreen, forKey: "titleTextColor")
        
        alert.addAction(cancelAction)
        alert.addAction(finishAction)
        
        present(alert, animated: true)
    }
    
    private func showDeleteConfirmationAlert() {
        let alert = UIAlertController(
            title: "Deletar Áudio",
            message: "Tem certeza de que deseja deletar esse áudio?",
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .default)
        let deleteAction = UIAlertAction(title: "Deletar", style: .cancel) { [weak self] _ in
            self?.resetRecording()
        }
        
        // Define a cor verde para o botão Iniciar Gravação
        deleteAction.setValue(UIColor.systemRed, forKey: "titleTextColor")
        
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        
        present(alert, animated: true)
    }
        
    private func handleFinishRecording() {
        // 1. Primeiro para a gravação
        stopRecording()
            
        // 2. Aqui você pode implementar a lógica de salvamento do áudio no futuro
        saveAudioRecording() // Função reservada para implementação futura
            
        // 3. Reseta o timer
        resetRecording()
    }
        
    /// Função reservada para implementação futura do salvamento do áudio
    private func saveAudioRecording() {
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try audioSession.setActive(true)
            
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            audioURL = documentsPath.appendingPathComponent("audio_\(Date().timeIntervalSince1970).m4a")
            print("Audio Salvo com o nome: \(String(describing: audioURL))")
            
            guard let audioURL = audioURL else {
                print("Erro ao criar URL para o áudio.")
                return }
            
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 16000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            audioRecorder = try AVAudioRecorder(url: audioURL, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            
        } catch {
            print("Erro ao iniciar gravação: \(error.localizedDescription)")
        }
    }
    
    ///whatafuck
    func animateRecordingImage() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseInOut) {
            self.recordingImage.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        } completion: { _ in
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseInOut) {
                self.recordingImage.transform = .identity
            }
        }
    }
    
    // Função para iniciar/parar a animação
    @objc func toggleRecordingAnimation() {
            if recordingState == .recording {
                startRecordingAnimation()
            } else {
                stopRecordingAnimation()
            }
            audioRecorder?.stop()
            audioRecorder = nil
            
            do {
                try AVAudioSession.sharedInstance().setActive(false)
            } catch {
                print("Erro ao desativar sessão de áudio: \(error.localizedDescription)")
            }
        }

    // Inicia a animação
    func startRecordingAnimation() {
        currentImageIndex = 0
        recordingImage.image = recordingImages[currentImageIndex]
        
        // Configura o timer para trocar as imagens a cada 0.5 segundos
        recordingAnimationTimer = Timer.scheduledTimer(withTimeInterval: 0.6, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            self.currentImageIndex = (self.currentImageIndex + 1) % self.recordingImages.count
            
            UIView.transition(with: self.recordingImage,
                              duration: 0.4,
                              options: .transitionCrossDissolve,
                              animations: {
                                  self.recordingImage.image = self.recordingImages[self.currentImageIndex]
                              },
                              completion: nil)
        }
    }

    // Para a animação
    func stopRecordingAnimation() {
        recordingAnimationTimer?.invalidate()
        recordingAnimationTimer = nil
        
        // Volta para a imagem inicial (ou outra de sua escolha)
        UIView.transition(with: recordingImage,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: {
            self.recordingImage.image = .emptyRec
                          },
                          completion: nil)
    }
    
}

// MARK: - addViews & setConstraints
extension VoiceRecordingViewController: ViewCodeProtocol {
    
    func addSubViews() {
        view.addSubview(recordingImage)
        view.addSubview(timerLabel)
        view.addSubview(soundWaveImage)
        view.addSubview(buttonsStackView)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            /// recordingImage constraints
            recordingImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            recordingImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            /// timerLabel constraints
            timerLabel.topAnchor.constraint(equalTo: recordingImage.bottomAnchor, constant: 40),
            timerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            /// soundWaveImage constraints
            soundWaveImage.topAnchor.constraint(equalTo: timerLabel.bottomAnchor, constant: 40),
            soundWaveImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            /// buttonsStackView constraints
            buttonsStackView.topAnchor.constraint(equalTo: soundWaveImage.bottomAnchor, constant: 40),
            buttonsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            
        ])
    }
    
    func setupViews() {
        addSubViews()
        setupConstraints()
    }
}

// MARK: - button functions
extension VoiceRecordingViewController {
    
    /// linkar botões com suas ações
    private func setupButtonActions() {
        recordButton.addTarget(self, action: #selector(recordButtonTapped), for: .touchUpInside)
        recordButton.addTarget(self, action: #selector(toggleRecordingAnimation), for: .touchDragEnter)
        finishedAudioButton.addTarget(self, action: #selector(finishButtonTapped), for: .touchUpInside)
        deleteAudioButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }
    
    /// ações dos botões
    @objc private func deleteButtonTapped() {
        showDeleteConfirmationAlert()
    }
       
    @objc private func finishButtonTapped() {
        showFinishConfirmationAlert()
    }
       
    @objc private func recordButtonTapped() {
           switch recordingState {
           case .stopped, .paused:
               startRecording()
           case .recording:
               pauseRecording()
           }
       }
}
