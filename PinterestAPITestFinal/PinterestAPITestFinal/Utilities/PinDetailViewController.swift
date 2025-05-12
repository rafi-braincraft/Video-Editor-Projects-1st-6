//
//  PinDetailViewController.swift
//  PinterestAPITestFinal
//
//  Created by BCL Device 5 on 12/5/25.
//


import UIKit

class PinDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    var pin: Pin!
    private var imageURL: URL?
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = .white
        scrollView.contentInsetAdjustmentBehavior = .never
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkGray
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.color = .darkGray
        return indicator
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Save Image", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = UIColor(red: 0.9, green: 0.0, blue: 0.0, alpha: 1.0) // Pinterest red
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(saveImageTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var visitButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Visit Pin", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .white
        button.setTitleColor(UIColor(red: 0.9, green: 0.0, blue: 0.0, alpha: 1.0), for: .normal)
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(red: 0.9, green: 0.0, blue: 0.0, alpha: 1.0).cgColor
        button.addTarget(self, action: #selector(visitPinTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureWithPin()
        setupGestures()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // Add a close button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeTapped)
        )
        
        // Add scroll view
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Add components to content view
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(saveButton)
        contentView.addSubview(visitButton)
        
        // Add activity indicator
        view.addSubview(activityIndicator)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // Content view
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Image view
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1.3), // Adjust aspect ratio as needed
            
            // Title label
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Description label
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Save button
            saveButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 24),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            saveButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Visit button
            visitButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 12),
            visitButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            visitButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            visitButton.heightAnchor.constraint(equalToConstant: 44),
            visitButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            
            // Activity indicator
            activityIndicator.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
        ])
    }
    
    private func setupGestures() {
        // Add pinch gesture for zoom
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        imageView.addGestureRecognizer(pinchGesture)
        
        // Add double tap gesture for reset zoom
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        imageView.addGestureRecognizer(doubleTapGesture)
    }
    
    // MARK: - Configure View
    
    private func configureWithPin() {
        guard let pin = pin else { return }
        
        // Set title and description
        titleLabel.text = pin.title ?? "Untitled Pin"
        descriptionLabel.text = pin.description ?? "No description available"
        
        // Set title in navigation bar
        navigationItem.title = "Pin Details"
        
        // Hide visit button if no link
        if pin.link == nil {
            visitButton.isHidden = true
            
            // Update constraint to account for hidden button
            if let lastConstraint = contentView.constraints.last {
                NSLayoutConstraint.deactivate([lastConstraint])
                contentView.bottomAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 24).isActive = true
            }
        }
        
        // Load image
        loadPinImage()
    }
    
    private func loadPinImage() {
        activityIndicator.startAnimating()
        
        // Get the best available image URL
        let possibleImageURL = pin.media?.images?.originals?.url ?? 
                               pin.media?.images?.x474x?.url ??
                               pin.media?.images?.x236x?.url
        
        guard let imageURLString = possibleImageURL, 
              let url = URL(string: imageURLString) else {
            activityIndicator.stopAnimating()
            showAlert(title: "Error", message: "Could not load image")
            return
        }
        
        self.imageURL = url
        
        // Load image
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.imageView.image = image
                    self.activityIndicator.stopAnimating()
                }
            } else {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.activityIndicator.stopAnimating()
                    self.showAlert(title: "Error", message: "Failed to load image")
                }
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    @objc private func saveImageTapped() {
        guard let image = imageView.image else {
            showAlert(title: "Error", message: "No image to save")
            return
        }
        
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc private func visitPinTapped() {
        guard let link = pin.link, let url = URL(string: link) else {
            showAlert(title: "Error", message: "Invalid PIN URL")
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            showAlert(title: "Error", message: "Cannot open URL")
        }
    }
    
    @objc private func handlePinchGesture(_ gesture: UIPinchGestureRecognizer) {
        guard let view = gesture.view else { return }
        
        if gesture.state == .began || gesture.state == .changed {
            view.transform = view.transform.scaledBy(x: gesture.scale, y: gesture.scale)
            gesture.scale = 1.0
        }
    }
    
    @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        // Reset zoom on double tap
        UIView.animate(withDuration: 0.3) {
            self.imageView.transform = .identity
        }
    }
    
    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            showAlert(title: "Error", message: "Save failed: \(error.localizedDescription)")
        } else {
            showAlert(title: "Success", message: "Image saved to your photo library")
        }
    }
    
    // MARK: - Helper Methods
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
