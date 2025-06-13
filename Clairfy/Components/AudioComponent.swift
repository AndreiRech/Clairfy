//
//  AudioComponent.swift
//  Clairfy
//
//  Created by Bernardo Garcia Fensterseifer on 12/06/25.
//

import UIKit

class AudioComponent: UIView {

    // MARK: - UI Components
    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .tertiarySystemBackground
        view.layer.cornerRadius = 24
        view.layer.masksToBounds = true
        return view
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
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .left
        label.textColor = UIColor(named: "Label-Secondary")
        label.numberOfLines = 1
        return label
    }()

    private lazy var audioDurationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "00:48:14"
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 13, weight: .medium)
        label.textAlignment = .left
        label.textColor = UIColor(named: "Label-Primary")
        label.numberOfLines = 1
        return label
    }()

    // MARK: - Buttons
    private lazy var playImageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(systemName: "play.fill")
        image.contentMode = .scaleAspectFit
        image.tintColor = .white
        return image
    }()

    lazy var playButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var playButtonView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBlue
        view.layer.cornerRadius = 25
        view.layer.masksToBounds = true
        return view
    }()

    private lazy var trashImageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(systemName: "trash.fill")
        image.contentMode = .scaleAspectFit
        image.tintColor = .white
        return image
    }()

    lazy var trashButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var trashButtonView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemRed
        view.layer.cornerRadius = 17
        view.layer.masksToBounds = true
        return view
    }()

    private lazy var shareImageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(systemName: "square.and.arrow.up.fill")
        image.contentMode = .scaleAspectFit
        image.tintColor = .white
        return image
    }()

    lazy var shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var shareButtonView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGreen
        view.layer.cornerRadius = 17
        view.layer.masksToBounds = true
        return view
    }()

    private lazy var soundWaveImageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(named: "soundWave")
        image.contentMode = .scaleAspectFit
        return image
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

    private lazy var buttonsStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        stack.distribution = .fill
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        stack.addArrangedSubview(spacer)
        stack.addArrangedSubview(trashButtonView)
        stack.addArrangedSubview(shareButtonView)
        return stack
    }()

    private lazy var topStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [playButtonView, audioInfoStackView, audioDurationLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 16
        stack.alignment = .center
        stack.distribution = .fill
        return stack
    }()

    private lazy var mainStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [topStackView, soundWaveImageView, buttonsStackView])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }()

    // MARK: - Public Properties
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

    var playButtonColor: UIColor? {
        get { playButtonView.backgroundColor }
        set { playButtonView.backgroundColor = newValue }
    }

    var trashButtonColor: UIColor? {
        get { trashButtonView.backgroundColor }
        set { trashButtonView.backgroundColor = newValue }
    }

    var shareButtonColor: UIColor? {
        get { shareButtonView.backgroundColor }
        set { shareButtonView.backgroundColor = newValue }
    }

    var playButtonIconColor: UIColor? {
        get { playImageView.tintColor }
        set { playImageView.tintColor = newValue }
    }

    var trashButtonIconColor: UIColor? {
        get { trashImageView.tintColor }
        set { trashImageView.tintColor = newValue }
    }

    var shareButtonIconColor: UIColor? {
        get { shareImageView.tintColor }
        set { shareImageView.tintColor = newValue }
    }

    var playButtonIconWeight: UIImage.SymbolWeight = .medium {
        didSet {
            updateIconWeight(imageView: playImageView, systemName: "play.fill", weight: playButtonIconWeight)
        }
    }

    var trashButtonIconWeight: UIImage.SymbolWeight = .medium {
        didSet {
            updateIconWeight(imageView: trashImageView, systemName: "trash.fill", weight: trashButtonIconWeight)
        }
    }

    var shareButtonIconWeight: UIImage.SymbolWeight = .medium {
        didSet {
            updateIconWeight(imageView: shareImageView, systemName: "square.and.arrow.up.fill", weight: shareButtonIconWeight)
        }
    }

    // MARK: - Initialization
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
        let buttons = [playButton, trashButton, shareButton]
        buttons.forEach { button in
            button.addTarget(self, action: #selector(buttonTouchDown(_:)), for: [.touchDown, .touchDragEnter])
            button.addTarget(self, action: #selector(buttonTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchDragExit, .touchCancel])
        }
    }

    @objc private func buttonTouchDown(_ sender: UIButton) {
        // Feedback tátil leve ao tocar
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
            // Efeito de "saltinho" ao liberar
            sender.superview?.transform = CGAffineTransform(scaleX: 1.02, y: 1.02)
            sender.superview?.alpha = 1.0
        }, completion: { _ in
            // Volta ao tamanho original suavemente
            UIView.animate(withDuration: 0.3) {
                sender.superview?.transform = .identity
            }

            // Feedback tátil adicional ao completar a ação (opcional)
            if sender.isTouchInside {
                let generator = UIImpactFeedbackGenerator(style: .soft)
                generator.impactOccurred()
            }
        })
    }

    // MARK: - Helper Methods
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

        playButtonView.addSubview(playImageView)
        playButtonView.addSubview(playButton)

        trashButtonView.addSubview(trashImageView)
        trashButtonView.addSubview(trashButton)

        shareButtonView.addSubview(shareImageView)
        shareButtonView.addSubview(shareButton)
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

            // Play button constraints
            playButtonView.widthAnchor.constraint(equalToConstant: 50),
            playButtonView.heightAnchor.constraint(equalToConstant: 50),
            playImageView.centerXAnchor.constraint(equalTo: playButtonView.centerXAnchor),
            playImageView.centerYAnchor.constraint(equalTo: playButtonView.centerYAnchor),
            playImageView.widthAnchor.constraint(equalToConstant: 20),
            playImageView.heightAnchor.constraint(equalToConstant: 20),
            playButton.topAnchor.constraint(equalTo: playButtonView.topAnchor),
            playButton.leadingAnchor.constraint(equalTo: playButtonView.leadingAnchor),
            playButton.trailingAnchor.constraint(equalTo: playButtonView.trailingAnchor),
            playButton.bottomAnchor.constraint(equalTo: playButtonView.bottomAnchor),

            // Trash button constraints
            trashButtonView.widthAnchor.constraint(equalToConstant: 34),
            trashButtonView.heightAnchor.constraint(equalToConstant: 34),
            trashImageView.centerXAnchor.constraint(equalTo: trashButtonView.centerXAnchor),
            trashImageView.centerYAnchor.constraint(equalTo: trashButtonView.centerYAnchor),
            trashImageView.widthAnchor.constraint(equalToConstant: 20),
            trashImageView.heightAnchor.constraint(equalToConstant: 20),
            trashButton.topAnchor.constraint(equalTo: trashButtonView.topAnchor),
            trashButton.leadingAnchor.constraint(equalTo: trashButtonView.leadingAnchor),
            trashButton.trailingAnchor.constraint(equalTo: trashButtonView.trailingAnchor),
            trashButton.bottomAnchor.constraint(equalTo: trashButtonView.bottomAnchor),

            // Share button constraints
            shareButtonView.widthAnchor.constraint(equalToConstant: 34),
            shareButtonView.heightAnchor.constraint(equalToConstant: 34),
            shareImageView.centerXAnchor.constraint(equalTo: shareButtonView.centerXAnchor),
            shareImageView.centerYAnchor.constraint(equalTo: shareButtonView.centerYAnchor),
            shareImageView.widthAnchor.constraint(equalToConstant: 20),
            shareImageView.heightAnchor.constraint(equalToConstant: 20),
            shareButton.topAnchor.constraint(equalTo: shareButtonView.topAnchor),
            shareButton.leadingAnchor.constraint(equalTo: shareButtonView.leadingAnchor),
            shareButton.trailingAnchor.constraint(equalTo: shareButtonView.trailingAnchor),
            shareButton.bottomAnchor.constraint(equalTo: shareButtonView.bottomAnchor),

            // Tamanho dos ícones dos botões
            playImageView.widthAnchor.constraint(equalTo: playButtonView.widthAnchor, multiplier: 0.5),
            playImageView.heightAnchor.constraint(equalTo: playButtonView.heightAnchor, multiplier: 0.5),
            trashImageView.widthAnchor.constraint(equalTo: trashButtonView.widthAnchor, multiplier: 0.5),
            trashImageView.heightAnchor.constraint(equalTo: trashButtonView.heightAnchor, multiplier: 0.5),
            shareImageView.widthAnchor.constraint(equalTo: shareButtonView.widthAnchor, multiplier: 0.5),
            shareImageView.heightAnchor.constraint(equalTo: shareButtonView.heightAnchor, multiplier: 0.5),

            // Sound wave image
            soundWaveImageView.heightAnchor.constraint(equalToConstant: 40),
        ])
    }
}
