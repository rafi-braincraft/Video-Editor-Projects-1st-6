import UIKit

class CircularProgressView: UIView {
    
    static let iPad: Bool = UIDevice.current.userInterfaceIdiom == .pad
    
    private let backgroundLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()
    private let label = UILabel()
    private let storageLabel = UILabel()
    private let availableLabel = UILabel()
    
    let labelSize: CGFloat = iPad ? 38 : 19
    let storageLabelSize: CGFloat = iPad ? 26 : 12
    let availableLabelSize: CGFloat = iPad ? 29 : 13
    
    let screenWidth = UIScreen.main.bounds.width
    private var strokeLineWidth: CGFloat {
        return 7 * (screenWidth / 414)
    }
    
    // Progress value (0.0 to 1.0)
    var progress: CGFloat = 0 {
        didSet {
            updateProgress()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        // Configure layers
        backgroundLayer.strokeColor = UIColor.customGray.cgColor
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.lineWidth = strokeLineWidth
        backgroundLayer.lineCap = .round
        layer.addSublayer(backgroundLayer)
        
        progressLayer.strokeColor = UIColor.customBlue.cgColor
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineWidth = strokeLineWidth
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0
        layer.addSublayer(progressLayer)

        label.textAlignment = .center
        label.numberOfLines = 1
        label.font = UIFont.boldSystemFont(ofSize: labelSize)
        label.textColor = .black
        addSubview(label)
        
        // Configure "Storage" label
        storageLabel.text = "Storage"
        storageLabel.textAlignment = .center
        storageLabel.font = UIFont.systemFont(ofSize: storageLabelSize)
        storageLabel.textColor = .gray
        addSubview(storageLabel)
        
        // Configure "Available" label
        availableLabel.textAlignment = .center
        availableLabel.font = UIFont.systemFont(ofSize: availableLabelSize)
        availableLabel.textColor = UIColor.customBlue
        addSubview(availableLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Update paths whenever the view's bounds change
        let centerPoint = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let radius = min(bounds.width, bounds.height) / 2 - 10
        let circularPath = UIBezierPath(arcCenter: centerPoint,
                                        radius: radius,
                                        startAngle: -CGFloat.pi / 2,
                                        endAngle: 3 * CGFloat.pi / 2,
                                        clockwise: true)
        
        backgroundLayer.path = circularPath.cgPath
        progressLayer.path = circularPath.cgPath

        let labelHeight = UIFont.systemFont(ofSize: labelSize).lineHeight
        //let storageLabelHeight = UIFont.systemFont(ofSize: storageLabelSize).lineHeight
        let centerY = bounds.height / 2
        
        label.frame = CGRect(x: 0, y: centerY - labelHeight / 2, width: bounds.width, height: labelHeight)
        
        // Storage label (just above the main label)
        storageLabel.frame = CGRect(x: 0, y: label.frame.minY - labelHeight + 5, width: bounds.width, height: labelHeight)
        
        // Available label (just below the main label)
        availableLabel.frame = CGRect(x: 0, y: label.frame.maxY - 5, width: bounds.width, height: labelHeight)
    
}

private func updateProgress(animated: Bool = true) {
    let clampedProgress = min(max(progress, 0), 1)
    
    if animated {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = progressLayer.strokeEnd
        animation.toValue = clampedProgress
        animation.duration = 1.0
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        progressLayer.add(animation, forKey: "progressAnim")
    }
    
    progressLayer.strokeEnd = clampedProgress
    let percentage = Int(clampedProgress * 100)
    label.text = "\(percentage) GB"
    availableLabel.text = "Available"
}

}
