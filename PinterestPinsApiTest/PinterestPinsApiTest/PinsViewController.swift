//
//  PinsViewController.swift
//  PinterestPinsApiTest
//
//  Created by BCL Device 5 on 14/5/25.
//


import UIKit

class PinsViewController: UIViewController {
    // MARK: - Properties
    private var pins: [Pin] = []
    private var nextPaginationToken: String?
    private var isLoading = false
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 16
        let width = (view.bounds.width - 24) / 2 // 2 columns with padding
        layout.itemSize = CGSize(width: width, height: width * 1.5) // 3:2 aspect ratio
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(PinCollectionViewCell.self, forCellWithReuseIdentifier: PinCollectionViewCell.reuseIdentifier)
        return collectionView
    }()
    
    private let refreshControl = UIRefreshControl()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupDelegates()
        loadPins()
    }
    
    // MARK: - Setup
    private func setupViews() {
        title = "My Pins"
        view.backgroundColor = .white
        
        view.addSubview(collectionView)
        collectionView.addSubview(refreshControl)
        view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // Add logout button
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logoutButtonTapped))
    }
    
    private func setupDelegates() {
        collectionView.dataSource = self
        collectionView.delegate = self
        refreshControl.addTarget(self, action: #selector(refreshPins), for: .valueChanged)
    }
    
    // MARK: - Data Loading
    private func loadPins(pagination: String? = nil) {
        guard !isLoading else { return }
        
        isLoading = true
        
        if pagination == nil {
            loadingIndicator.startAnimating()
        }
        
        PinterestAPIManager.shared.fetchAllPins(pagination: pagination) { [weak self] result in
            guard let self = self else { return }
            
            self.isLoading = false
            self.loadingIndicator.stopAnimating()
            self.refreshControl.endRefreshing()
            
            switch result {
            case .success(let pinsResponse):
                // If this is the first page, replace pins; otherwise append
                if pagination == nil {
                    self.pins = pinsResponse.items
                } else {
                    self.pins.append(contentsOf: pinsResponse.items)
                }
                
                self.nextPaginationToken = pinsResponse.bookmark
                self.collectionView.reloadData()
                
                // Show a message if no pins were found
                if self.pins.isEmpty {
                    let emptyLabel = UILabel()
                    emptyLabel.text = "No pins found. Try creating some pins on Pinterest first."
                    emptyLabel.textAlignment = .center
                    emptyLabel.textColor = .gray
                    self.collectionView.backgroundView = emptyLabel
                } else {
                    self.collectionView.backgroundView = nil
                }
                
            case .failure(let error):
                print("Error loading pins: \(error.localizedDescription)")
                
                // Handle error
                let alert = UIAlertController(title: "Error Loading Pins", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
                
                // If token is expired, go back to login
                //                if let error = error as NSError, error.code == 401 {
                //                    self.navigateToLogin()
                //                }
            }
        }
    }
    
    @objc private func refreshPins() {
        pins = []
        nextPaginationToken = nil
        collectionView.reloadData()
        loadPins()
    }
    
    // MARK: - Actions
    @objc private func logoutButtonTapped() {
        PinterestAuthManager.shared.logout()
        navigateToLogin()
    }
    
    private func navigateToLogin() {
        let loginVC = LoginViewController()
        let navController = UINavigationController(rootViewController: loginVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension PinsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pins.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PinCollectionViewCell.reuseIdentifier, for: indexPath) as? PinCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let pin = pins[indexPath.item]
        cell.configure(with: pin)
        
        // Load more pins when approaching the end
        if indexPath.item == pins.count - 5 && !isLoading && nextPaginationToken != nil {
            loadPins(pagination: nextPaginationToken)
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension PinsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Handle pin selection if needed
        let pin = pins[indexPath.item]
        print("Selected pin: \(pin.id)")
    }
}
