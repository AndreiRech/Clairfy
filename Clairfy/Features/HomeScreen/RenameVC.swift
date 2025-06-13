import UIKit

class RenameViewController: UIViewController {
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
    
    lazy var textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = Fonts.body
        textField.textColor = .label
        textField.placeholder = "Insira seu título"
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
    
    // MARK: Functions
    func additionalSetup() {
        title = "Novo Áudio"
        
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.rightBarButtonItem = saveButtonItem
        navigationItem.leftBarButtonItem = closeButtonItem
        
        view.backgroundColor = .tertiarySystemBackground
    }
}

extension RenameViewController: ViewCodeProtocol {
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

extension RenameViewController {
    @objc func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc func saveButtonTapped() {
        print(textField.text ?? "")
        dismiss(animated: true) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                let window = windowScene.windows.first {
                    
                let newRoot = ConsultationListVC()
                let navController = UINavigationController(rootViewController: newRoot)
                    
                UIView.transition(with: window,
                                  duration: 0.5,
                                  options: [.allowAnimatedContent, .transitionCrossDissolve],
                                  animations: { window.rootViewController = navController })
            }
        }
    }
}

extension RenameViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
        
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text as NSString? else { return true }
        
        let newText = currentText.replacingCharacters(in: range, with: string)
        
        return newText.count <= 24
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        print(textField.text ?? "")
    }
}
