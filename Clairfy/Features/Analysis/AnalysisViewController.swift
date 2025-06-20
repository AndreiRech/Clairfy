//
//  AnalysisViewController.swift
//  Clairfy
//
//  Created by Bernardo Garcia Fensterseifer on 12/06/25.
//

import AVFoundation
import UIKit

class AnalysisViewController: UIViewController {
    // MARK: Subviews
    private lazy var segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Médico", "Paciente"])
        control.translatesAutoresizingMaskIntoConstraints = false
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        return control
    }()
    
    private lazy var audioComponent: AudioComponent = {
        let component = AudioComponent()
        component.translatesAutoresizingMaskIntoConstraints = false
        component.title = consultation?.title
        component.date = consultation?.date.formatDate()
        component.duration = "00:48:14"
        component.audioPath = consultation?.audio?.audioPath
            
        // Configurar cores
        component.titleColor = .label
        component.dateColor = .secondaryLabel
        component.durationColor = .secondaryLabel
        component.playButtonColor = .clairBlue
        component.trashButtonColor = .clairBlue
        component.shareButtonColor = .clairBlue
        component.playButtonIconColor = .tertiarySystemBackground
        component.trashButtonIconColor = .tertiarySystemBackground
        component.shareButtonIconColor = .tertiarySystemBackground
        component.trashButtonIconWeight = .bold
        component.shareButtonIconWeight = .bold
            
        // Configurar ações
        component.playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        component.trashButton.addTarget(self, action: #selector(trashButtonTapped), for: .touchUpInside)
        component.shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
            
        return component
    }()
    
    private lazy var doctorView: DoctorAnalysisView = {
        let view = DoctorAnalysisView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.consultation = consultation
        return view
    }()
    
    private lazy var patientView: PatientAnalysisView = {
        let view = PatientAnalysisView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.consultation = consultation
        return view
    }()
    
    private lazy var loader = LoaderView()
    
    // MARK: Properties
    var consultation: ConsultationModel? {
        didSet {
            doctorView.consultation = consultation
            patientView.consultation = consultation
            audioComponent.audioPath = consultation?.audio?.audioPath
        }
    }
    
    private var audioPlayer: AVAudioPlayer?
    private var isPlaying = false
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        additionalSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let consultationID = consultation?.id else { return }

           let updatedConsultation = Persistence.shared.getConsultation(by: consultationID)
           self.consultation = updatedConsultation
    }
    
    // MARK: Setup
    func additionalSetup() {
        view.backgroundColor = .secondarySystemBackground
        navigationItem.title = "Análise"
        navigationController?.navigationBar.prefersLargeTitles = false
        segmentedControlValueChanged(segmentedControl)
        
        setConsultationTime()
    }
    
    private func setConsultationTime() {
        guard let audioPath = consultation?.audio?.audioPath else { return }

        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = documents.appendingPathComponent(audioPath)

        guard FileManager.default.fileExists(atPath: url.path) else {
            print("❌ Arquivo não encontrado: \(url.path)")
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            let durationInSeconds = player.duration

            let hours = Int(durationInSeconds) / 3600
            let minutes = (Int(durationInSeconds) % 3600) / 60
            let seconds = Int(durationInSeconds) % 60
            let formattedDuration = String(format: "%02d:%02d:%02d", hours, minutes, seconds)

            audioComponent.duration = formattedDuration
        } catch {
            print("❌ Erro ao carregar áudio: \(error)")
            audioComponent.duration = "00:00:00"
        }
    }
}

// MARK: - ViewCodeProtocol
extension AnalysisViewController: ViewCodeProtocol {
    func addSubViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(segmentedControl)
        contentView.addSubview(audioComponent)
        contentView.addSubview(doctorView)
        contentView.addSubview(patientView)
    }
    
    func setupConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])

        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            segmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            audioComponent.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20),
            audioComponent.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            audioComponent.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            doctorView.topAnchor.constraint(equalTo: audioComponent.bottomAnchor, constant: 20),
            doctorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            doctorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            doctorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32),
            
            patientView.topAnchor.constraint(equalTo: audioComponent.bottomAnchor, constant: 20),
            patientView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            patientView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            patientView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
        
        // Configuração inicial
        doctorView.isHidden = false
        patientView.isHidden = true
    }
}

// MARK: - Actions
extension AnalysisViewController {
    @objc private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: // Médico
            doctorView.isHidden = false
            patientView.isHidden = true
        case 1: // Paciente
            doctorView.isHidden = true
            patientView.isHidden = false
        default:
            break
        }
    }
    
    private func updatePlayIcon(to state: PlayButtonState) {
        let iconName: String
        
        switch state {
        case .play:
            iconName = "play.fill"
            let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
            let image = UIImage(systemName: iconName, withConfiguration: config)
            audioComponent.playButtonIconColor = .tertiarySystemBackground
            audioComponent.playButtonView.backgroundColor = .clairBlue
            audioComponent.playButton.setImage(image, for: .normal)
        case .pause:
            iconName = "pause.fill"
            let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
            let image = UIImage(systemName: iconName, withConfiguration: config)
            audioComponent.playButtonIconColor = .tertiarySystemBackground
            audioComponent.playButtonView.backgroundColor = .clairBlue
            audioComponent.playButton.setImage(image, for: .normal)
            audioComponent.playButton.tintColor = .tertiarySystemBackground
        }
    }
    
    @objc private func playButtonTapped() {
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

    @objc private func trashButtonTapped() {
        print("Trash button tapped")
    }

    @objc private func shareButtonTapped() {
        print("Share button tapped")
    }
    
    enum PlayButtonState {
        case play
        case pause
    }
}

// MARK: - AVAudioPlayerDelegate
extension AnalysisViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        audioComponent.playButtonState = .play
        isPlaying = false
        print("✅ Áudio terminou de tocar")
    }
}
