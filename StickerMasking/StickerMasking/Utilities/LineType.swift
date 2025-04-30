//
//import UIKit
//
//class DrawableView: UIView {
//
//    enum Mode {
//        case ERASE
//        case RESTORE
//    }
//
//    private var imageLayer = CALayer()
//    private var maskImageView: UIImageView!
//    private var shapeLayer: CAShapeLayer!
//    private var path: UIBezierPath!
//    private var maskImage: UIImage? {
//        didSet {
//            updateModeAppearance()
//        }
//    }
//
//    var eraserWidth: CGFloat = 20.0
//    var currentMode: Mode = .ERASE {
//        didSet {
//            updateModeAppearance()
//        }
//    }
//    var bkgImage: UIImage = UIImage()
//    private var isFirstTime = true
//
//    private var overlayLayer: CALayer!
//    private var overlayMaskLayer: CAShapeLayer!
//    private var previousTouchLocation: CGPoint?
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupLayers()
//    }
//
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        setupLayers()
//    }
//
//    override func layoutSubviews() {
//        super.layoutSubviews()
//
//        if isFirstTime {
//            isFirstTime = false
//
//            imageLayer.frame = bounds
//            maskImageView.frame = bounds
//            shapeLayer.frame = bounds
//            overlayLayer.frame = bounds
//            overlayMaskLayer.frame = bounds
//
//            if maskImage == nil {
//                maskImage = createTransparentImage()
//                maskImageView.image = maskImage
//            }
//        }
//    }
//
//    private func setupLayers() {
//        backgroundColor = .clear
//
//        // Setup image layer
//        imageLayer.frame = bounds
//        imageLayer.contentsGravity = .resizeAspectFill
//        layer.addSublayer(imageLayer)
//
//        // Create transparent image view for mask
//        maskImageView = UIImageView(frame: bounds)
//        maskImageView.backgroundColor = .clear
//
//        // Setup shape layer for drawing
//        shapeLayer = CAShapeLayer()
//        shapeLayer.fillColor = nil
//        shapeLayer.lineWidth = eraserWidth
//        shapeLayer.lineCap = .round
//        shapeLayer.lineJoin = .round
//
//        // Add shape layer to mask image view
//        maskImageView.layer.addSublayer(shapeLayer)
//
//        // Apply mask image view as mask to image layer
//        imageLayer.mask = maskImageView.layer
//
//        // Setup overlay layer for restore mode highlighting
//        overlayLayer = CALayer()
//        overlayLayer.frame = bounds
//        overlayLayer.backgroundColor = UIColor.red.withAlphaComponent(0.8).cgColor
//        overlayLayer.isHidden = true
//        layer.addSublayer(overlayLayer)
//
//        // Setup mask for overlay layer (inverse of the main mask)
//        overlayMaskLayer = CAShapeLayer()
//        overlayMaskLayer.frame = bounds
//        overlayMaskLayer.fillColor = UIColor.black.cgColor
//        overlayLayer.mask = overlayMaskLayer
//
//        // Initialize path
//        path = UIBezierPath()
//    }
//
//    private func updateModeAppearance() {
//        overlayLayer.isHidden = currentMode != .RESTORE
//        shapeLayer.strokeColor = currentMode == .ERASE ?
//            UIColor.white.cgColor : UIColor.clear.cgColor
//        updateOverlayMask()
//    }
//
//    private func updateOverlayMask() {
//        guard let maskImage = maskImage else { return }
//
//        let ciImage = CIImage(image: maskImage)
//        let filter = CIFilter(name: "CIMaskToAlpha")
//        filter?.setValue(ciImage, forKey: kCIInputImageKey)
//
//        if let outputImage = filter?.outputImage {
//            let context = CIContext(options: nil)
//            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
//                overlayMaskLayer.contents = cgImage
//            }
//        }
//    }
//
//    // Changed from private to internal (by removing private)
//    func updateBackgroundImage(_ image: UIImage) {
//        bkgImage = image
//        imageLayer.contents = image.cgImage
//    }
//
//    private func createTransparentImage() -> UIImage? {
//        let renderer = UIGraphicsImageRenderer(size: bounds.size)
//        return renderer.image { ctx in
//            UIColor.clear.setFill()
//            ctx.fill(bounds)
//        }
//    }
//
//    func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
//        let location = gesture.location(in: self)
//
//        switch gesture.state {
//        case .began:
//            previousTouchLocation = location
//            path = UIBezierPath()
//            path.move(to: location)
//
//        case .changed:
//            guard previousTouchLocation != nil else { return }
//            path.addLine(to: location)
//            shapeLayer.path = path.cgPath
//            previousTouchLocation = location
//
//        case .ended, .cancelled:
//            if let blendedImage = blendShapeLayerWithImage() {
//                maskImage = blendedImage
//                maskImageView.image = maskImage
//                updateOverlayMask()
//            }
//            shapeLayer.path = nil
//            previousTouchLocation = nil
//
//        default:
//            break
//        }
//    }
//
//    private func blendShapeLayerWithImage() -> UIImage? {
//        let renderer = UIGraphicsImageRenderer(size: bounds.size)
//        return renderer.image { ctx in
//            maskImage?.draw(at: .zero)
//
//            if let path = shapeLayer.path {
//                ctx.cgContext.addPath(path)
//                ctx.cgContext.setLineWidth(eraserWidth)
//                ctx.cgContext.setLineCap(.round)
//                ctx.cgContext.setLineJoin(.round)
//
//                if currentMode == .ERASE {
//                    ctx.cgContext.setStrokeColor(UIColor.white.cgColor)
//                } else {
//                    ctx.cgContext.setBlendMode(.clear)
//                    ctx.cgContext.setStrokeColor(UIColor.clear.cgColor)
//                }
//
//                ctx.cgContext.strokePath()
//            }
//        }
//    }
//
//    func resetMask() {
//        maskImage = createTransparentImage()
//        maskImageView.image = maskImage
//        shapeLayer.path = nil
//        updateOverlayMask()
//    }
//}







//import UIKit
//
//class DrawableView: UIView {
//
//    enum Mode {
//        case ERASE
//        case RESTORE
//    }
//    
//    // Store operations in chronological order with their mode
//    private struct DrawOperation {
//        let path: UIBezierPath
//        let mode: Mode
//    }
//    
//    // Custom mask layer class for drawing
//    private class CustomMaskLayer: CALayer {
//        // Keep operations in chronological order
//        var operations = [DrawOperation]()
//        
//        // Current drawing paths
//        var currentPath: UIBezierPath?
//        var currentMode: Mode = .ERASE
//        
//        var lineWidth: CGFloat = 20.0
//        
//        override func draw(in ctx: CGContext) {
//            // Set up context
//            ctx.setLineCap(.round)
//            ctx.setLineJoin(.round)
//            ctx.setLineWidth(lineWidth)
//            
//            // Start with a clear canvas
//            ctx.clear(bounds)
//            
//            // Draw all operations in chronological order
//            for operation in operations {
//                if operation.mode == .ERASE {
//                    // Draw with white to reveal
//                    ctx.setBlendMode(.normal)
//                    ctx.setStrokeColor(UIColor.white.cgColor)
//                } else {
//                    // Draw with clear to erase
//                    ctx.setBlendMode(.clear)
//                    ctx.setStrokeColor(UIColor.black.cgColor) // Color doesn't matter with clear blend
//                }
//                
//                ctx.addPath(operation.path.cgPath)
//                ctx.strokePath()
//            }
//            
//            // Draw current operation
//            if let currentPath = currentPath {
//                if currentMode == .ERASE {
//                    // Draw with white to reveal
//                    ctx.setBlendMode(.normal)
//                    ctx.setStrokeColor(UIColor.white.cgColor)
//                } else {
//                    // Draw with clear to erase
//                    ctx.setBlendMode(.clear)
//                    ctx.setStrokeColor(UIColor.black.cgColor) // Color doesn't matter with clear blend
//                }
//                
//                ctx.addPath(currentPath.cgPath)
//                ctx.strokePath()
//            }
//        }
//    }
//
//    // Main image layer
//    private var imageLayer = CALayer()
//    
//    // Custom mask layer
//    private var maskLayer = CustomMaskLayer()
//    
//    // Current path being drawn
//    private var currentPath = UIBezierPath()
//
//    var eraserWidth: CGFloat = 20.0 {
//        didSet {
//            maskLayer.lineWidth = eraserWidth
//        }
//    }
//    
//    var currentMode: Mode = .ERASE {
//        didSet {
//            maskLayer.currentMode = currentMode
//            // Reset current path for new mode
//            currentPath = UIBezierPath()
//            maskLayer.currentPath = nil
//        }
//    }
//    
//    var bkgImage: UIImage = UIImage() {
//        didSet {
//            imageLayer.contents = bkgImage.cgImage
//        }
//    }
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupLayers()
//    }
//
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        setupLayers()
//    }
//
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        
//        // Update frames
//        imageLayer.frame = bounds
//        maskLayer.frame = bounds
//        
//        // Make sure mask is redrawn
//        maskLayer.setNeedsDisplay()
//    }
//
//    private func setupLayers() {
//        backgroundColor = .clear
//
//        // Setup image layer
//        imageLayer.frame = bounds
//        imageLayer.contentsGravity = .resizeAspectFill
//        layer.addSublayer(imageLayer)
//        
//        // Setup mask layer
//        maskLayer.frame = bounds
//        maskLayer.lineWidth = eraserWidth
//        maskLayer.isOpaque = false
//        
//        // Apply mask to image
//        imageLayer.mask = maskLayer
//    }
//
//    func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
//        let location = gesture.location(in: self)
//
//        switch gesture.state {
//        case .began:
//            // Start new path
//            currentPath = UIBezierPath()
//            currentPath.move(to: location)
//            
//            // Set current path in mask layer
//            maskLayer.currentPath = currentPath
//            
//            // Trigger redraw
//            //maskLayer.setNeedsDisplay()
//
//        case .changed:
//            // Add to current path
//            currentPath.addLine(to: location)
//            
//            // Update the current path in mask layer (reference is already set)
//            
//            // Trigger redraw
//            maskLayer.setNeedsDisplay()
//
//        case .ended, .cancelled:
//            // Add completed path to history
//            if let path = maskLayer.currentPath {
//                // Create a copy of the path to store
//                let completedPath = UIBezierPath(cgPath: path.cgPath)
//                
//                // Add to operations list
//                let operation = DrawOperation(path: completedPath, mode: currentMode)
//                maskLayer.operations.append(operation)
//            }
//            
//            // Clear current path reference
//            maskLayer.currentPath = nil
//            currentPath = UIBezierPath()
//            
//            // Trigger final redraw
//            maskLayer.setNeedsDisplay()
//            
//        default:
//            break
//        }
//    }
//
//    func resetMask() {
//        // Clear all operations
//        maskLayer.operations.removeAll()
//        maskLayer.currentPath = nil
//        currentPath = UIBezierPath()
//        
//        // Redraw
//        maskLayer.setNeedsDisplay()
//    }
//
//    func updateBackgroundImage(_ image: UIImage) {
//        bkgImage = image
//        imageLayer.contents = image.cgImage
//    }
//}





//
//  LineType.swift
//  StickerMasking
//
//  Created by BCL Device 5 on 16/4/25.
//

//import UIKit
//
//class DrawableView: UIView {
//
//    enum Mode {
//        case ERASE
//        case RESTORE
//    }
//
//    private var imageLayer = CALayer()
//    private var maskLayer = CAShapeLayer()
//
//    var eraserWidth: CGFloat = 20.0
//    var eraserColor: UIColor = .white
//    var currentMode: Mode = .ERASE
//    var bkgImage: UIImage = UIImage()
//
//    var isFirstTime = true
//
//    private var originalMaskPath: UIBezierPath?
//    private var lastPoint: CGPoint?
//    private var firstPoint: CGPoint?
//    // Main path for the entire view (bounds)
//    private var mainPath = UIBezierPath()
//    // Path for erasing
//    private var erasePath: UIBezierPath?
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupLayers()
//    }
//
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        setupLayers()
//    }
//
//    override func layoutSubviews() {
//        super.layoutSubviews()
//
//        if isFirstTime {
//            isFirstTime = false
//
//            imageLayer.frame = bounds
//            maskLayer.frame = bounds
//
//            if originalMaskPath == nil {
//                originalMaskPath = UIBezierPath(rect: bounds)
//                mainPath = UIBezierPath(rect: bounds)
//                maskLayer.path = mainPath.cgPath
//            }
//        }
//    }
//
//    private func setupLayers() {
//        backgroundColor = .clear
//
//        imageLayer.frame = bounds
//        imageLayer.contentsGravity = .resizeAspectFill
//        layer.addSublayer(imageLayer)
//
//        maskLayer.frame = bounds
//        maskLayer.fillColor = UIColor.red.cgColor // Black fill shows the image
//
//        mainPath = UIBezierPath(rect: bounds)
//        maskLayer.path = mainPath.cgPath
//        originalMaskPath = mainPath.copy() as? UIBezierPath
//
//        imageLayer.mask = maskLayer
//    }
//
//    private func updateMask() {
//        // Start with the main path
//        let visiblePath = UIBezierPath(rect: bounds)
//
//        // Add the erase path to create "holes" in the mask
//        if let erasePath = self.erasePath {
//            visiblePath.append(erasePath)
////            visiblePath.usesEvenOddFillRule = true
//        }
//
//        CATransaction.begin()
//        CATransaction.setDisableActions(true)
//        maskLayer.path = visiblePath.cgPath
////        maskLayer.fillRule = .evenOdd
//        CATransaction.commit()
//    }
//
//    func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
//        let location = gesture.location(in: self)
//
//        switch gesture.state {
//        case .began:
//            // Start new stroke
//            lastPoint = location
//            firstPoint = location
//
//            // Create new erase path for stroke drawing
//            erasePath = UIBezierPath()
//            erasePath?.lineWidth = eraserWidth
//            erasePath?.lineCapStyle = .round
//            erasePath?.lineJoinStyle = .round
//            erasePath?.move(to: location)
//
//            // No need to update the mask yet - don't make anything transparent at the beginning
//
//        case .changed:
//            // Add line to the path
//            erasePath?.addLine(to: location)
//            lastPoint = location
//
//            // Create a stroked version of the path for masking
//            let strokedPath = createStrokedPath()
//
//            // Update the mask with the stroked path
//            let visiblePath = UIBezierPath(rect: bounds)
//            visiblePath.append(strokedPath)
////            visiblePath.usesEvenOddFillRule = true
//
//            CATransaction.begin()
//            CATransaction.setDisableActions(true)
//            maskLayer.path = visiblePath.cgPath
//            self.maskLayer.fillRule = .evenOdd
//            CATransaction.commit()
//
//        case .ended, .cancelled:
//            // Create final stroked path with caps
//            let strokedPath = createStrokedPath()
//
//            // Update the mask with the final path
//            let visiblePath = UIBezierPath(rect: bounds)
//            visiblePath.append(strokedPath)
//            //visiblePath.usesEvenOddFillRule = true
//
//            CATransaction.begin()
//            CATransaction.setDisableActions(true)
//            self.maskLayer.path = visiblePath.cgPath
//            //maskLayer.fillRule = .evenOdd
//            CATransaction.commit()
//
//            // Reset for next stroke but keep the mask effect
//            self.lastPoint = nil
//            self.firstPoint = nil
//            self.erasePath = nil
//
//        default:
//            break
//        }
//    }
//
//    // Create a stroked version of the path for masking
//    private func createStrokedPath() -> UIBezierPath {
//        guard let path = erasePath?.copy() as? UIBezierPath else {
//            return UIBezierPath()
//        }
//
//        // Configure the path for stroking
//        path.lineWidth = eraserWidth
//        path.lineCapStyle = .round
//        path.lineJoinStyle = .round
//
//        // Convert the stroked path to a filled path
//        // Since copy(strokingWithWidth:) returns a non-optional CGPath, we don't need if let
//        let cgPath = path.cgPath.copy(strokingWithWidth: eraserWidth,
//                                      lineCap: .round,
//                                      lineJoin: .round,
//                                      miterLimit: 0)
//
//        return UIBezierPath(cgPath: cgPath)
//    }
//
//    func resetMask() {
//        guard let originalPath = originalMaskPath else { return }
//
//        CATransaction.begin()
//        let animation = CABasicAnimation(keyPath: "path")
//        animation.duration = 0.3
//        animation.fromValue = maskLayer.path
//        animation.toValue = originalPath.cgPath
//        maskLayer.add(animation, forKey: "pathAnimation")
//        CATransaction.commit()
//
//        maskLayer.path = originalPath.cgPath
//        maskLayer.fillRule = .nonZero
//
//        erasePath = nil
//    }
//
//    func updateBackgroundImage(_ image: UIImage) {
//        bkgImage = image
//        imageLayer.contents = image.cgImage
//    }
//}
////
////import UIKit
////
////class DrawableView: UIView {
////
////    enum Mode {
////        case ERASE
////        case RESTORE
////    }
////
////    private var imageLayer = CALayer()
////    private var maskLayer = CAShapeLayer()
////
////    var eraserWidth: CGFloat = 20.0
////    var eraserColor: UIColor = .white
////    var currentMode: Mode = .ERASE
////    var bkgImage: UIImage = UIImage()
////
////    private var isFirstTime = true
////
////    private var originalMaskPath: UIBezierPath?
////    private var lastPoint: CGPoint?
////    private var allStrokedPaths: [UIBezierPath] = []
////
////    private var currentPath: UIBezierPath?
////
////    override init(frame: CGRect) {
////        super.init(frame: frame)
////        setupLayers()
////    }
////
////    required init?(coder: NSCoder) {
////        super.init(coder: coder)
////        setupLayers()
////    }
////
////    override func layoutSubviews() {
////        super.layoutSubviews()
////
////        if isFirstTime {
////            isFirstTime = false
////
////            imageLayer.frame = bounds
////            maskLayer.frame = bounds
////
////            if originalMaskPath == nil {
////                let fullPath = UIBezierPath(rect: bounds)
////                originalMaskPath = fullPath
////                updateMaskLayer()
////            }
////        }
////    }
////
////    private func setupLayers() {
////        backgroundColor = .clear
////
////        imageLayer.frame = bounds
////        imageLayer.contentsGravity = .resizeAspectFill
////        layer.addSublayer(imageLayer)
////
////        maskLayer.frame = bounds
////        maskLayer.fillColor = UIColor.black.cgColor
////
////        imageLayer.mask = maskLayer
////    }
////
////    func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
////        let location = gesture.location(in: self)
////
////        switch gesture.state {
////        case .began:
////            currentPath = UIBezierPath()
////            currentPath?.lineWidth = eraserWidth
////            currentPath?.lineCapStyle = .round
////            currentPath?.lineJoinStyle = .round
////            currentPath?.move(to: location)
////
////        case .changed:
////            currentPath?.addLine(to: location)
////            updateMaskLayer(tempPath: currentPath)
////
////        case .ended, .cancelled:
////            if let currentPath = currentPath {
////                let strokedPath = strokedVersion(of: currentPath)
////                allStrokedPaths.append(strokedPath)
////            }
////            updateMaskLayer()
////            currentPath = nil
////
////        default:
////            break
////        }
////    }
////
////    private func strokedVersion(of path: UIBezierPath) -> UIBezierPath {
////        let cgStrokedPath = path.cgPath.copy(strokingWithWidth: eraserWidth, lineCap: .round, lineJoin: .round, miterLimit: 0)
////        return UIBezierPath(cgPath: cgStrokedPath)
////    }
////
////    private func updateMaskLayer(tempPath: UIBezierPath? = nil) {
////        let combinedPath = CGMutablePath()
////        combinedPath.addRect(bounds) // Full background (non-erased)
////
////        // Combine all permanent erasures
////        for path in allStrokedPaths {
////            combinedPath.addPath(path.cgPath)
////        }
////
////        // Add temporary path (if panning)
////        if let tempPath = tempPath {
////            combinedPath.addPath(strokedVersion(of: tempPath).cgPath)
////        }
////
////        CATransaction.begin()
////        CATransaction.setDisableActions(true)
////        maskLayer.path = combinedPath
////        //maskLayer.fillRule = .nonZero // ⭐️ Changed to .nonZero
////        CATransaction.commit()
////    }
////
////    func resetMask() {
////        allStrokedPaths.removeAll()
////        currentPath = nil
////        updateMaskLayer()
////    }
////
////    func updateBackgroundImage(_ image: UIImage) {
////        bkgImage = image
////        imageLayer.contents = image.cgImage
////    }
////}
import UIKit

enum LineType: Int {
    case DRAW
    case ERASE
    case RESTORE
}

class LineDef: NSObject {
    var lineType: LineType = .DRAW
    var color: UIColor = UIColor.black
    var opacity: Float = 1.0
    var lineWidth: CGFloat = 8.0
    var points: [CGPoint] = [CGPoint]()
}

class MaskableView: UIView {
    
    var bkgImage: UIImage = UIImage() {
        didSet {
            updateBkgImage()
        }
    }
    var currentMode: LineType = .ERASE {
        didSet {
            currentLineDef = nil
        }
    }
    var currentLineDef: LineDef?
    var eraserColor: UIColor = UIColor.white
    var eraserOpacity: Float = 1.0
    
    func updateBkgImage() {
        if layer.sublayers == nil {
            let l = CALayer()
            layer.addSublayer(l)
        }
        guard let layers = layer.sublayers else { return }
        for l in layers {
            if !(l is CAShapeLayer) {
                l.contents = bkgImage.cgImage
            }
        }
        setNeedsDisplay()
    }
    
    func undo() {
        guard let n = layer.sublayers?.count, n > 1 else { return }
        _ = layer.sublayers?.popLast()
    }
    
    func addLineDef(_ def: LineDef) {
        switch def.lineType {
        case .DRAW:
            addDrawLayer(def)
        case .ERASE:
            addEraseLayer(def)
        case .RESTORE:
            addRestoreLayer(def)
        }
        setNeedsDisplay()
    }
    
    private func addDrawLayer(_ def: LineDef) {
        let newLayer = CAShapeLayer()
        newLayer.lineCap = .round
        newLayer.lineWidth = def.lineWidth
        newLayer.opacity = def.opacity
        newLayer.strokeColor = def.color.cgColor
        newLayer.fillColor = UIColor.clear.cgColor
        
        let bez = UIBezierPath()
        for pt in def.points {
            if pt == def.points.first {
                bez.move(to: pt)
            } else {
                bez.addLine(to: pt)
            }
        }
        newLayer.path = bez.cgPath
        layer.addSublayer(newLayer)
    }
    
    private func addEraseLayer(_ def: LineDef) {
        let newLayer = CALayer()
        newLayer.contents = bkgImage.cgImage
        newLayer.opacity = def.opacity
        
        let maskLayer = CAShapeLayer()
        maskLayer.lineCap = .round
        maskLayer.lineWidth = def.lineWidth
        maskLayer.strokeColor = UIColor.black.cgColor
        maskLayer.fillColor = UIColor.clear.cgColor
        
        let bez = UIBezierPath()
        for pt in def.points {
            if pt == def.points.first {
                bez.move(to: pt)
            } else {
                bez.addLine(to: pt)
            }
        }
        maskLayer.path = bez.cgPath
        newLayer.mask = maskLayer
        layer.addSublayer(newLayer)
    }
    
    private func addRestoreLayer(_ def: LineDef) {
        let newLayer = CAShapeLayer()
        newLayer.lineCap = .round
        newLayer.lineWidth = def.lineWidth
        newLayer.opacity = def.opacity
        newLayer.strokeColor = eraserColor.cgColor
        newLayer.fillColor = UIColor.clear.cgColor
        
        let bez = UIBezierPath()
        for pt in def.points {
            if pt == def.points.first {
                bez.move(to: pt)
            } else {
                bez.addLine(to: pt)
            }
        }
        newLayer.path = bez.cgPath
        layer.addSublayer(newLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let layers = layer.sublayers {
            for l in layers {
                l.frame = bounds
            }
        }
    }
    
    func startDrawing(at point: CGPoint) {
        let line = LineDef()
        line.lineType = currentMode
        line.lineWidth = currentMode == .ERASE ? eraserWidth : restoreWidth
        line.opacity = currentMode == .ERASE ? 0 : eraserOpacity
        line.points.append(point)
        currentLineDef = line
    }
    
    func continueDrawing(at point: CGPoint) {
        guard let def = currentLineDef else { return }
        def.points.append(point)
        addLineDef(def)
        currentLineDef = def
    }
    
    func endDrawing() {
        currentLineDef = nil
    }
    
    // Default values - can be changed via slider
    var eraserWidth: CGFloat = 20.0
    var restoreWidth: CGFloat = 20.0
}

