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
    var consultation: ConsultationModel?
    weak var delegate: AnalysisViewController?
    var tempoDeRespostaAPI: Bool = false
    
    // MARK: - UI Components
    internal lazy var clinicalSummary: TextComponent = {
        let textComponent = TextComponent()
        textComponent.translatesAutoresizingMaskIntoConstraints = false
        textComponent.title = "Resumo Clínico"
        
        textComponent.editButtonText = "Editar"
        textComponent.editButtonImage = UIImage(systemName: "pencil")
        textComponent.actionButtonText = "Compartilhar"
        textComponent.actionButtonImage = UIImage(systemName: "square.and.arrow.up.fill")
        textComponent.editButtonColor = .clairBlue
        textComponent.actionButtonColor = .clairBlue
        textComponent.editButtonIconColor = .tertiarySystemBackground
        textComponent.editButtonLabelColor = .tertiarySystemBackground
        textComponent.actionButtonIconColor = .tertiarySystemBackground
        textComponent.actionButtonLabelColor = .tertiarySystemBackground
        
        textComponent.editButton.addTarget(self, action: #selector(editButtonTapped(_:)), for: .touchUpInside)
        textComponent.actionButton.addTarget(self, action: #selector(copyButtonTapped(_:)), for: .touchUpInside)
        
        return textComponent
    }()
    
    internal lazy var keyWords: TextComponent = {
        let textComponent = TextComponent()
        textComponent.translatesAutoresizingMaskIntoConstraints = false
        textComponent.title = "Palavras Chave"
        
        textComponent.editButtonText = "Editar"
        textComponent.editButtonImage = UIImage(systemName: "pencil")
        textComponent.actionButtonText = "Compartilhar"
        textComponent.actionButtonImage = UIImage(systemName: "square.and.arrow.up.fill")
        textComponent.editButtonColor = .clairBlue
        textComponent.actionButtonColor = .clairBlue
        textComponent.editButtonIconColor = .tertiarySystemBackground
        textComponent.actionButtonIconColor = .tertiarySystemBackground
        textComponent.editButtonLabelColor = .tertiarySystemBackground
        textComponent.actionButtonLabelColor = .tertiarySystemBackground
        
        textComponent.editButton.addTarget(self, action: #selector(editButtonTapped(_:)), for: .touchUpInside)
        textComponent.actionButton.addTarget(self, action: #selector(copyButtonTapped(_:)), for: .touchUpInside)
        return textComponent
    }()

    internal lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [clinicalSummary, keyWords])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.isHidden = true
        return stackView
    }()
    
    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DoctorAnalysisView: ViewCodeProtocol {
    func addSubViews() {
        addSubview(contentStackView)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

extension DoctorAnalysisView {
    @objc private func editButtonTapped(_ sender: UIButton) {
        guard let transcriptionID = self.consultation?.transcription?.id else { return }

        if sender == clinicalSummary.editButton {
            delegate?.didTapEdit(category: .summary, transcriptionID: transcriptionID)
        } else if sender == keyWords.editButton {
            delegate?.didTapEdit(category: .keyWords, transcriptionID: transcriptionID)
        } else {
            print("❌ Botão desconhecido")
        }
    }
    
    @objc private func copyButtonTapped(_ sender: UIButton) {
        guard let transcription = self.consultation?.transcription else { return }

        var text: String = ""
        if sender == clinicalSummary.editButton {
            text = transcription.summary
        } else if sender == keyWords.editButton {
            text = transcription.keyWords.joined(separator: "\n\n")
        } else { }

        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
            
        if let viewController = self.delegate {
            activityVC.popoverPresentationController?.sourceView = viewController.view
            viewController.present(activityVC, animated: true, completion: nil)
        }
    }
}
