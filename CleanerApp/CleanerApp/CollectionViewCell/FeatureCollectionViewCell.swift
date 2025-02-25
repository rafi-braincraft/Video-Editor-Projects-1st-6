//
//  FeatureCollectionViewCell.swift
//  CleanerApp
//
//  Created by Mohammad Noor on 8/12/24.
//

import UIKit

class FeatureCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "FeatureCollectionViewCell"

    @IBOutlet weak var backgroundImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpViews()
        // Initialization code
    }
    
    func setUpViews() {
        backgroundImage.contentMode = .scaleToFill
    }

}
