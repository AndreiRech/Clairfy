import AVFoundation
import UIKit 

class PatientAnalysisView: UIView {
    // MARK: - Properties
    var consultation: ConsultationModel?
    weak var delegate: AnalysisViewController?
    var tempoDeRespostaAPI: Bool = false

    internal lazy var patientSummary: TextComponent = {
        let textComponent = TextComponent()
        textComponent.translatesAutoresizingMaskIntoConstraints = false
        textComponent.title = "Resumo da Consulta"
       
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
    
    internal lazy var actionPoints: TextComponent = {
        let textComponent = TextComponent()
        textComponent.translatesAutoresizingMaskIntoConstraints = false
        textComponent.title = "Pontos de Ação"
        
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
       let stackView = UIStackView(arrangedSubviews: [patientSummary, actionPoints])
       stackView.translatesAutoresizingMaskIntoConstraints = false
       stackView.axis = .vertical
       stackView.spacing = 24
       stackView.isHidden = false
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

extension PatientAnalysisView: ViewCodeProtocol {
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

extension PatientAnalysisView {
    @objc private func editButtonTapped(_ sender: UIButton) {
        guard let transcriptionID = self.consultation?.transcription?.id else { return }

        if sender == patientSummary.editButton {
            delegate?.didTapEdit(category: .didctarized, transcriptionID: transcriptionID)
        } else if sender == actionPoints.editButton {
            delegate?.didTapEdit(category: .actionPoints, transcriptionID: transcriptionID)
        } else {
            print("❌ Botão desconhecido")
        }
    }
    
    @objc private func copyButtonTapped(_ sender: UIButton) {
        guard let transcription = self.consultation?.transcription else { return }

        var text: String = ""
        if sender == patientSummary.editButton {
            text = transcription.didctarized
        } else if sender == actionPoints.editButton {
            text = transcription.actionPoints.joined(separator: "\n\n")
        } else { }

        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
            
        if let viewController = self.delegate {
            activityVC.popoverPresentationController?.sourceView = viewController.view
            viewController.present(activityVC, animated: true, completion: nil)
        }
    }
}
