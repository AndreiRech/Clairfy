import UIKit

class AnalysisEditViewController: UIViewController {
    // MARK: Subviews
    lazy var closeButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(image: UIImage(systemName: "xmark"),
                               style: .plain,
                               target: self,
                               action: #selector(closeButtonTapped))
    }()
    
    lazy var saveButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(image: UIImage(systemName: "checkmark"),
                               style: .plain,
                               target: self,
                               action: #selector(saveButtonTapped))
    }()
    
    lazy var titleLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Fonts.body
        label.textColor = .label
        label.text = "Título"
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return label
    }()
    
    lazy var separator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .tertiarySystemGroupedBackground
        return view
    }()
    
    lazy var textField: UITextView = {
        let textField = UITextView()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = Fonts.body
        textField.textColor = .label
        textField.text = "Insira seu título"
        textField.backgroundColor = .secondarySystemBackground
        return textField
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, separator, textField])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.backgroundColor = .secondarySystemBackground
        stackView.layer.cornerRadius = 24
        stackView.layer.masksToBounds = true
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 16, left: 24, bottom: 16, right: 0)
        return stackView
    }()
    
    // MARK: Initializers
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        additionalSetup()
    }
    
    // MARK: Properties
    var transcriptionID: UUID?
    var category: TranscriptionEnum?
    weak var delegate: AnalysisViewController?
    
    // MARK: Functions
    private func additionalSetup() {
        title = "Detalhes"
        
        setupInfo()
        
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.rightBarButtonItem = saveButtonItem
        navigationItem.leftBarButtonItem = closeButtonItem
        
        view.backgroundColor = .tertiarySystemBackground
    }
    
    private func setupInfo()  {
        guard
            let category = self.category,
            let transcriptionID = self.transcriptionID,
            let transcription = Persistence.shared.getTranscription(by: transcriptionID)
        else { return }
        
        switch category {
        case .transcription:
            titleLabel.text = "Resumo"
            textField.text = transcription.transcription
        case .summary:
            titleLabel.text = "Resumo da Consulta"
            textField.text = transcription.summary
        case .didctarized:
            titleLabel.text = "Resumo Cliníco"
            textField.text = transcription.didctarized
        case .keyWords:
            titleLabel.text = "Palavras Chave"
            textField.text = transcription.keyWords.joined(separator: "\n\n")
        case .actionPoints:
            titleLabel.text = "Pontos de Ação"
            textField.text = transcription.actionPoints.joined(separator: "\n\n")
        }
    }
    
    private func saveTranscription() {
        guard
            let category = self.category,
            let transcriptionID = self.transcriptionID,
            let transcription = Persistence.shared.getTranscription(by: transcriptionID)
        else { return }

        let fallbackText: String?
        switch category {
        case .transcription:
            fallbackText = transcription.transcription
        case .summary:
            fallbackText = transcription.summary
        case .didctarized:
            fallbackText = transcription.didctarized
        case .keyWords:
            fallbackText = transcription.keyWords.joined(separator: "\n\n")
        case .actionPoints:
            fallbackText = transcription.actionPoints.joined(separator: "\n\n")
        }

        guard let text = (textField.text?.isEmpty == false ? textField.text : fallbackText) else { return }

        let newTranscription = TranscriptionModel(
            id: transcriptionID,
            transcription: category == .transcription ? text : transcription.transcription,
            summary: category == .summary ? text : transcription.summary,
            didctarized: category == .didctarized ? text : transcription.didctarized,
            keyWords: category == .keyWords ? text.components(separatedBy: "\n\n") : transcription.keyWords,
            actionPoints: category == .actionPoints ? text.components(separatedBy: "\n\n") : transcription.actionPoints
        )

        _ = Persistence.shared.updateTranscription(newTranscription)
    }

}

extension AnalysisEditViewController: ViewCodeProtocol {
    func addSubViews() {
        view.addSubview(stackView)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            separator.heightAnchor.constraint(equalToConstant: 1),
            textField.heightAnchor.constraint(equalToConstant: 200),
        ])
    }
}

extension AnalysisEditViewController {
    @objc func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc func saveButtonTapped() {
        saveTranscription()
        delegate?.didFinishEditing()
        dismiss(animated: true)
    }
}
