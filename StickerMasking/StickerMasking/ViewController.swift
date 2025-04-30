//
//  ViewController.swift
//  StickerMasking
//
//  Created by BCL Device 5 on 9/4/25.
//

import UIKit

class ViewController: UIViewController {
    
    //eraser button view
    @IBOutlet weak var eraserButtonIcon: UIImageView!
    @IBOutlet weak var eraserButtonLabel: UILabel!
    @IBOutlet weak var eraserButtonView: UIView!
    
    //restore button view
    @IBOutlet weak var restoreButtonIcon: UIImageView!
    @IBOutlet weak var restoreButtonLabel: UILabel!
    @IBOutlet weak var restoreButtonView: UIView!
    
    @IBOutlet weak var eraserThicknessSlider: UISlider!
    @IBOutlet weak var maskableView: MetalMaskingView!
    
    
    var imageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupImageView()
        setupMaskableView()
    }
    
    private func setupUI() {
        eraserButtonView.layer.cornerRadius = 8
        eraserButtonView.layer.borderWidth = 1
        eraserButtonView.layer.borderColor = UIColor.systemBlue.cgColor
        
        restoreButtonView.layer.cornerRadius = 8
        restoreButtonView.layer.borderWidth = 1
        restoreButtonView.layer.borderColor = UIColor.black.cgColor
        
        // Set initial slider value to match the default eraser width
       // eraserThicknessSlider.value = Float(maskableView.eraserWidth)
        
        // Set initial button states
        updateEraserButtonView(for: true)
        updateRestoreButtonView(for: false)
    }
    
    private func setupMaskableView() {
//        maskableView.currentMode = .ERASE
//        maskableView.bkgImage = UIImage(named: "sample") ?? UIImage()
//        maskableView.eraserColor = .white
//        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        maskableView.addGestureRecognizer(pan)
    }
    
    private func setupImageView() {
        imageView.contentMode = .scaleAspectFit
        imageView.frame = maskableView.bounds
        imageView.image = UIImage(named: "sample") // Replace "sample" with your image name
        
        // Instead of adding the imageView as a subview, update the background of DrawingCanvasView
        maskableView.updateBackgroundImage(imageView.image ?? UIImage())
    }
    
    @IBAction func eraserButtonTapped(_ sender: UIButton) {
        
        maskableView.currentMode = .erase
               updateEraserButtonView(for: true)
               updateRestoreButtonView(for: false)
    }
    
    @IBAction func restoreButtonTapped(_ sender: UIButton) {
//        maskableView.resetMask()
//                
//                // Or if we want manual restore functionality:
        maskableView.currentMode = .restore
               updateEraserButtonView(for: false)
                updateRestoreButtonView(for: true)
    }
    
    @IBAction func handleThicknessSlider(_ sender: UISlider) {
       // maskableView.eraserWidth = CGFloat(sender.value)
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        maskableView.handlePanGesture(gesture)
    }
    
    private func updateEraserButtonView(for isSelected: Bool) {
        eraserButtonView.backgroundColor = isSelected ? .systemBlue : .white
        eraserButtonLabel.textColor = isSelected ? .white : .black
        eraserButtonIcon.tintColor = isSelected ? .white : .systemBlue
    }
    
    private func updateRestoreButtonView(for isSelected: Bool) {
        restoreButtonView.backgroundColor = isSelected ? .black : .white
        restoreButtonLabel.textColor = isSelected ? .white : .black
        restoreButtonIcon.tintColor = isSelected ? .white : .black
    }
}
