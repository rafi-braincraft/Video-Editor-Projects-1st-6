//
//  TenorSuggestionCell.swift
//  GifMakerSwift
//
//  Created by Mohammad Noor on 6/2/25.
//

import UIKit

class TenorSuggestionCell: UICollectionViewCell {
    static let identifer = "TenorSuggestionCell"
    
    @IBOutlet weak var backgroundLayerView: UIView!
    @IBOutlet weak var tenorSuggestionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpBackgroundLabel()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //setUpBackgroundLabel()
    }
    
    override var isSelected: Bool {
        didSet {
            setBackgroundColor(isSelected: isSelected)
        }
    }
    
    func setBackgroundColor(isSelected: Bool) {
        if isSelected {
            backgroundLayerView.layer.borderColor = UIColor(named: "colSelectedIconYello")!.cgColor
            tenorSuggestionLabel.textColor = UIColor(named: "colSelectedIconYello")!
        } else {
            backgroundLayerView.layer.borderColor = UIColor(named: "tenorBorderNotSelected")!.cgColor
            tenorSuggestionLabel.textColor = UIColor(named: "tenorSuggestionLabel")!
        }
    }
    
    func setUpBackgroundLabel() {
        backgroundLayerView.layer.cornerRadius = 8
        backgroundLayerView.layer.borderWidth = 0.5
        backgroundLayerView.clipsToBounds = true
        setBackgroundColor(isSelected: false)
    }

}
