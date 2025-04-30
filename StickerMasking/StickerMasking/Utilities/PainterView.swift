import UIKit

class PainterView: UIView {
    
    enum Mode {
        case ERASE
        case RESTORE
    }
    
    // Current mode
    var currentMode: Mode = .ERASE {
        didSet {
            // Update internal state when mode changes
            updateModeSettings()
        }
    }
    
    // Main image layer and mask layer
    private var imageLayer = CALayer()
    private var maskLayer = CAShapeLayer()
    
    // Separate restore mask layer
    private var restoreMaskLayer = CAShapeLayer()
    
    // Current path being drawn
    private var currentPath = UIBezierPath()
    
    // Combined erase path
    private var combinedErasePath = UIBezierPath()
    
    // Settings
    var eraserWidth: CGFloat = 20.0 {
        didSet {
            maskLayer.lineWidth = eraserWidth
            restoreMaskLayer.lineWidth = eraserWidth
        }
    }
    
    var eraserColor: UIColor = .white {
        didSet {
            updateModeSettings()
        }
    }
    
    // Background image
    var bkgImage: UIImage = UIImage() {
        didSet {
            imageLayer.contents = bkgImage.cgImage
        }
    }
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayers()
    }
    
    private func setupLayers() {
        // Setup image layer
        imageLayer.frame = bounds
        imageLayer.contentsGravity = .resizeAspectFill
        layer.addSublayer(imageLayer)
        
        // Setup main mask layer
        maskLayer.frame = bounds
        maskLayer.fillColor = nil
        maskLayer.lineWidth = eraserWidth
        maskLayer.lineCap = .round
        maskLayer.lineJoin = .round
        maskLayer.strokeColor = eraserColor.cgColor
        
        // Setup restore mask layer
        restoreMaskLayer.frame = bounds
        restoreMaskLayer.fillColor = nil
        restoreMaskLayer.lineWidth = eraserWidth
        restoreMaskLayer.lineCap = .round
        restoreMaskLayer.lineJoin = .round
        restoreMaskLayer.strokeColor = UIColor.black.cgColor
        restoreMaskLayer.compositingFilter = "destinationOut"
        
        // Apply mask to image layer
        imageLayer.mask = maskLayer
    }
    
    private func updateModeSettings() {
        if currentMode == .ERASE {
            // Remove restore mask layer if it's a sublayer
            if restoreMaskLayer.superlayer != nil {
                restoreMaskLayer.removeFromSuperlayer()
            }
        } else {
            // Add restore mask layer as a sublayer of the main mask layer
            if restoreMaskLayer.superlayer == nil {
                maskLayer.addSublayer(restoreMaskLayer)
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Update frames
        imageLayer.frame = bounds
        maskLayer.frame = bounds
        restoreMaskLayer.frame = bounds
    }
    
    // MARK: - Touch Handling
    
    func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: self)
        
        switch gesture.state {
        case .began:
            // Initialize current path
            currentPath = UIBezierPath()
            currentPath.move(to: location)
            
        case .changed:
            // Add to current path
            currentPath.addLine(to: location)
            
            if currentMode == .ERASE {
                // In ERASE mode, draw white on the main mask layer
                let tempPath = UIBezierPath(cgPath: combinedErasePath.cgPath)
                tempPath.append(currentPath)
                maskLayer.path = tempPath.cgPath
            } else {
                // In RESTORE mode, draw on the restore mask layer to create "holes"
                restoreMaskLayer.path = currentPath.cgPath
            }
            
        case .ended, .cancelled:
            if currentMode == .ERASE {
                // Add current path to combined erase path
                combinedErasePath.append(currentPath)
                maskLayer.path = combinedErasePath.cgPath
            } else {
                // For RESTORE mode, clear the restore path
                // The effect has already been applied to the mask
                restoreMaskLayer.path = nil
            }
            
            // Reset current path
            currentPath = UIBezierPath()
            
        default:
            break
        }
    }
    
    // MARK: - Public Methods
    
    func resetMask() {
        combinedErasePath = UIBezierPath()
        currentPath = UIBezierPath()
        maskLayer.path = nil
        restoreMaskLayer.path = nil
    }
    
    func undo() {
        // A simple undo would require tracking individual operations
        // This is a simplified version that just clears everything
        resetMask()
    }
    
    func updateBackgroundImage(_ image: UIImage) {
        bkgImage = image
    }
}
