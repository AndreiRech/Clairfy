//
//  AudioComponent.swift
//  Clairfy
//
//  Created by Bernardo Garcia Fensterseifer on 12/06/25.
//

import UIKit

class TextComponent: UIView {
    
    // MARK: - UI Components
    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .tertiarySystemBackground
        view.layer.cornerRadius = 24
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Title"
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textAlignment = .left
        label.textColor = UIColor(named: "Label-Primary")
        label.numberOfLines = 1
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()

    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "AI summary here..."
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .left
        label.textColor = UIColor(named: "Label-Primary")
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Edit Button Components
    private lazy var editImageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(systemName: "pencil")
        image.contentMode = .scaleAspectFit
        image.tintColor = .white
        return image
    }()
    
    private lazy var editTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Edit"
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var editButtonStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [editImageView, editTitleLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.backgroundColor = .systemBlue
        stack.layer.cornerRadius = 14
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .center
        stack.distribution = .fill
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)
        stack.setContentHuggingPriority(.required, for: .horizontal)
        stack.setContentCompressionResistancePriority(.required, for: .horizontal)
        return stack
    }()
    
    lazy var editButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Action Button Components
    private lazy var actionImageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(systemName: "doc.on.doc")
        image.contentMode = .scaleAspectFit
        image.tintColor = .white
        return image
    }()
    
    private lazy var actionTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Copy"
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var actionButtonStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [actionImageView, actionTitleLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.backgroundColor = .systemGreen
        stack.layer.cornerRadius = 14
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .center
        stack.distribution = .fill
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)
        stack.setContentHuggingPriority(.required, for: .horizontal)
        stack.setContentCompressionResistancePriority(.required, for: .horizontal)
        return stack
    }()
    
    lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Button Stack
    private lazy var buttonsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [editButtonStack, actionButtonStack])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.distribution = .fill
        return stack
    }()
    
    // MARK: - Main Stack
    private lazy var mainStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, textLabel, buttonsStackView])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }()

    // MARK: - Public Properties
    var title: String? {
        get { titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    var text: String? {
        get { textLabel.text }
        set { textLabel.text = newValue }
    }
    
    var editButtonImage: UIImage? {
        get { editImageView.image }
        set { editImageView.image = newValue }
    }
    
    var editButtonText: String? {
        get { editTitleLabel.text }
        set { editTitleLabel.text = newValue }
    }
    
    var editButtonColor: UIColor? {
        get { editButtonStack.backgroundColor }
        set {
            editButtonStack.backgroundColor = newValue
            if let newValue = newValue {
                let contrastingColor = newValue.isLight ? UIColor.black : UIColor.white
                editImageView.tintColor = contrastingColor
                editTitleLabel.textColor = contrastingColor
            }
        }
    }
    
    var editButtonIconColor: UIColor? {
        get { editImageView.tintColor }
        set { editImageView.tintColor = newValue }
    }
    
    var editButtonLabelColor: UIColor? {
        get { editTitleLabel.textColor }
        set { editTitleLabel.textColor = newValue }
    }
    
    var actionButtonImage: UIImage? {
        get { actionImageView.image }
        set { actionImageView.image = newValue }
    }
    
    var actionButtonText: String? {
        get { actionTitleLabel.text }
        set { actionTitleLabel.text = newValue }
    }
    
    var actionButtonColor: UIColor? {
        get { actionButtonStack.backgroundColor }
        set {
            actionButtonStack.backgroundColor = newValue
            if let newValue = newValue {
                let contrastingColor = newValue.isLight ? UIColor.black : UIColor.white
                actionImageView.tintColor = contrastingColor
                actionTitleLabel.textColor = contrastingColor
            }
        }
    }
    
    var actionButtonIconColor: UIColor? {
        get { actionImageView.tintColor }
        set { actionImageView.tintColor = newValue }
    }
    
    var actionButtonLabelColor: UIColor? {
        get { actionTitleLabel.textColor }
        set { actionTitleLabel.textColor = newValue }
    }
    
    var textColor: UIColor? {
        get { textLabel.textColor }
        set { textLabel.textColor = newValue }
    }

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        setupButtons()
        setupButtonAnimations()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
        setupButtons()
        setupButtonAnimations()
    }

    // MARK: - Button Animations
    private func setupButtonAnimations() {
        [editButton, actionButton].forEach { button in
            button.addTarget(self, action: #selector(buttonTouchDown(_:)), for: [.touchDown, .touchDragEnter])
            button.addTarget(self, action: #selector(buttonTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchDragExit, .touchCancel])
        }
    }

    @objc private func buttonTouchDown(_ sender: UIButton) {
        let buttonStack = sender == editButton ? editButtonStack : actionButtonStack
        
        UIView.animate(withDuration: 0.1,
                       delay: 0,
                       options: [.curveEaseIn, .allowUserInteraction],
                       animations: {
            buttonStack.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            buttonStack.alpha = 0.8
        })
    }

    @objc private func buttonTouchUp(_ sender: UIButton) {
        let buttonStack = sender == editButton ? editButtonStack : actionButtonStack
        
        // Animação de "toque" mais pronunciada
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.7,
                       options: [.curveEaseOut, .allowUserInteraction],
                       animations: {
            buttonStack.transform = .identity
            buttonStack.alpha = 1.0
            
            // Efeito de "pulsar" ao soltar
            buttonStack.transform = CGAffineTransform(scaleX: 1.03, y: 1.03)
        }, completion: { _ in
            UIView.animate(withDuration: 0.3) {
                buttonStack.transform = .identity
            }
        })
        
        // Feedback tátil (haptic)
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred()
    }
    
    // MARK: - Setup
        private func setupButtons() {
            addSubViews()
            setupConstraints()
            setupButtonTargets()
        }

        // MARK: - Button Targets
        private func setupButtonTargets() {
            // Make the button stacks tappable by adding the buttons as overlays
            editButtonStack.addSubview(editButton)
            actionButtonStack.addSubview(actionButton)
            
            // Set button constraints to match their stacks
            NSLayoutConstraint.activate([
                editButton.topAnchor.constraint(equalTo: editButtonStack.topAnchor),
                editButton.leadingAnchor.constraint(equalTo: editButtonStack.leadingAnchor),
                editButton.trailingAnchor.constraint(equalTo: editButtonStack.trailingAnchor),
                editButton.bottomAnchor.constraint(equalTo: editButtonStack.bottomAnchor),
                
                actionButton.topAnchor.constraint(equalTo: actionButtonStack.topAnchor),
                actionButton.leadingAnchor.constraint(equalTo: actionButtonStack.leadingAnchor),
                actionButton.trailingAnchor.constraint(equalTo: actionButtonStack.trailingAnchor),
                actionButton.bottomAnchor.constraint(equalTo: actionButtonStack.bottomAnchor)
            ])
        }

        // MARK: - Public Methods to Handle Button Actions
        func setEditButtonAction(target: Any?, action: Selector) {
            editButton.addTarget(target, action: action, for: .touchUpInside)
        }
        
        func setActionButtonAction(target: Any?, action: Selector) {
            actionButton.addTarget(target, action: action, for: .touchUpInside)
        }
}

// MARK: - ViewCodeProtocol
extension TextComponent: ViewCodeProtocol {
    func addSubViews() {
        addSubview(backgroundView)
        backgroundView.addSubview(mainStackView)
        
        // Add buttons to the same superview as their stacks
//        editButtonStack.superview?.addSubview(editButton)
//        actionButtonStack.superview?.addSubview(actionButton)
        backgroundView.addSubview(buttonsStackView)
    }
    
    func setupConstraints() {
        let padding: CGFloat = 16
        
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            mainStackView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: padding),
            mainStackView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: padding),
            mainStackView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -padding),
             
            // Align buttons to the right
            buttonsStackView.trailingAnchor.constraint(equalTo: mainStackView.trailingAnchor),
            buttonsStackView.topAnchor.constraint(equalTo: mainStackView.bottomAnchor, constant: padding),
            buttonsStackView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -padding)
        ])
    }
}

// MARK: - UIColor Extension
extension UIColor {
    var isLight: Bool {
        var white: CGFloat = 0
        self.getWhite(&white, alpha: nil)
        return white > 0.5
    }
}
