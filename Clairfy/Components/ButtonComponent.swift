import UIKit

class ButtonComponent: UIButton {
    // MARK: Subviews
    private lazy var button: UIButton = {
        var button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .tertiarySystemBackground
        button.setTitleColor(.clairBlue, for: .normal)
//        button.layer.borderWidth = 1
        //button.layer.borderColor = UIColor.lightGray.cgColor
//        button.clipsToBounds = true
        return button
    }()
    
    // MARK: Proprieties
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    
    var text: String = "" {
        didSet {
            button.setTitle(text, for: .normal)
        }
    }
    
    var font: UIFont? {
        didSet {
            button.titleLabel?.font = font
        }
    }
    
    var cornerRadius: CGFloat = 24 {
        didSet {
            button.layer.cornerRadius = cornerRadius
        }
    }
    
    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        feedbackGenerator.prepare()
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Functions
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
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
    
    override func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {
        button.addTarget(target, action: action, for: controlEvents)
    }
}

extension ButtonComponent: ViewCodeProtocol {
    func addSubViews() {
        addSubview(button)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: self.topAnchor),
            button.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            button.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
    }
}
