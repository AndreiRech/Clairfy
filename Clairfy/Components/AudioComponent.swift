import UIKit

class AudioComponent: UIView {
    // MARK: Subviews
    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .tertiarySystemBackground
        view.layer.cornerRadius = 24
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var soundWaveImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = .soundWave
        return imageView
    }()

    private lazy var audioTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Audio"
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textAlignment = .left
        label.textColor = UIColor(named: "Label-Primary")
        label.numberOfLines = 1
        return label
    }()

    private lazy var audioDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "10/06/2024 - 21:00"
        label.textColor = .secondaryLabel
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()

    private lazy var audioDurationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "00:48:14"
        label.textColor = .secondaryLabel
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 13, weight: .medium)
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()

    // MARK: - Buttons
    private lazy var playButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .clairBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.tintColor = .tertiarySystemBackground  // Corrigido: aplica direto no botão
        button.layer.cornerRadius = 19
        return button
    }()

    // MARK: - Stack Views
    private lazy var audioInfoStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [audioTitleLabel, audioDateLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        stack.distribution = .fill
        return stack
    }()

    private lazy var topStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [playButton, audioInfoStackView, audioDurationLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 16
        stack.alignment = .center
        stack.distribution = .fill
        return stack
    }()

    private lazy var mainStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [topStackView, soundWaveImageView])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }()

    // MARK: Properties
    var title: String? {
        get { audioTitleLabel.text }
        set { audioTitleLabel.text = newValue }
    }

    var titleColor: UIColor {
        get { audioTitleLabel.textColor }
        set { audioTitleLabel.textColor = newValue }
    }

    var date: String? {
        get { audioDateLabel.text }
        set { audioDateLabel.text = newValue }
    }

    var dateColor: UIColor {
        get { audioDateLabel.textColor }
        set { audioDateLabel.textColor = newValue }
    }

    var duration: String? {
        get { audioDurationLabel.text }
        set { audioDurationLabel.text = newValue }
    }

    var durationColor: UIColor {
        get { audioDurationLabel.textColor }
        set { audioDurationLabel.textColor = newValue }
    }
    
    var playbutton: UIButton {
        get { playButton }
        set { playButton = newValue }
    }

    var audioPath: String? {
        didSet {
            print("Caminho do áudio definido: \(audioPath ?? "sem caminho")")
        }
    }
    
    var playButtonState: PlayButtonState = .play {
        didSet {
            updatePlayButtonIcon()
        }
    }

    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        setupButtonAnimations()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: - Button Animations
    private func setupButtonAnimations() {
        let button = playButton
        button.addTarget(self, action: #selector(buttonTouchDown(_:)), for: [.touchDown, .touchDragEnter])
        button.addTarget(self, action: #selector(buttonTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchDragExit, .touchCancel])
    }
    
    private func updatePlayButtonIcon() {
        let systemName: String
        switch playButtonState {
            case .play:
                systemName = "play.fill"
            case .pause:
                systemName = "pause.fill"
        }
        
        // Usando peso bold como padrão
        let config = UIImage.SymbolConfiguration(weight: .bold)
        playButton.setImage(UIImage(systemName: systemName, withConfiguration: config), for: .normal)
    }

    private func updateIconWeight(imageView: UIImageView, systemName: String, weight: UIImage.SymbolWeight) {
        let config = UIImage.SymbolConfiguration(weight: weight)
        imageView.image = UIImage(systemName: systemName, withConfiguration: config)
    }
}

// MARK: - ViewCodeProtocol
extension AudioComponent: ViewCodeProtocol {
    func addSubViews() {
        addSubview(backgroundView)
        backgroundView.addSubview(mainStackView)
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
            mainStackView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -padding),
            
            playButton.heightAnchor.constraint(equalToConstant: 38),
            playButton.widthAnchor.constraint(equalToConstant: 38),

            // Sound wave image
            soundWaveImageView.heightAnchor.constraint(equalToConstant: 40),
        ])
    }
}

extension AudioComponent {
    @objc private func buttonTouchDown(_ sender: UIButton) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()

        UIView.animate(withDuration: 0.1,
                       delay: 0,
                       options: [.curveEaseIn, .allowUserInteraction],
                       animations: {
            sender.superview?.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            sender.superview?.alpha = 0.9
        })
    }

    @objc private func buttonTouchUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.4,
                       initialSpringVelocity: 0.5,
                       options: [.curveEaseOut, .allowUserInteraction],
                       animations: {
            sender.superview?.transform = CGAffineTransform(scaleX: 1.02, y: 1.02)
            sender.superview?.alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: 0.3) {
                sender.superview?.transform = .identity
            }

            if sender.isTouchInside {
                let generator = UIImpactFeedbackGenerator(style: .soft)
                generator.impactOccurred()
            }
        })
    }
}
