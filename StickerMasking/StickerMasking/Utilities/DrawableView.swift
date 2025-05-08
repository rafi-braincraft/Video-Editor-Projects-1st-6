import UIKit


class DrawableView: UIView {

    enum Mode {
        case erase
        case restore
    }

    private var imageLayer = CALayer()
    private var maskImageView: UIImageView!
    private var shapeLayer: CAShapeLayer!
    private var path: UIBezierPath!
    private var restorePath: UIBezierPath!
    private var currentTransform: CGAffineTransform = .identity

    private var maskImage: UIImage? {
        didSet {
            updateModeAppearance()
        }
    }

    var eraserWidth: CGFloat = 20.0 {
        didSet {
            
        }
    }
    
    var currentMode: Mode = .erase {
        didSet {
            updateModeAppearance()
        }
    }
    var bkgImage: UIImage = UIImage()
    private var isFirstTime = true

    private var overlayLayer: CALayer!
    private var overlayMaskLayer: CAShapeLayer!
    private var previousTouchLocation: CGPoint?
    private var mainBounds: CGRect = .zero

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if isFirstTime {
            isFirstTime = false
            self.mainBounds = self.bounds
            imageLayer.frame = bounds
            maskImageView.frame = bounds
            shapeLayer.frame = bounds
            overlayLayer.frame = bounds
            overlayMaskLayer.frame = bounds

            if maskImage == nil {
                maskImage = createTransparentImage()
                maskImageView.image = maskImage
            }
        }
    }

    private func setupLayers() {
        backgroundColor = .clear

        // Setup image layer
        imageLayer.frame = bounds
        imageLayer.contentsGravity = .resizeAspectFill
        layer.addSublayer(imageLayer)

        // Create transparent image view for mask
        maskImageView = UIImageView(frame: bounds)
        maskImageView.backgroundColor = .clear

        // Setup shape layer for drawing
        shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = nil
        shapeLayer.lineWidth = eraserWidth
        shapeLayer.lineCap = .round
        shapeLayer.lineJoin = .round

        // Add shape layer to mask image view
        maskImageView.layer.addSublayer(shapeLayer)

        // Apply mask image view as mask to image layer
        imageLayer.mask = maskImageView.layer

        // Setup overlay layer for restore mode highlighting
        overlayLayer = CALayer()
        overlayLayer.frame = bounds
        overlayLayer.backgroundColor = UIColor.red.withAlphaComponent(0.8).cgColor
        overlayLayer.isHidden = true
        layer.addSublayer(overlayLayer)

        // Setup mask for overlay layer (inverse of the main mask)
        overlayMaskLayer = CAShapeLayer()
        overlayMaskLayer.frame = bounds
        overlayMaskLayer.fillColor = UIColor.black.cgColor
        overlayLayer.mask = overlayMaskLayer

        // Initialize path
        path = UIBezierPath()
        restorePath = UIBezierPath()
    }

    private func updateModeAppearance() {
        overlayLayer.isHidden = currentMode != .restore
        shapeLayer.strokeColor = currentMode == .erase ?
            UIColor.white.cgColor : UIColor.clear.cgColor
    }

    // Changed from private to internal (by removing private)
    func updateBackgroundImage(_ image: UIImage) {
        bkgImage = image
        imageLayer.contents = image.cgImage
    }

    private func createTransparentImage() -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: bounds.size)
        return renderer.image { ctx in
            UIColor.clear.setFill()
            ctx.fill(bounds)
        }
    }

    func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: self)

        switch gesture.state {
        case .began:
            previousTouchLocation = location
            
            if currentMode == .erase {
                path = UIBezierPath()
                path.move(to: location)
            } else {
                restorePath = UIBezierPath()
                restorePath.move(to: location)
            }
            

        case .changed:
            guard previousTouchLocation != nil else { return }
            
            if currentMode == .erase {
                path.addLine(to: location)
                shapeLayer.path = path.cgPath
            } else {
                restorePath.addLine(to: location)
                shapeLayer.path = restorePath.cgPath
                
                // Apply the restore immediately during pan gesture
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    guard let self else { return }
                    if let blendedImage = blendShapeLayerWithImage() {
                        maskImage = blendedImage
                        DispatchQueue.main.async {
                            self.maskImageView.image = self.maskImage
                        }
                    }
                }
            }
            previousTouchLocation = location

        case .ended, .cancelled:
            if currentMode == .erase {
                // Only blend for erase mode at the end
                if let blendedImage = blendShapeLayerWithImage() {
                    maskImage = blendedImage
                    maskImageView.image = maskImage
                }
            }
            shapeLayer.path = nil
            previousTouchLocation = nil
            break

        default:
            break
        }
    }

    private func blendShapeLayerWithImage() -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: self.mainBounds.size)
        return renderer.image { ctx in
            // First, draw the existing mask image
            maskImage?.draw(at: .zero)

            if let path = shapeLayer.path {
                ctx.cgContext.addPath(path)
                ctx.cgContext.setLineWidth(eraserWidth)
                ctx.cgContext.setLineCap(.round)
                ctx.cgContext.setLineJoin(.round)

                if currentMode == .erase {
                    // For erasing: draw with white color
                    ctx.cgContext.setStrokeColor(UIColor.white.cgColor)
                    ctx.cgContext.strokePath()
                } else {
                    // For restoring: properly remove the erased areas
                    // Clear the area first
                    ctx.cgContext.setBlendMode(.clear)
                    ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
                    ctx.cgContext.strokePath()
                    
                    // Reset blend mode for future operations
                    ctx.cgContext.setBlendMode(.normal)
                }
            }
        }
    }
    
    func updateImageTransformation(_ transform: CGAffineTransform) {
        currentTransform = transform
        
        // Apply transformation to the image content layers but not to the view itself
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        // Apply transform to image layer
        imageLayer.setAffineTransform(transform)
        
        // Apply transform to mask image view layer
        maskImageView.layer.setAffineTransform(transform)
        
        CATransaction.commit()
    }

    func resetMask() {
        maskImage = createTransparentImage()
        maskImageView.image = maskImage
        shapeLayer.path = nil
    }
}
