import UIKit
import AVFoundation

class VoiceRecordingViewController: UIViewController, AVAudioRecorderDelegate {
    // MARK: Subviews
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
    
    // MARK: Proprieties
    private lazy var recorder: AudioRecordManager = {
        return AudioRecordManager(voiceRecordVC: self)
    }()
    
    var startingRecording: Bool = false
    
    // MARK: Init
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        additionalSetup()
    }
    
    // MARK: Functions
    private func additionalSetup() {
        title = "Gravação de Áudio"
        view.backgroundColor = .secondarySystemBackground
                
        setupButtonActions()
        recorder.updateTimerLabel()
        
        navigationController?.navigationBar.prefersLargeTitles = false
        
        if startingRecording {
            recordButtonTapped()
            startingRecording = false
        }
    }
}

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
            buttonsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            recordButton.widthAnchor.constraint(equalToConstant: 92),
            recordButton.heightAnchor.constraint(equalToConstant: 92),
            
            deleteAudioButton.widthAnchor.constraint(equalToConstant: 56),
            deleteAudioButton.heightAnchor.constraint(equalToConstant: 56),
            
            finishedAudioButton.widthAnchor.constraint(equalToConstant: 56),
            finishedAudioButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
}

extension VoiceRecordingViewController {
    private func setupButtonActions() {
        recordButton.addTarget(self, action: #selector(recordButtonTapped), for: .touchUpInside)
        recordButton.addTarget(self, action: #selector(toggleRecordingAnimation), for: .touchDragEnter)
        finishedAudioButton.addTarget(self, action: #selector(finishButtonTapped), for: .touchUpInside)
        deleteAudioButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }
    
    @objc func deleteButtonTapped() {
        recorder.showDeleteConfirmationAlert()
    }
       
    @objc func finishButtonTapped() {
        recorder.showFinishConfirmationAlert()
    }
       
    @objc func recordButtonTapped() {
        switch recorder.recordingState {
        case .stopped:
            recorder.startRecording()
            recorder.audioRecorder?.record()
        case .paused:
            recorder.audioRecorder?.record()
            recorder.updateRecordButtonIcon()
               
            recorder.timer = Timer.scheduledTimer(
                timeInterval: 0.01,
                target: self,
                selector: #selector(updateTimer),
                userInfo: nil,
                repeats: true
            )
            
            recorder.startRecordingAnimation()
        case .recording:
            recorder.pauseRecording()
            recorder.audioRecorder?.pause()
            recorder.timer?.invalidate()
            recorder.timer = nil

        }
    }
    
    // Função para iniciar/parar a animação
    @objc func toggleRecordingAnimation() {
            if recorder.recordingState == .recording {
                recorder.startRecordingAnimation()
            } else {
                recorder.stopRecordingAnimation()
            }
            recorder.audioRecorder?.stop()
            recorder.audioRecorder = nil
            
            do {
                try AVAudioSession.sharedInstance().setActive(false)
            } catch {
                print("Erro ao desativar sessão de áudio: \(error.localizedDescription)")
            }
        }
    
    @objc func updateTimer() {
        recorder.elapsedTime += 0.01
        recorder.updateTimerLabel()
    }
}
