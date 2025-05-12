//
//  PinsViewController.swift
//  pinterestAPIReleaseAdition
//
//  Created by BCL Device 5 on 12/5/25.
//


import UIKit

class PinsViewController: UIViewController {
    
    // MARK: - Properties
    
    private var pins: [Pin] = []
    private var bookmark: String?
    private var isLoading = false
    private var user: User?
    
    // MARK: - UI Components
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
        
        // Calculate cell size based on screen width
        let screenWidth = UIScreen.main.bounds.width
        let cellWidth = (screenWidth - 6) / 2 // 2 columns with 2pt padding
        
        layout.itemSize = CGSize(width: cellWidth, height: cellWidth * 1.5) // 3:2 aspect ratio
        layout.sectionInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(PinCollectionViewCell.self, forCellWithReuseIdentifier: PinCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        return collectionView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private let refreshControl = UIRefreshControl()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        loadUserProfile()
        loadPins()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "My Pins"
        
        // Add logout button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Logout",
            style: .plain,
            target: self,
            action: #selector(logoutTapped)
        )
        
        // Add collection view
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Add activity indicator
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // Add pull to refresh
        refreshControl.addTarget(self, action: #selector(refreshPins), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    // MARK: - Data Loading
    
    private func loadUserProfile() {
        PinterestAPIManager.shared.getUserProfile { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self?.user = user
                    self?.title = "\(user.username)'s Pins"
                case .failure(let error):
                    print("Error loading profile: \(error)")
                }
            }
        }
    }
    
    private func loadPins(isRefresh: Bool = false) {
        guard !isLoading else { return }
        
        isLoading = true
        
        if !isRefresh && pins.isEmpty {
            activityIndicator.startAnimating()
        }
        
        // If refreshing, clear bookmark for a fresh start
        let bookmarkToUse = isRefresh ? nil : bookmark
        
        PinterestAPIManager.shared.getUserPins(bookmark: bookmarkToUse) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                self.isLoading = false
                self.activityIndicator.stopAnimating()
                self.refreshControl.endRefreshing()
                
                switch result {
                case .success(let pinsResponse):
                    if isRefresh {
                        self.pins = pinsResponse.items
                    } else {
                        self.pins.append(contentsOf: pinsResponse.items)
                    }
                    
                    self.bookmark = pinsResponse.bookmark
                    self.collectionView.reloadData()
                    
                    // Show empty state if needed
                    if self.pins.isEmpty {
                        self.showEmptyState()
                    }
                    
                case .failure(let error):
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    @objc private func refreshPins() {
        loadPins(isRefresh: true)
    }
    
    private func loadMorePins() {
        // Only load more if we have a bookmark and not already loading
        if let _ = bookmark, !isLoading {
            loadPins()
        }
    }
    
    // MARK: - Actions
    
    @objc private func logoutTapped() {
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive) { [weak self] _ in
            PinterestAPIManager.shared.logout()
            
            // Return to login screen
            self?.dismiss(animated: true)
            self?.navigationController?.popToRootViewController(animated: true)
        })
        
        present(alert, animated: true)
    }
    
    // MARK: - Helper Methods
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showEmptyState() {
        let emptyLabel = UILabel()
        emptyLabel.text = "No pins found"
        emptyLabel.textAlignment = .center
        emptyLabel.font = UIFont.systemFont(ofSize: 18)
        emptyLabel.textColor = .gray
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(emptyLabel)
        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

// MARK: - UICollectionViewDataSource

extension PinsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pins.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PinCollectionViewCell.identifier, for: indexPath) as? PinCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let pin = pins[indexPath.item]
        cell.configure(with: pin)
        
        // If we're approaching the end of the list, load more pins
        if indexPath.item == pins.count - 5 && bookmark != nil {
            loadMorePins()
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension PinsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Handle pin selection if needed
        let pin = pins[indexPath.item]
        
        // Open the pin in Safari if it has a link
        if let link = pin.link, let url = URL(string: link), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}