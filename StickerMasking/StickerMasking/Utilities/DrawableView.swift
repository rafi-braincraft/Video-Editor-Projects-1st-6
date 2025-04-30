
import UIKit

class DrawableView: UIView {

    enum Mode {
        case ERASE
        case RESTORE
    }

    private var imageLayer = CALayer()
    private var maskImageView: UIImageView!
    private var shapeLayer: CAShapeLayer!
    private var path: UIBezierPath!
    private var maskImage: UIImage? {
        didSet {
            updateModeAppearance()
        }
    }

    var eraserWidth: CGFloat = 20.0
    var currentMode: Mode = .ERASE {
        didSet {
            updateModeAppearance()
        }
    }
    var bkgImage: UIImage = UIImage()
    private var isFirstTime = true

    private var overlayLayer: CALayer!
    private var overlayMaskLayer: CAShapeLayer!
    private var previousTouchLocation: CGPoint?

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
    }

    private func updateModeAppearance() {
        overlayLayer.isHidden = currentMode != .RESTORE
        shapeLayer.strokeColor = currentMode == .ERASE ?
            UIColor.white.cgColor : UIColor.clear.cgColor
        updateOverlayMask()
    }

    private func updateOverlayMask() {
        guard let maskImage = maskImage else { return }

        let ciImage = CIImage(image: maskImage)
        let filter = CIFilter(name: "CIMaskToAlpha")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)

        if let outputImage = filter?.outputImage {
            let context = CIContext(options: nil)
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                overlayMaskLayer.contents = cgImage
            }
        }
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
            path = UIBezierPath()
            path.move(to: location)

        case .changed:
            guard previousTouchLocation != nil else { return }
            path.addLine(to: location)
            shapeLayer.path = path.cgPath
            previousTouchLocation = location

        case .ended, .cancelled:
            if let blendedImage = blendShapeLayerWithImage() {
                maskImage = blendedImage
                maskImageView.image = maskImage
                updateOverlayMask()
            }
            shapeLayer.path = nil
            previousTouchLocation = nil

        default:
            break
        }
    }

    private func blendShapeLayerWithImage() -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: bounds.size)
        return renderer.image { ctx in
            maskImage?.draw(at: .zero)

            if let path = shapeLayer.path {
                ctx.cgContext.addPath(path)
                ctx.cgContext.setLineWidth(eraserWidth)
                ctx.cgContext.setLineCap(.round)
                ctx.cgContext.setLineJoin(.round)

                if currentMode == .ERASE {
                    ctx.cgContext.setStrokeColor(UIColor.white.cgColor)
                } else {
                    ctx.cgContext.setBlendMode(.clear)
                    ctx.cgContext.setStrokeColor(UIColor.clear.cgColor)
                }

                ctx.cgContext.strokePath()
            }
        }
    }

    func resetMask() {
        maskImage = createTransparentImage()
        maskImageView.image = maskImage
        shapeLayer.path = nil
        updateOverlayMask()
    }
}
