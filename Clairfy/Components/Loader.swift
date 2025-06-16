import UIKit

class LoaderView: UIView {
    // MARK: Subviews
    private let shapeLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.label.cgColor
        layer.lineWidth = 4
        return layer
    }()
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.title1
        label.textColor = .label
        label.textAlignment = .center
        label.text = "Analizando áudio..."
        return label
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [])
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()
    
    // MARK: Functions
    private func additionalSetup() {
        let circularPath = UIBezierPath(arcCenter: center, radius: 20, startAngle: 0, endAngle: 2 * .pi, clockwise: true)

        shapeLayer.path = circularPath.cgPath
        shapeLayer.strokeColor = UIColor.systemBlue.cgColor
        shapeLayer.lineWidth = 4
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineCap = .round

        layer.addSublayer(shapeLayer)

        startRotating()
    }
    
    private func startRotating() {
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.toValue = 2 * Double.pi
        rotation.duration = 1
        rotation.isCumulative = true
        rotation.repeatCount = .infinity

        layer.add(rotation, forKey: "rotationAnimation")
    }
    
    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        additionalSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LoaderView: ViewCodeProtocol {
    func addSubViews() {
        addSubview(stackView)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
