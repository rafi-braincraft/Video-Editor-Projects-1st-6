//
//  GeneratorCollectionViewCell.swift
//  QR_Scanner
//
//  Created by Mohammad Noor on 11/11/24.
//

import UIKit

class GeneratorCollectionViewCell: UICollectionViewCell {
    var imageView: UIImageView!
    static let identifier = GeneratorCollectionViewCell.self.description()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpImageView()
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
    
}
