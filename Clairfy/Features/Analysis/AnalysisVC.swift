import AVFoundation
import UIKit

class AnalysisViewController: UIViewController {
    // MARK: SubViews
    internal lazy var generateAnalysisButton: ButtonComponent = {
        let button = ButtonComponent()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.text = "Gerar Análise"
        button.font = Fonts.title1
        button.cornerRadius = 24
        
        button.addTarget(self, action: #selector(gerarAnalise), for: .touchUpInside)
        return button
    }()
    
    internal var analysisGenerated: Bool = false {
        didSet {
            updateContentVisibility()
        }
    }
    
    internal var isLoading: Bool = false {
        didSet {
            updateLoadingState()
        }
    }
    
    internal lazy var loadingView: LoaderView = {
        let view = LoaderView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    internal lazy var audioComponent: AudioComponent = {
        let component = AudioComponent()
        component.translatesAutoresizingMaskIntoConstraints = false
        component.title = consultation?.title
        component.date = consultation?.date.formatDate()
        component.duration = "00:48:14"
        component.audioPath = consultation?.audio?.audioPath
        component.playbutton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
            
        return component
    }()
    
    internal lazy var loader = LoaderView()
    
    internal var audioPlayer: AVAudioPlayer?
    
    internal var isPlaying = false
    
    internal let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.showsVerticalScrollIndicator = false
        return view
    }()

    internal lazy var contentView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [segmentedControl, audioComponent, doctorView, patientView])
        view.axis = .vertical
        view.spacing = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    internal lazy var segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Médico", "Paciente"])
        control.translatesAutoresizingMaskIntoConstraints = false
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        return control
    }()
    
    lazy var doctorView: DoctorAnalysisView = {
        let view = DoctorAnalysisView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.consultation = consultation
        view.delegate = self
        return view
    }()
    
    lazy var patientView: PatientAnalysisView = {
        let view = PatientAnalysisView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.consultation = consultation
        view.delegate = self
        return view
    }()
    
    // MARK: Properties
    var consultation: ConsultationModel? {
        didSet {
            doctorView.consultation = consultation
            patientView.consultation = consultation
            audioComponent.audioPath = consultation?.audio?.audioPath
            
            guard let audioPath = consultation?.audio?.audioPath else { return }
            let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let url = documents.appendingPathComponent(audioPath)

            audioComponent.soundWaveImageView.configure(with: url, color: .clairBlue)
            updateUI()
            analysisGenerated = consultation?.transcription != nil
        }
    }
    
    // MARK: Init
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        additionalSetup()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        audioComponent.stopAudio()
    }
    
    // MARK: Functions
    private func additionalSetup() {
        view.backgroundColor = .secondarySystemBackground
        navigationItem.title = "Análise"
        navigationController?.navigationBar.prefersLargeTitles = true
        segmentedControlValueChanged(segmentedControl)
        
        setConsultationTime()
        updateContent()
        setupLongPressGesture()
        
        audioComponent.playbutton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
    }
    
    private func renameAudio(name: String) {
        guard let consultation = self.consultation else { return }
        
        self.audioComponent.title = name
        let id = consultation.id
        
        let consultationModel = ConsultationModel(id: id, title: name, date: consultation.date, audio: consultation.audio, transcription: consultation.transcription)

        _ = Persistence.shared.updateConsultation(consultationModel, transcription: consultation.transcription, audio: consultation.audio)
        
        self.consultation = Persistence.shared.getConsultation(by: consultation.id)
    }
    
    private func setupLongPressGesture() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressOnAudioComponent(_:)))
        audioComponent.addGestureRecognizer(longPress)
    }
    
    internal func updateUI() {
        doctorView.clinicalSummary.text = consultation?.transcription?.summary ?? "Nenhum resumo disponível"
        doctorView.keyWords.text = consultation?.transcription?.keyWords.joined(separator: "\n\n") ?? "Nenhuma palavra-chave disponível"
        patientView.patientSummary.text = consultation?.transcription?.didctarized ?? "Nenhum resumo disponível"
        patientView.actionPoints.text = consultation?.transcription?.actionPoints.joined(separator: "\n\n") ?? "Nenhum ponto de ação disponível"
        audioComponent.title = consultation?.title
    }
        
    internal func updateLoadingState() {
        loadingView.isHidden = !isLoading
        generateAnalysisButton.isEnabled = !isLoading
        generateAnalysisButton.alpha = isLoading ? 0.7 : 1.0
        doctorView.isHidden = isLoading
        patientView.isHidden = isLoading
    }
    
    internal func updateContentVisibility() {
        UIView.animate(withDuration: 0.3) {
            let visible = self.analysisGenerated
            self.doctorView.contentStackView.isHidden = !visible
            
            if self.segmentedControl.selectedSegmentIndex == 0 {
                self.patientView.isHidden = true
            } else {
                self.patientView.isHidden = false
            }
        }
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
    
    private func updateContent() {
        guard let consultationID = consultation?.id else { return }

        let updatedConsultation = Persistence.shared.getConsultation(by: consultationID)
        self.consultation = updatedConsultation
    }
    
    func didTapEdit(category: TranscriptionEnum, transcriptionID: UUID?) {
        let editVC = AnalysisEditViewController()
        editVC.transcriptionID = transcriptionID
        editVC.category = category
        editVC.delegate = self

        let navController = UINavigationController(rootViewController: editVC)
                
        if let sheet = navController.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }

        self.present(navController, animated: true)
    }
    
    func didFinishEditing() {
        updateContent()
    }
 }
    
extension AnalysisViewController: ViewCodeProtocol {
    func addSubViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        view.addSubview(loadingView)
        view.addSubview(generateAnalysisButton)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            // ScrollView ocupa a tela toda, mas com espaço pro botão
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            scrollView.bottomAnchor.constraint(equalTo: generateAnalysisButton.topAnchor, constant: -16),

            // ContentView dentro da scrollView
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // LoadingView
            loadingView.topAnchor.constraint(equalTo: audioComponent.bottomAnchor, constant: 150),
            loadingView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),

            // Botão fixo no final da tela
            generateAnalysisButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            generateAnalysisButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            generateAnalysisButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            generateAnalysisButton.heightAnchor.constraint(equalToConstant: 66)
        ])
    }

}

extension AnalysisViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        audioComponent.playButtonState = .play
        audioComponent.resetWaveformProgress()
    }
}

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
    
    @objc internal func playButtonTapped() {
        if audioComponent.audioPlayer?.isPlaying == true {
                audioComponent.pauseAudio()
                audioComponent.playButtonState = .play
                print("⏸ Áudio pausado")
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

        // Reseta o progresso da waveform antes de tocar novamente
            audioComponent.soundWaveImageView.resetWaveformProgress()

            // Configura e toca via AudioComponent (centraliza tudo lá)
            audioComponent.preparePlayback(with: url)
            audioComponent.playAudio()
            audioComponent.playButtonState = .pause
            print("▶️ Áudio iniciado via AudioComponent")
    }

    @objc internal func trashButtonTapped() {
        print("Trash button tapped")
    }

    @objc internal func shareButtonTapped() {
        print("Share button tapped")
    }
    
    @objc private func handleLongPressOnAudioComponent(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }

        let alert = UIAlertController(
            title: "Renomear Áudio",
            message: "Digite o novo nome do áudio:",
            preferredStyle: .alert
        )

        alert.addTextField { textField in
            textField.text = self.audioComponent.title
            textField.placeholder = "Novo nome"
        }

        let renameAction = UIAlertAction(title: "Renomear", style: .default) { _ in
            if let newName = alert.textFields?.first?.text, !newName.isEmpty {
                self.renameAudio(name: newName)
            }
        }

        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel)

        alert.addAction(renameAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }
}

extension AnalysisViewController: AudioComponentDelegate {
    func audioComponentDidFinishPlaying(_ component: AudioComponent) {
        audioComponent.playButtonState = .play
        audioComponent.soundWaveImageView.progress = 1.0
        print("🔁 Áudio finalizado, resetando estado")
    }
}
