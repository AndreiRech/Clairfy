//
//  wef.swift
//  Clairfy
//
//  Created by Bernardo Garcia Fensterseifer on 16/06/25.
//

import AVFoundation
import UIKit

class PatientAnalysisView: UIView {
    
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
    
    // MARK: - UI Components
    private lazy var patientSummary: TextComponent = {
        let textComponent = TextComponent()
        textComponent.translatesAutoresizingMaskIntoConstraints = false
        textComponent.title = "Resumo da Consulta"
        
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
        
        textComponent.editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        textComponent.actionButton.addTarget(self, action: #selector(copyButtonTapped), for: .touchUpInside)
        
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
                
        return button
    }()
    
    private lazy var loadingView: LoaderView = {
        let view = LoaderView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [patientSummary])
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
        patientSummary.text = consultation?.transcription?.didctarized ?? "Nenhum resumo disponível"
    }
    
    private func updateLoadingState() {
        loadingView.isHidden = !isLoading
        generateAnalysisButton.isEnabled = !isLoading
        generateAnalysisButton.alpha = isLoading ? 0.7 : 1.0
    }
    
    private func updateContentVisibility() {
        UIView.animate(withDuration: 0.3) {
            self.contentStackView.isHidden = !self.analysisGenerated
            self.contentStackView.alpha = self.analysisGenerated ? 1.0 : 0.0
        }
    }
    
    // MARK: - Button Actions
    @objc private func editButtonTapped() {
        print("Botão Editar (Paciente) pressionado")
    }
    
    @objc private func copyButtonTapped() {
        print("Botão Copiar (Paciente) pressionado")
    }
}


//import AVFoundation
//import UIKit
//
//class PatientAnalysisView: UIView {
//    
//    // MARK: - Properties
//    var consultation: ConsultationModel? {
//        didSet {
//            updateUI()
//        }
//    }
//    
//    private var isLoading: Bool = false {
//        didSet {
//            updateLoadingState()
//        }
//    }
//    
//    private var analysisGenerated: Bool = false {
//        didSet {
//            updateContentVisibility()
//        }
//    }
//    
//    // MARK: - UI Components
//    private lazy var patientSummary: TextComponent = {
//        let textComponent = TextComponent()
//        textComponent.translatesAutoresizingMaskIntoConstraints = false
//        textComponent.title = "Resumo da Consulta"
//        
//        textComponent.actionButtonText = "Copiar"
//        textComponent.actionButtonImage = UIImage(systemName: "doc.on.doc.fill")
//        textComponent.actionButtonColor = .clairBlue
//        textComponent.actionButtonIconColor = .tertiarySystemBackground
//        textComponent.actionButtonLabelColor = .tertiarySystemBackground
//        textComponent.actionButton.addTarget(self, action: #selector(copyButtonTapped), for: .touchUpInside)
//        
//        textComponent.editButtonText = "Editar"
//        textComponent.editButtonImage = UIImage(systemName: "pencil")
//        textComponent.editButtonColor = .clairBlue
//        textComponent.editButtonIconColor = .tertiarySystemBackground
//        textComponent.editButtonLabelColor = .tertiarySystemBackground
//        
//        textComponent.isHidden = true
//        textComponent.alpha = 0.0
//        
//        return textComponent
//    }()
//    
//    private lazy var generateAnalysisButton: GlassButton = {
//        let button = GlassButton()
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.buttonText = "Gerar Análise"
//        button.textColor = .clairBlue
//        button.fontSize = 22
//        button.fontWeight = .semibold
//        button.blurOpacity = 0.35
//        button.glassBorderWidth = 1.0
//        button.cornerRadius = 24
//        button.heightAnchor.constraint(equalToConstant: 56).isActive = true
////        button.addTarget(self, action: #selector(generateAnalysisTapped), for: .touchUpInside)
//        return button
//    }()
//    
//    private lazy var loadingView: LoaderView = {
//        let view = LoaderView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.isHidden = true
//        return view
//    }()
//    
//    // MARK: - Initialization
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupViews()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    // MARK: - Setup
//    private func setupViews() {
//        addSubview(patientSummary)
//        addSubview(generateAnalysisButton)
//        addSubview(loadingView)
//        
//        NSLayoutConstraint.activate([
//            patientSummary.topAnchor.constraint(equalTo: topAnchor),
//            patientSummary.leadingAnchor.constraint(equalTo: leadingAnchor),
//            patientSummary.trailingAnchor.constraint(equalTo: trailingAnchor),
//            
//            generateAnalysisButton.leadingAnchor.constraint(equalTo: leadingAnchor),
//            generateAnalysisButton.trailingAnchor.constraint(equalTo: trailingAnchor),
//            generateAnalysisButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -24),
//            
//            loadingView.topAnchor.constraint(equalTo: topAnchor),
//            loadingView.leadingAnchor.constraint(equalTo: leadingAnchor),
//            loadingView.trailingAnchor.constraint(equalTo: trailingAnchor),
//            loadingView.bottomAnchor.constraint(equalTo: bottomAnchor)
//        ])
//    }
//    
//    // MARK: - UI Updates
//    private func updateUI() {
//        patientSummary.text = consultation?.transcription?.summary ?? "Nenhum resumo disponível"
//    }
//    
//    // mostra o loading
//    private func updateLoadingState() {
//        loadingView.isHidden = !isLoading
//        generateAnalysisButton.isEnabled = !isLoading
//        generateAnalysisButton.alpha = isLoading ? 0.7 : 1.0
//    }
//    
//    // mostra a resposta da IA
//    private func updateContentVisibility() {
//        UIView.animate(withDuration: 0.3) {
//            self.patientSummary.isHidden = !self.analysisGenerated
//            self.patientSummary.alpha = self.analysisGenerated ? 1.0 : 0.0
//        }
//    }
//    
//    // MARK: - Actions
//    @objc private func copyButtonTapped() {
//        print("Botão Copiar (Paciente) pressionado")
//    }
//}
