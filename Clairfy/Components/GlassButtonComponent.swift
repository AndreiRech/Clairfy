import UIKit

class GlassButton: UIButton {
    
    // MARK: - Configurações Ajustáveis
    var buttonText: String = "" {
        didSet {
            label.text = buttonText
            updateLayout()
        }
    }
    
    var textColor: UIColor = .clairBlue {
        didSet {
            label.textColor = textColor
            iconView?.tintColor = textColor
        }
    }
    
    var fontSize: CGFloat = 22 {
        didSet {
            label.font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        }
    }
    
    var fontWeight: UIFont.Weight = .semibold {
        didSet {
            label.font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        }
    }
    
    var cornerRadius: CGFloat = 24 {
        didSet {
            layer.cornerRadius = cornerRadius
            blurView.layer.cornerRadius = cornerRadius
            overlayView.layer.cornerRadius = cornerRadius
            layer.masksToBounds = true // Corrige o problema do quadrado externo
        }
    }
    
    var blurOpacity: CGFloat = 0.15 {
        didSet {
            blurView.alpha = blurOpacity
        }
    }
    
    var glassBorderWidth: CGFloat = 0.5 {
        didSet {
            layer.borderWidth = glassBorderWidth
        }
    }
    
    // MARK: - Componentes Internos
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
    private let overlayView = UIView()
    private let label = UILabel()
    private var iconView: UIImageView?
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    
    // MARK: - Inicialização
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    // MARK: - Configuração
    private func setupButton() {
        // Configuração da View Principal
        backgroundColor = .clear
        layer.masksToBounds = true // Fundamental para corrigir as bordas
        
        // Configuração do Blur (Efeito Vidro)
        blurView.alpha = blurOpacity
        blurView.isUserInteractionEnabled = false
        blurView.clipsToBounds = true
        
        // Overlay para efeito de vidro molhado
        overlayView.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        overlayView.isUserInteractionEnabled = false
        overlayView.clipsToBounds = true
        
        // Configuração do Label
        label.text = buttonText
        label.textColor = textColor
        label.font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        label.textAlignment = .center
        
        // Configurações de Borda e Sombra
        layer.borderWidth = glassBorderWidth
        layer.borderColor = UIColor.white.withAlphaComponent(0.15).cgColor
        
        // Sombra interna para efeito de profundidade
        blurView.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        blurView.layer.shadowOffset = CGSize(width: 0, height: 2)
        blurView.layer.shadowRadius = 4
        blurView.layer.shadowOpacity = 0.1
        blurView.layer.masksToBounds = false
        
        // Adicionando Subviews
        addSubview(blurView)
        addSubview(overlayView)
        addSubview(label)
        
        // Constraints
        setupConstraints()
        
        // Prepara o gerador de feedback háptico
        feedbackGenerator.prepare()
    }
    
    private func setupConstraints() {
        blurView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Blur View preenche todo o botão
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Overlay View também preenche
            overlayView.topAnchor.constraint(equalTo: topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Label centralizado
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 24),
            label.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -24)
        ])
    }
    
    // MARK: - Métodos Públicos
    func setIcon(_ image: UIImage?) {
        if let image = image {
            if iconView == nil {
                iconView = UIImageView()
                iconView?.contentMode = .scaleAspectFit
                iconView?.tintColor = textColor
                addSubview(iconView!)
            }
            iconView?.image = image.withRenderingMode(.alwaysTemplate)
            updateLayout()
        } else {
            iconView?.removeFromSuperview()
            iconView = nil
        }
    }
    
    private func updateLayout() {
        guard let iconView = iconView else {
            label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            return
        }
        
        iconView.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 12).isActive = true
        
        NSLayoutConstraint.activate([
            iconView.trailingAnchor.constraint(equalTo: label.leadingAnchor, constant: -8),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    // MARK: - Animação de Toque com Feedback Haptic
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        // Feedback háptico
        feedbackGenerator.impactOccurred(intensity: 0.7)
        
        UIView.animate(withDuration: 0.15) {
            self.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
            self.alpha = 0.9
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        animateTouchUp()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        animateTouchUp()
    }
    
    private func animateTouchUp() {
        UIView.animate(withDuration: 0.4, delay: 0,
                      usingSpringWithDamping: 0.4,
                      initialSpringVelocity: 0.5,
                      options: .curveEaseOut) {
            self.transform = .identity
            self.alpha = 1
        }
    }
}
