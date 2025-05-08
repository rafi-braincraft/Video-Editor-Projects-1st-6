import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var videoHolderView: UIView!
    
    //eraser button view
    @IBOutlet weak var eraserButtonIcon: UIImageView!
    @IBOutlet weak var eraserButtonLabel: UILabel!
    @IBOutlet weak var eraserButtonView: UIView!
    
    //restore button view
    @IBOutlet weak var restoreButtonIcon: UIImageView!
    @IBOutlet weak var restoreButtonLabel: UILabel!
    @IBOutlet weak var restoreButtonView: UIView!
    
    @IBOutlet weak var eraserThicknessSlider: UISlider!
    @IBOutlet weak var maskableView: DrawableView!
    
    var imageView = UIImageView()
    var sampleImageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupVideoHolderAndSampleImage()
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
        
        // Set initial button states
        updateEraserButtonView(for: true)
        updateRestoreButtonView(for: false)
    }
    
    private func setupMaskableView() {
        maskableView.frame = videoHolderView.bounds
        maskableView.isUserInteractionEnabled = true
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        pan.maximumNumberOfTouches = 1
        pan.minimumNumberOfTouches = 1
        maskableView.addGestureRecognizer(pan)
    }
    
    private func setupVideoHolderAndSampleImage() {
        // Add a sample image view to videoHolderView
        sampleImageView = UIImageView(frame: videoHolderView.bounds)
        sampleImageView.contentMode = .scaleAspectFit
        sampleImageView.image = UIImage(named: "sample") // Your background image
        sampleImageView.isUserInteractionEnabled = true
        videoHolderView.addSubview(sampleImageView)
    }
    
    private func setupImageView() {
        imageView.contentMode = .scaleAspectFit
        imageView.frame = maskableView.bounds
        imageView.image = UIImage(named: "transperant") // Replace "sample" with your image name
        
        // Instead of adding the imageView as a subview, update the background of DrawingCanvasView
        maskableView.updateBackgroundImage(imageView.image ?? UIImage())
    }
    
    @IBAction func eraserButtonTapped(_ sender: UIButton) {
        maskableView.currentMode = .erase
        updateEraserButtonView(for: true)
        updateRestoreButtonView(for: false)
    }
    
    @IBAction func restoreButtonTapped(_ sender: UIButton) {
        maskableView.currentMode = .restore
        updateEraserButtonView(for: false)
        updateRestoreButtonView(for: true)
    }
    
    @IBAction func handleThicknessSlider(_ sender: UISlider) {
        // Uncomment if you want to implement this
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
