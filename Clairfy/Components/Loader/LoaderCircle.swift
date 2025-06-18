import UIKit

class LoaderCircleView: UIView {
    // MARK: Subviews
    private let shapeLayer = CAShapeLayer()
    
    // MARK: Properties
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 37, height: 34)
    }
    
    // MARK: Functions
    private func additionalSetup() {
        shapeLayer.strokeColor = UIColor.clairBlue.cgColor
        shapeLayer.lineWidth = 4
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineCap = .round
        layer.addSublayer(shapeLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
            
        let radius = min(bounds.width, bounds.height) / 2 - shapeLayer.lineWidth / 2
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let circularPath = UIBezierPath(arcCenter: center,
                                        radius: radius,
                                        startAngle: 0,
                                        endAngle: 1.5 * .pi,
                                        clockwise: true)
        shapeLayer.path = circularPath.cgPath
        shapeLayer.frame = bounds
    }

    private func startRotating() {
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.toValue = 2 * Double.pi
        rotation.duration = 1
        rotation.repeatCount = .infinity
        rotation.isRemovedOnCompletion = false
        layer.add(rotation, forKey: "rotationAnimation")
    }
    
    func startAnimation() {
        startRotating()
    }
    
    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        additionalSetup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
