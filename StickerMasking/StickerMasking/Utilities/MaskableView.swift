//
//  MaskableView.swift
//  StickerMasking
//
//  Created by BCL Device 5 on 9/4/25.
//

import UIKit

class OldMaskableView: UIView {
    
    private var isFirstTime = true
    private var maskImage: UIImage? = nil
    private var renderer: UIGraphicsImageRenderer?
    private var shapeLayer = CAShapeLayer()
    private var maskLayer = CALayer()
    private var panGestureRecognizer = ImmediatePanGestureRecogniser()
    private var lastErasePoint: CGPoint?
    
    @objc @IBInspectable public var eraserRadius: CGFloat = 20 {
        didSet {
            if lastErasePoint == nil {
                lastErasePoint = CGPoint(x: bounds.midX, y: bounds.midY)
            }
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.2)
            
            if let position = lastErasePoint {
                let rect = CGRect(origin: position, size: CGSize.zero).insetBy(dx: -eraserRadius/2, dy: -eraserRadius/2)
                let circlePath = UIBezierPath(ovalIn: rect)
                shapeLayer.path = circlePath.cgPath
            }
            
            CATransaction.commit()
        }
            
    }
    
    @objc @IBInspectable public var eraserColor: UIColor? = nil {
        didSet {
            shapeLayer.fillColor = eraserColor?.cgColor
        }
    }
    
    public var drawingAction: DrawingAction = .erase
    public var rendererImage: UIImage? {
        guard let renderer = renderer else { return nil }
        
        let result = renderer.image  { [weak self] in
            guard let self = self else { return }
            
            return layer.render(in: $0.cgContext)
        }
        return result
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        //shapeLayer.backgroundColor = eraserColor?.cgColor
        shapeLayer.lineWidth = 2
        shapeLayer.fillColor = eraserColor?.cgColor
        
        layer.mask = maskLayer
        panGestureRecognizer.addTarget(self, action: #selector(handlePanGesture(_:)))
        self.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc func handlePanGesture(_ sender: ImmediatePanGestureRecogniser) {
        let point = sender.location(in: self)

        if(sender.state != .ended) {
            drawPath(at: point)
        }
    }
    
    private func drawPath(at point: CGPoint) {
        guard let renderer = renderer else { return }
        
        lastErasePoint = point
        
        let image = renderer.image { context in
            if let maskImage = maskImage {
                maskImage.draw(in: bounds)
                
                let rect = CGRect(origin: point, size: CGSize.zero).insetBy(dx: -eraserRadius/2, dy: -eraserRadius/2)
                let color = UIColor.black.cgColor
                context.cgContext.setFillColor(color)
                
                let blendMode: CGBlendMode
                let alpha: CGFloat
                if drawingAction == .erase {
                    blendMode = .sourceIn
                    alpha = 0
                } else {
                    blendMode = .normal
                    alpha = 1
                }
                
                if eraserColor != nil {
                    let circlePath = UIBezierPath(ovalIn: rect)
                    circlePath.fill(with: blendMode, alpha: alpha)
                    shapeLayer.path = circlePath.cgPath
                }
            }
        }
        
        maskImage = image
        maskLayer.contents = maskImage?.cgImage
    }
    
    public func updateBounds() {
        maskLayer.frame = bounds
        shapeLayer.frame = layer.frame
        
        if isFirstTime {
            renderer = UIGraphicsImageRenderer(size: bounds.size)
            installFirstTimeMask()
            layer.superlayer?.addSublayer(shapeLayer)
            isFirstTime = false
        } else {
            guard let renderer = renderer else { return }
            let image = renderer.image { context in
                if let maskImage = maskImage {
                    maskImage.draw(in: bounds)
                }
            }
            
            maskImage = image
            maskLayer.contents = maskImage?.cgImage
        }
    }
    
    private func installFirstTimeMask() {
        guard let renderer = renderer else { return }
        let image = renderer.image { context in
            UIColor.black.setFill()
            context.fill(bounds,blendMode: .normal)
        }
        
        maskImage = image
        maskLayer.contents = maskImage?.cgImage
    }
    
}



