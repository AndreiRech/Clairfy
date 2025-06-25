import AVFoundation
import UIKit

class AnalysisViewController: UIViewController {
    // MARK: SubViews

    internal lazy var generateAnalysisButton: GlassButton = {
        let button = GlassButton()
        button.translatesAutoresizingMaskIntoConstraints = false

        button.buttonText = "Gerar Análise"
        button.textColor = .clairBlue
        button.fontSize = 22
        button.fontWeight = .semibold
        button.blurOpacity = 0.35
        button.glassBorderWidth = 1.0
        button.cornerRadius = 24
        button.heightAnchor.constraint(equalToConstant: 56).isActive = true

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
        component.delegate = self

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

    // MARK: Functions
    private func additionalSetup() {
        view.backgroundColor = .secondarySystemBackground
        navigationItem.title = "Análise"
        navigationController?.navigationBar.prefersLargeTitles = true
        segmentedControlValueChanged(segmentedControl)

        setConsultationTime()
        updateContent()

        // Garantir target do botão play
        audioComponent.playbutton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
    }

    internal func updateUI() {
        doctorView.clinicalSummary.text = consultation?.transcription?.summary ?? "Nenhum resumo disponível"
        doctorView.keyWords.text = consultation?.transcription?.keyWords.joined(separator: "\n\n") ?? "Nenhuma palavra-chave disponível"
        patientView.patientSummary.text = consultation?.transcription?.didctarized ?? "Nenhum resumo disponível"
        patientView.actionPoints.text = consultation?.transcription?.actionPoints.joined(separator: "\n\n") ?? "Nenhum ponto de ação disponível"
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

// MARK: - ViewCodeProtocol
extension AnalysisViewController: ViewCodeProtocol {
    func addSubViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        view.addSubview(loadingView)
        view.addSubview(generateAnalysisButton)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            scrollView.bottomAnchor.constraint(equalTo: generateAnalysisButton.topAnchor, constant: -16),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            loadingView.topAnchor.constraint(equalTo: audioComponent.bottomAnchor, constant: 150),
            loadingView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),

            generateAnalysisButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            generateAnalysisButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            generateAnalysisButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            generateAnalysisButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
}


// MARK: - AudioComponentDelegate
extension AnalysisViewController: AudioComponentDelegate {
    func audioComponentDidFinishPlaying(_ component: AudioComponent) {
        audioComponent.playButtonState = .play
        audioComponent.soundWaveImageView.progress = 1.0
        print("🔁 Áudio finalizado, resetando estado")
    }
}

// MARK: - AVAudioPlayerDelegate (não é mais necessário aqui se seu player está dentro do AudioComponent, mas mantive se quiser)
extension AnalysisViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        audioComponent.playButtonState = .play
        audioComponent.resetWaveformProgress()
        print("🔁 Áudio finalizado, resetando estado")
    }
}
