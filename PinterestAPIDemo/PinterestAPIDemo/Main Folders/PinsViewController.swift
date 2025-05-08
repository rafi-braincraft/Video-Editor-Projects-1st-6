//
//  PinsViewController 2.swift
//  PinterestAPIDemo
//
//  Created by BCL Device 5 on 8/5/25.
//


// PinsViewController.swift
import UIKit

class PinsViewController: UIViewController {
    
    @IBOutlet weak var pinsCollectionView: UICollectionView!
    
    private var pins: [Pin] = []
    private let cellIdentifier = "PinCell"
    private var loadingIndicator = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupLoadingIndicator()
        
        // Check if we're authenticated
        if PinterestAPI.shared.isAuthenticated {
            fetchPins()
        } else {
            // If not authenticated, go back to login screen
            navigationController?.popViewController(animated: true)
        }
    }
    
    private func setupLoadingIndicator() {
        loadingIndicator.center = view.center
        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)
    }
    
    private func setupCollectionView() {
        // Register cell
        pinsCollectionView.register(PinCell.self, forCellWithReuseIdentifier: cellIdentifier)
        
        // Set delegate and data source
        pinsCollectionView.delegate = self
        pinsCollectionView.dataSource = self
        
        // Set up flow layout
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        // Create a Pinterest-style grid
        let width = (view.bounds.width - 30) / 2  // 10 points spacing on each side and between items
        layout.itemSize = CGSize(width: width, height: width * 1.3)  // Slightly taller than wide
        
        pinsCollectionView.collectionViewLayout = layout
        pinsCollectionView.backgroundColor = .systemGray6
    }
    
    private func fetchPins() {
        // Show loading indicator
        loadingIndicator.startAnimating()
        
        PinterestAPI.shared.fetchUserPins { [weak self] result in
            DispatchQueue.main.async {
                self?.loadingIndicator.stopAnimating()
                
                switch result {
                case .success(let pins):
                    self?.pins = pins
                    self?.pinsCollectionView.reloadData()
                    
                    // If no pins, show message
                    if pins.isEmpty {
                        self?.showNoContentMessage()
                    }
                    
                case .failure(let error):
                    self?.showError(error)
                }
            }
        }
    }
    
    private func showNoContentMessage() {
        let messageLabel = UILabel()
        messageLabel.text = "No pins found. Create some pins on Pinterest first!"
        messageLabel.textAlignment = .center
        messageLabel.textColor = .gray
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // Add logout functionality
    @IBAction func logoutTapped(_ sender: Any) {
        PinterestAPI.shared.logout()
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension PinsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pins.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! PinCell
        let pin = pins[indexPath.item]
        cell.configure(with: pin)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Handle pin selection - you can navigate to a detail view or open the pin's URL
        let pin = pins[indexPath.item]
        if let link = pin.link, let url = URL(string: link), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}