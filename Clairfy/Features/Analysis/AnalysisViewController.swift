//
//  AnalysisViewController.swift
//  Clairfy
//
//  Created by Bernardo Garcia Fensterseifer on 12/06/25.
//

import UIKit

class AnalysisViewController: UIViewController {
    
    // MARK: components & variables
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.text = "Análise"
        label.textColor = .label
        return label
    }()
    
    private lazy var segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Médico", "Paciente"])
        control.translatesAutoresizingMaskIntoConstraints = false
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        return control
    }()
    
    private lazy var artificialInteligenceSummary: TextComponent = {
        let textComponent = TextComponent()
        textComponent.translatesAutoresizingMaskIntoConstraints = false
        textComponent.title = "Resumo Clínico"
        textComponent.text = "Paciente Ana Paula, 37 anos, em acompanhamento de hipotireoidismo autoimune. Refere cansaço persistente, ganho de peso (5kg), constipação, sono não reparador e episódios esporádicos de ansiedade. Adere bem à levotiroxina 100mcg. Exame físico normal exceto palpação tireoidiana irregular. Solicitados exames hormonais e vitamínicos."

        // Configuração do botão Editar
        textComponent.editButtonText = "Editar"
        textComponent.editButtonImage = UIImage(systemName: "pencil")
        
        // Configuração do botão Ação
        textComponent.actionButtonText = "Copiar"
        textComponent.actionButtonImage = UIImage(systemName: "doc.on.doc.fill")
        
        // Usando cores personalizadas (opção 1 - contraste automático)
        textComponent.editButtonColor = .clairBlue
        textComponent.actionButtonColor = .clairBlue
        
        // OU usando cores específicas (opção 2 - cores manuais)
         textComponent.editButtonColor = UIColor(named: "clairBlue") ?? .systemBlue
         textComponent.editButtonIconColor = .tertiarySystemBackground
         textComponent.editButtonLabelColor = .tertiarySystemBackground
         textComponent.actionButtonColor = UIColor(named: "clairBlue") ?? .systemBlue
         textComponent.actionButtonIconColor = .tertiarySystemBackground
         textComponent.actionButtonLabelColor = .tertiarySystemBackground

        // Adicionando ações
        textComponent.editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        textComponent.actionButton.addTarget(self, action: #selector(copyButtonTapped), for: .touchUpInside)
        
        return textComponent
    }()
    
    private lazy var audioComponent: AudioComponent = {
            let component = AudioComponent()
            component.translatesAutoresizingMaskIntoConstraints = false
            component.title = "Audio"
            component.date = "10/06/2024 - 21:00"
            component.duration = "00:48:14"
            
            // Configurar cores dos textos
            component.titleColor = .label
            component.dateColor = .secondaryLabel
            component.durationColor = .secondaryLabel
            
            // Configurar cores dos botões
            component.playButtonColor = .clairBlue
            component.trashButtonColor = .clairBlue
            component.shareButtonColor = .clairBlue
            
            // Configurar cores dos ícones
            component.playButtonIconColor = .tertiarySystemBackground
            component.trashButtonIconColor = .tertiarySystemBackground
            component.shareButtonIconColor = .tertiarySystemBackground
            
            // Configurar grossura dos ícones (opções: .ultraLight, .thin, .light, .regular, .medium, .semibold, .bold, .heavy, .black)
            component.playButtonIconWeight = .bold
            component.trashButtonIconWeight = .bold
            component.shareButtonIconWeight = .bold
            
            // Configurar ações dos botões
            component.playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
            component.trashButton.addTarget(self, action: #selector(trashButtonTapped), for: .touchUpInside)
            component.shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
            
            return component
        }()
    
    // MARK: "main"
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        view.backgroundColor = .secondarySystemBackground
    }
    
    // MARK: functions
    
}

// MARK: addViews & setConstraints
extension AnalysisViewController: ViewCodeProtocol {
    
    func addSubViews() {
        view.addSubview(titleLabel)
        view.addSubview(segmentedControl)
        view.addSubview(artificialInteligenceSummary)
        view.addSubview(audioComponent)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            
            /// titleLabel constraints
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            /// segmentedControl constraints
            segmentedControl.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            /// audioComponent constraints
            audioComponent.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20),
            audioComponent.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            audioComponent.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            /// artificialInteligenceSummary constraints
            artificialInteligenceSummary.topAnchor.constraint(equalTo: audioComponent.bottomAnchor, constant: 20),
            artificialInteligenceSummary.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            artificialInteligenceSummary.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
            
        ])
    }
    
    func setupViews() {
        addSubViews()
        setupConstraints()
    }
}

// MARK: button functions
extension AnalysisViewController {
    
    /// linkar botões com suas ações
    private func setupButtonActions() {
        
    }
    
    /// ações dos botões
    @objc private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        print("Segmento selecionado: \(sender.selectedSegmentIndex)")
        // adicionar a lógica para quando o segmento é alterado
    }
    
    @objc private func editButtonTapped(_ sender: UISegmentedControl) {
        print("Edit button selecionado")
        // adicionar a lógica para quando o botao de editar é apertado
    }
    
    @objc private func copyButtonTapped(_ sender: UISegmentedControl) {
        print("Copy button selecionado")
        // adicionar a lógica para quando o botao de copiar é apertado
    }
    
    @objc private func playButtonTapped() {
        print("Play button tapped")
    }

    @objc private func trashButtonTapped() {
        print("Trash button tapped")
    }

    @objc private func shareButtonTapped() {
        print("Share button tapped")
    }
    
}
