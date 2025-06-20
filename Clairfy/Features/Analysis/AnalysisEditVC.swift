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
        view.backgroundColor = .separator
        return view
    }()
    
    lazy var textField: UITextView = {
        let textField = UITextView()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = Fonts.body
        textField.textColor = .label
        textField.text = "Insira seu título"
        textField.backgroundColor = .secondarySystemBackground
        textField.delegate = self
        return textField
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, textField])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 32
        stackView.backgroundColor = .secondarySystemBackground
        stackView.layer.cornerRadius = 24
        stackView.layer.masksToBounds = true
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 0)
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
    
    // MARK: Functions
    func additionalSetup() {
        title = "Detalhes"
        
        setupTitle()
        
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.rightBarButtonItem = saveButtonItem
        navigationItem.leftBarButtonItem = closeButtonItem
        
        view.backgroundColor = .tertiarySystemBackground
    }
    
    private func setupTitle()  {
        guard
            let category = self.category,
            let transcriptionID = self.transcriptionID,
            let transcription = Persistence.shared.getTranscription(by: transcriptionID)
        else { return }
        
        switch category {
        case .transcription:
            titleLabel.text = "Resumo"
        case .summary:
            titleLabel.text = "Resumo da Consulta"
        case .didctarized:
            titleLabel.text = "Resumo Cliníco"
        case .keyWords:
            titleLabel.text = "Palavras Chave"
        case .actionPoints:
            titleLabel.text = "Pontos de Ação"
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
            
            textField.heightAnchor.constraint(equalToConstant: 44),
        ])
    }
}

extension AnalysisEditViewController {
    @objc func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc func saveButtonTapped() {
        saveTranscription()
    
        dismiss(animated: true)
    }
}

extension AnalysisEditViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let currentText = textView.text as NSString? else { return true }
        
        let newText = currentText.replacingCharacters(in: range, with: text)
        
        return newText.count <= 360
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        print(textView.text ?? "")
    }
}
