//
//  CustomCollectionViewCell.swift
//  CollectionViewDemo
//
//  Created by Mohammad Noor on 28/10/24.
//

import UIKit

class CustomCollectionViewCell: UICollectionViewCell {

    
    @IBOutlet weak var textLabel: UILabel!
    
    static let idetifier = "CustomCollectionViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textLabel.numberOfLines = 0
    }
    
    public func configure(with label: String ) {
        textLabel.text = label
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "CustomCollectionViewCell", bundle: nil)
    }

}
