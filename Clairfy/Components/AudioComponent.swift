import UIKit
import AVFoundation

protocol AudioComponentDelegate: AnyObject {
    func audioComponentDidFinishPlaying(_ component: AudioComponent)
}


class AudioComponent: UIView {
    func resetWaveformProgress() {
        soundWaveImageView.progress = 0.0
    }

    // MARK: Subviews
    var audioPlayer: AVAudioPlayer?
    private var displayLink: CADisplayLink?

    // MARK: Delegate
    weak var delegate: AudioComponentDelegate?

    // MARK: Properties
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

    // MARK: Public API
    func preparePlayback(with url: URL) {
        if audioPlayer == nil || audioPlayer?.url != url {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.delegate = self
            } catch {
                print("Erro ao preparar player: \(error)")
            }
        }
        stopProgressAnimation()
        soundWaveImageView.progress = 0.0
        playButtonState = .play
    }

    func playAudio() {
        guard let player = audioPlayer else { return }
        if !player.isPlaying {
            player.play()
            startProgressAnimation()
            playButtonState = .pause
        }
    }

    func pauseAudio() {
        audioPlayer?.pause()
        stopProgressAnimation()
        playButtonState = .play
    }

    func stopAudio() {
        audioPlayer?.stop()
        stopProgressAnimation()
        soundWaveImageView.progress = 0.0
        playButtonState = .play
    }

    // MARK: - Progress Animation
    private func startProgressAnimation() {
        displayLink?.invalidate()
        displayLink = CADisplayLink(target: self, selector: #selector(updateWaveProgress))
        displayLink?.add(to: .main, forMode: .common)
    }

    private func stopProgressAnimation() {
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc private func updateWaveProgress() {
        guard let player = audioPlayer, player.duration > 0 else { return }
        let progress = CGFloat(player.currentTime / player.duration)
        soundWaveImageView.progress = min(progress, 1.0)

        if !player.isPlaying {
            stopProgressAnimation()
        }
    }

    // MARK: - Subviews
    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .tertiarySystemBackground
        view.layer.cornerRadius = 24
        view.layer.masksToBounds = true
        return view
    }()

    lazy var soundWaveImageView: AudioWaveformView = {
        let waveformView = AudioWaveformView()
        waveformView.translatesAutoresizingMaskIntoConstraints = false
        waveformView.layer.cornerRadius = 8
        waveformView.clipsToBounds = true
        waveformView.delegate = self
        return waveformView
    }()

    private lazy var audioTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Audio"
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textAlignment = .left
        label.textColor = UIColor(named: "Label-Primary")
        return label
    }()

    private lazy var audioDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "10/06/2024 - 21:00"
        label.textColor = .secondaryLabel
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .left
        return label
    }()

    private lazy var audioDurationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "00:48:14"
        label.textColor = .secondaryLabel
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 13, weight: .medium)
        label.textAlignment = .left
        return label
    }()

    // MARK: - Buttons
    private lazy var playButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .clairBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        let iconSize: CGFloat = 17
        let config = UIImage.SymbolConfiguration(pointSize: iconSize, weight: .bold)
        let icon = UIImage(systemName: "play.fill", withConfiguration: config)
        button.setImage(icon, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.tintColor = .tertiarySystemBackground
        button.layer.cornerRadius = 23
        return button
    }()

    // MARK: - Stack Views
    private lazy var audioInfoStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [audioTitleLabel, audioDateLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        return stack
    }()

    private lazy var topStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [playButton, audioInfoStackView, audioDurationLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 16
        stack.alignment = .center
        return stack
    }()

    private lazy var mainStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [topStackView, soundWaveImageView])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 16
        return stack
    }()

    // MARK: Getters e Setters
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

    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        setupButtonAnimations()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        soundWaveImageView.delegate = self
    }

    // MARK: - Button Animations
    private func setupButtonAnimations() {
        playButton.addTarget(self, action: #selector(buttonTouchDown(_:)), for: [.touchDown, .touchDragEnter])
        playButton.addTarget(self, action: #selector(buttonTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchDragExit, .touchCancel])
    }

    private func updatePlayButtonIcon() {
        let systemName: String
        switch playButtonState {
            case .play: systemName = "play.fill"
            case .pause: systemName = "pause.fill"
        }

        let config = UIImage.SymbolConfiguration(weight: .bold)
        playButton.setImage(UIImage(systemName: systemName, withConfiguration: config), for: .normal)
    }

    @objc private func buttonTouchDown(_ sender: UIButton) {
        let feedback = UIImpactFeedbackGenerator(style: .medium)
        feedback.prepare()
        feedback.impactOccurred(intensity: 0.5)

        UIView.animate(withDuration: 0.4, delay: 0, options: [.allowUserInteraction]) {
            sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            sender.alpha = 0.9
        }
    }

    @objc private func buttonTouchUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.4,
                       delay: 0,
                       usingSpringWithDamping: 0.4,
                       initialSpringVelocity: 0.5,
                       options: [.curveEaseOut, .allowUserInteraction]) {
            sender.transform = .identity
            sender.alpha = 1.0
        }
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

            playButton.heightAnchor.constraint(equalToConstant: 46),
            playButton.widthAnchor.constraint(equalToConstant: 46),

            soundWaveImageView.heightAnchor.constraint(equalToConstant: 40),
        ])
    }
}

// MARK: - AVAudioPlayerDelegate
extension AudioComponent: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopProgressAnimation()
        soundWaveImageView.progress = 1.0
        playButtonState = .play
        delegate?.audioComponentDidFinishPlaying(self)
    }
}

// MARK: - AudioWaveformViewDelegate
extension AudioComponent: AudioWaveformViewDelegate {
    func waveformView(_ waveformView: AudioWaveformView, didScrubTo progress: CGFloat) {
        guard let player = audioPlayer else { return }
        let newTime = TimeInterval(progress) * player.duration
        player.currentTime = newTime
        soundWaveImageView.progress = progress
        if !player.isPlaying {
            playButtonState = .play
        }
    }
}
