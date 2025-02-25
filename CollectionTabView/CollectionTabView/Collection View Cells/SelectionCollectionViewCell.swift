//
//  SelectionCollectionViewCell.swift
//  CollectionTabView
//
//  Created by Mohammad Noor on 16/1/25.
//

import UIKit

class SelectionCollectionViewCell: UICollectionViewCell {
    let selectedColor = UIColor(named: "colSelectedIconYello")!
    let unselectedColor = UIColor(named: "colUnelectedIconGray")!
    
    static let identifier = "SelectionCollectionViewCell"
    
    @IBOutlet weak var imageLabel: UILabel!
    
    @IBOutlet weak var imageIcon: UIImageView!
    
    override var isSelected: Bool {
        didSet {
            updateSelectedTint()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpViews()
    }
    
    func setUpViews() {
        imageIcon.contentMode = .scaleToFill
    }
    
    func configure(_ imageLabelText: String, image: UIImage) {
        imageLabel.text = imageLabelText
        imageIcon.image = image
        restoreDefaultTint()
    }
    
    func restoreDefaultTint() {
        imageLabel.textColor = unselectedColor // Selected color
        imageIcon.tintColor = unselectedColor
    }
    
    func updateSelectedTint() {
        if isSelected {
            imageLabel.textColor = selectedColor// Selected color
            imageIcon.tintColor = selectedColor // Selected color
        } else {
            restoreDefaultTint()
        }
    }
    
}
