//
//  DetailsCollectionViewCell.swift
//  CleanerApp
//
//  Created by Mohammad Noor on 15/12/24.
//

import UIKit

class DetailsCollectionViewCell: UICollectionViewCell {
    var imageView: UIImageView!
    var loader: UIActivityIndicatorView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpImageView()
        setUpLoader()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init (coder:) has not been implemented.")
    }
    
    func setUpImageView() {
        imageView = UIImageView(frame: self.contentView.bounds)
        
        imageView.contentMode = .scaleToFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func setUpLoader() {
        loader = UIActivityIndicatorView(style: .medium)
        loader.translatesAutoresizingMaskIntoConstraints = false
        loader.hidesWhenStopped = true
        contentView.addSubview(loader)
        
        NSLayoutConstraint.activate([
            loader.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            loader.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    
    func configure(with imageUrl: String?) {
        loader.startAnimating()
        // Set a placeholder image while loading
        self.imageView.image = UIImage(named: "placeholder") // Make sure a placeholder image is added to your assets
        //loader.startAnimating()
        
        guard let imageUrl = imageUrl, let url = URL(string: imageUrl) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Failed to load image: \(error.localizedDescription)")
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                print("Failed to convert data to UIImage.")
                return
            }
            
            // Update the image on the main thread
            DispatchQueue.main.async {
                self.imageView.image = image
                self.loader.stopAnimating()
            }
        }.resume()
    }
    
    
}


