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
    
    lazy var recordingTapArea: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleRecordingImageTap), for: .touchUpInside)
        return button
    }()
    
    lazy var timerLabel: UILabel = {
        var label = UILabel()
        label.text = "00:00:00"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 42, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var visualizerView: AudioVisualizerComponent = {
        let v = AudioVisualizerComponent()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    lazy var recordButton: UIButton = {
        var button = UIButton()
        button.backgroundColor = .clairBlue
        button.translatesAutoresizingMaskIntoConstraints = false

        DispatchQueue.main.async {
            let iconSize = button.bounds.width * 0.4
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
        button.layer.cornerRadius = 28
        button.layer.masksToBounds = true
        button.backgroundColor = .label
        button.tintColor = .systemBackground
        
        DispatchQueue.main.async {
            let iconSize = button.bounds.width * 0.5
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: iconSize, weight: .heavy)
            let playImage = UIImage(systemName: "trash.fill", withConfiguration: symbolConfig)
            button.setImage(playImage, for: .normal)
        }

        return button
    }()
    
    lazy var finishedAudioButton: UIButton = {
        var button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 28
        button.layer.masksToBounds = true
        button.backgroundColor = .label
        button.tintColor = .systemBackground
        
        DispatchQueue.main.async {
            let iconSize = button.bounds.width * 0.5
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
    
    lazy var bottomStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [timerLabel, visualizerView, buttonsStackView])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .equalSpacing
        return stack
    }()
    
    // MARK: Proprieties
    var startingRecording: Bool = false
    
    private lazy var recorder: AudioRecordManager = {
        return AudioRecordManager(voiceRecordVC: self)
    }()
   
    // MARK: Init
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        recorder.resetRecording()
        recorder.disableButtonInteraction()
    }
    
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
        
        visualizerView.drawVisualizerCircles()
        recorder.audioMeteringDelegate = visualizerView
        
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
        view.addSubview(recordingTapArea)
        view.addSubview(bottomStack)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            recordingImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            recordingImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recordingImage.widthAnchor.constraint(equalToConstant: 328),
            recordingImage.heightAnchor.constraint(equalToConstant: 328),
            
            recordingTapArea.topAnchor.constraint(equalTo: recordingImage.topAnchor),
            recordingTapArea.bottomAnchor.constraint(equalTo: recordingImage.bottomAnchor),
            recordingTapArea.leadingAnchor.constraint(equalTo: recordingImage.leadingAnchor),
            recordingTapArea.trailingAnchor.constraint(equalTo:recordingImage.trailingAnchor),
            
            bottomStack.topAnchor.constraint(equalTo: recordingTapArea.bottomAnchor, constant: 64),
            bottomStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bottomStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            
            visualizerView.heightAnchor.constraint(equalToConstant: 100),
            visualizerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            
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
   
    private func toggleWaveform(visible: Bool) {
        visualizerView.removeVisualizerCircles()
        visualizerView.isHidden = false
    }
    
    @objc func deleteButtonTapped() {
        recorder.showDeleteConfirmationAlert()
    }
       
    @objc func finishButtonTapped() {
        if recorder.elapsedTime < 30 {
            recorder.showTooShortAlert()
        } else {
            recorder.showFinishConfirmationAlert()
        }
    }
       
    @objc func recordButtonTapped() {
        switch recorder.recordingState {
        case .stopped:
            recorder.startRecording()
        case .paused:
            recorder.resumeRecording()
        case .recording:
            recorder.pauseRecording()
        }
    }
    
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
    
    
    @objc func handleRecordingImageTap() {
        recordButtonTapped()
    }
}
