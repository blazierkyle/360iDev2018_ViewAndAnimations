//: # ButtonShield
//: A demo playground that demonstrates how to use Core Animation layers
//: to create a fun button, shamelessly stolen from ExpressVPN
//: > Icons made by [Icon Works](https://www.flaticon.com/authors/icon-works) from [www.flaticon.com](https://www.flaticon.com/) is licensed by [CC 3.0 BY](http://creativecommons.org/licenses/by/3.0/)

import UIKit
import PlaygroundSupport

//: ### Extensions to store constants

fileprivate extension CGFloat {
    static var outerCircleRatio: CGFloat = 0.8
    static var innerCircleRatio: CGFloat = 0.55
    static var inProgressRatio: CGFloat = 0.58
}

fileprivate extension Double {
    static var animationDuration: Double = 0.5
    static var inProgressPeriod: Double = 0.7
}

extension CAAnimation {
    static let inProgressRotateKey = "inProgressRotation"
    static let greenBackgroundOnKey = "greenBackgroundOn"
    static let greenBackgroundOffKey = "greenBackgroundOff"
}

extension CALayer {
    func applyPopShadow() {
        shadowColor = UIColor.white.cgColor
        shadowOffset = .zero
        shadowRadius = 1
        shadowOpacity = 0.1
    }
}
//: ### The main ButtonView class

class ButtonView: UIView {
    
    enum State {
        case off
        case inProgress
        case on
    }
    
    public var state: State = .off {
        didSet {
            switch state {
            case .on:
                showInProgress(false)
                animateOn()
            case .inProgress:
                showInProgress(true)
            case .off:
                showInProgress(false)
                animateOff()
            }
        }
    }
    
    private let buttonLayer = CALayer()
    private lazy var innerCircle: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.path = UIBezierPath(ovalIn: CGRect(center: buttonLayer.bounds.center, size: buttonLayer.bounds.size.rescale(CGFloat.innerCircleRatio))).cgPath
        layer.fillColor = UIColor.white.cgColor
        layer.shadowRadius = 15
        layer.shadowOpacity = 0.1
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 15, height: 25)
        layer.strokeColor = UIColor.darkGray.withAlphaComponent(0.7).cgColor
        layer.lineWidth = 3
        return layer
    }()
    
    private lazy var outerCircle: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.path = UIBezierPath(ovalIn: CGRect(center: buttonLayer.bounds.center, size: buttonLayer.bounds.size.rescale(CGFloat.outerCircleRatio))).cgPath
        layer.fillColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        layer.opacity = 0.4
        layer.applyPopShadow()
        return layer
    }()
    
    private lazy var greenBackground: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.green.withAlphaComponent(0.6).cgColor
        layer.path = UIBezierPath(ovalIn: CGRect(center: buttonLayer.frame.center, size: buttonLayer.bounds.size.rescale(CGFloat.innerCircleRatio))).cgPath
        layer.mask = createBadgeLayerMask()
        return layer
    }()
    
    private lazy var inProgressLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.locations = [0, 0.7]
        layer.colors = [UIColor.green.cgColor, UIColor.white.withAlphaComponent(0).cgColor]
        layer.frame = CGRect(center: buttonLayer.bounds.center, size: buttonLayer.bounds.size.rescale(CGFloat.inProgressRatio))
        layer.isHidden = true
        
        let mask = CAShapeLayer()
        mask.path = UIBezierPath(ovalIn: CGRect(center: layer.bounds.center, size: layer.bounds.size)).cgPath
        mask.fillColor = UIColor.black.cgColor
        layer.mask = mask
        return layer
    }()
    
    private lazy var badgeLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [UIColor.white.cgColor, UIColor.lightGray.withAlphaComponent(0.3).cgColor]
        layer.frame = self.layer.bounds
        layer.applyPopShadow()
        layer.mask = createBadgeLayerMask()
        return layer
    }()
    
    private func createBadgeLayerMask() -> CAShapeLayer {
        let scale = layer.bounds.width / UIBezierPath.badgePath.bounds.width
        let mask = CAShapeLayer()
        mask.path = UIBezierPath.badgePath.cgPath
        mask.transform = CATransform3DMakeScale(scale, scale, 1)
        return mask
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureLayers()
    }
    
    private func configureLayers() {
        backgroundColor = #colorLiteral(red: 0.9600390625, green: 0.9600390625, blue: 0.9600390625, alpha: 1)
        
        // Add custom layers
        buttonLayer.frame = bounds.largestContainedSquare.offsetBy(dx: 0, dy: -20)
        buttonLayer.addSublayer(outerCircle)
        buttonLayer.addSublayer(inProgressLayer)
        buttonLayer.addSublayer(innerCircle)
        
        layer.addSublayer(badgeLayer)
        badgeLayer.addSublayer(greenBackground)
        badgeLayer.addSublayer(buttonLayer)
    }
    
    private func animateOn() {
        greenBackground.removeAnimation(forKey: CAAnimation.greenBackgroundOffKey)
        let path = UIBezierPath(ovalIn: CGRect(center: bounds.center, size: bounds.smallestContainingSquare.size.rescale(sqrt(2)))).cgPath
        let animation = CABasicAnimation(keyPath: "path")
        animation.repeatCount = 1.0
        animation.fromValue = greenBackground.path
        animation.toValue = path
        animation.duration = Double.animationDuration
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        greenBackground.add(animation, forKey: CAAnimation.greenBackgroundOnKey)
        greenBackground.path = path
    }
    
    private func animateOff() {
        greenBackground.removeAnimation(forKey: CAAnimation.greenBackgroundOnKey)
        let path = UIBezierPath(ovalIn: CGRect(center: buttonLayer.frame.center, size: buttonLayer.bounds.size.rescale(CGFloat.innerCircleRatio))).cgPath
        let animation = CABasicAnimation(keyPath: "path")
        animation.repeatCount = 1.0
        animation.fromValue = greenBackground.path
        animation.toValue = path
        animation.duration = Double.animationDuration
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        greenBackground.add(animation, forKey: CAAnimation.greenBackgroundOffKey)
        greenBackground.path = path
    }
    
    private func showInProgress(_ show: Bool) {
        if show {
            let animation = CABasicAnimation(keyPath: "transform.rotation.z")
            animation.fromValue = 0
            animation.toValue = 2 * Double.pi
            animation.duration = Double.inProgressPeriod
            animation.repeatCount = Float.greatestFiniteMagnitude
            inProgressLayer.add(animation, forKey: CAAnimation.inProgressRotateKey)
        } else {
            inProgressLayer.removeAnimation(forKey: CAAnimation.inProgressRotateKey)
        }
        inProgressLayer.isHidden = !show
    }
}

//: ### Present the button

let aspectRatio = UIBezierPath.badgePath.bounds.width / UIBezierPath.badgePath.bounds.height
let button = ButtonView(frame: CGRect(x: 0, y: 0, width: 300, height: 300 / aspectRatio))

// Present the view controller in the Live View window
PlaygroundPage.current.liveView = button

let connection = PseudoConnection { (state) in
    switch state {
    case .disconnected:
        button.state = .off
    case .connecting:
        button.state = .inProgress
    case .connected:
        button.state = .on
    }
}

let gesture = UITapGestureRecognizer(target: connection, action: #selector(PseudoConnection.toggle))
button.addGestureRecognizer(gesture)
