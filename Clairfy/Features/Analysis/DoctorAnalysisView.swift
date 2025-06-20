//
//  Untitled.swift
//  Clairfy
//
//  Created by Bernardo Garcia Fensterseifer on 16/06/25.
//

import AVFoundation
import UIKit

class DoctorAnalysisView: UIView {
    
    // MARK: - Properties
    var consultation: ConsultationModel? {
        didSet {
            updateUI()
            analysisGenerated = consultation?.transcription != nil

        }
    }
    
    private var isLoading: Bool = false {
        didSet {
            updateLoadingState()
        }
    }
    
    private var analysisGenerated: Bool = false {
        didSet {
            updateContentVisibility()
        }
    }
    
    weak var delegate: AnalysisViewController?
    
    // MARK: - UI Components
    private lazy var clinicalSummary: TextComponent = {
        let textComponent = TextComponent()
        textComponent.translatesAutoresizingMaskIntoConstraints = false
        textComponent.title = "Resumo Clínico"
        
        textComponent.editButtonText = "Editar"
        textComponent.editButtonImage = UIImage(systemName: "pencil")
        textComponent.actionButtonText = "Copiar"
        textComponent.actionButtonImage = UIImage(systemName: "doc.on.doc.fill")
        textComponent.editButtonColor = .clairBlue
        textComponent.actionButtonColor = .clairBlue
        textComponent.editButtonIconColor = .tertiarySystemBackground
        textComponent.editButtonLabelColor = .tertiarySystemBackground
        textComponent.actionButtonIconColor = .tertiarySystemBackground
        textComponent.actionButtonLabelColor = .tertiarySystemBackground
        
        textComponent.editButton.addTarget(self, action: #selector(editButtonTapped(_:)), for: .touchUpInside)
        textComponent.actionButton.addTarget(self, action: #selector(copyButtonTapped), for: .touchUpInside)
        
        return textComponent
    }()
    
    private lazy var actionPoints: TextComponent = {
        let textComponent = TextComponent()
        textComponent.translatesAutoresizingMaskIntoConstraints = false
        textComponent.title = "Pontos de Ação"
        
        textComponent.editButtonText = "Editar"
        textComponent.editButtonImage = UIImage(systemName: "pencil")
        textComponent.actionButtonText = "Copiar"
        textComponent.actionButtonImage = UIImage(systemName: "doc.on.doc.fill")
        textComponent.editButtonColor = .clairBlue
        textComponent.actionButtonColor = .clairBlue
        textComponent.editButtonIconColor = .tertiarySystemBackground
        textComponent.actionButtonIconColor = .tertiarySystemBackground
        textComponent.editButtonLabelColor = .tertiarySystemBackground
        textComponent.actionButtonLabelColor = .tertiarySystemBackground
        
        textComponent.editButton.addTarget(self, action: #selector(editButtonTapped(_:)), for: .touchUpInside)

        return textComponent
    }()
    
    private lazy var generateAnalysisButton: GlassButton = {
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
    
    private lazy var loadingView: LoaderView = {
        let view = LoaderView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [clinicalSummary, actionPoints])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.isHidden = true
        return stackView
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        
        updateUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    private func setupViews() {
        addSubview(contentStackView)
        addSubview(generateAnalysisButton)
        addSubview(loadingView)
        
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentStackView.bottomAnchor.constraint(lessThanOrEqualTo: generateAnalysisButton.topAnchor, constant: -24),
            
            generateAnalysisButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            generateAnalysisButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            generateAnalysisButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24),
            
            loadingView.topAnchor.constraint(equalTo: topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    private func updateUI() {
        clinicalSummary.text = consultation?.transcription?.summary ?? "Nenhum resumo disponível"
        actionPoints.text = consultation?.transcription?.actionPoints.joined(separator: "\n\n") ?? "Nenhum ponto de ação disponível"
    }

    private func updateLoadingState() {
        loadingView.isHidden = !isLoading
        generateAnalysisButton.isEnabled = !isLoading
        generateAnalysisButton.alpha = isLoading ? 0.7 : 1.0
    }

    // arrumar - duracao tem q ser de acordo com o tempo de resposta da api
    private func updateContentVisibility() {
        UIView.animate(withDuration: 0.3) {
            self.contentStackView.isHidden = !self.analysisGenerated
            self.contentStackView.alpha = self.analysisGenerated ? 1.0 : 0.0
        }
    }
    
    // MARK: - Button Actions
    @objc private func editButtonTapped(_ sender: UIButton) {
        guard let transcriptionID = self.consultation?.transcription?.id else { return }

        if sender == clinicalSummary.editButton {
            delegate?.didTapEdit(category: .summary, transcriptionID: transcriptionID)
        } else if sender == actionPoints.editButton {
            delegate?.didTapEdit(category: .actionPoints, transcriptionID: transcriptionID)
        } else {
            print("❌ Botão desconhecido")
        }
    }
    
    @objc private func copyButtonTapped() {
        print("Botão Copiar (Médico) pressionado")
    }
    
    var tempoDeRespostaAPI: Bool = false
    
    @objc func gerarAnalise() {
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

}
