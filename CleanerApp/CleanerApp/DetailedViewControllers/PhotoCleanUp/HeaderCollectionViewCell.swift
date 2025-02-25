//
//  HeaderCollectionViewCell.swift
//  CleanerApp
//
//  Created by Mohammad Noor on 15/12/24.
//

import UIKit

protocol HeaderCollectionViewCellDelegate: AnyObject {
    func didSelectCell(_ cell: HeaderCollectionViewCell)
}


class HeaderCollectionViewCell: UICollectionViewCell {
    static let identifier = HeaderCollectionViewCell.self.description()
    weak var delegate: HeaderCollectionViewCellDelegate?
    
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .gray // Default color for unselected tabs
        return label
    }()
    
    override var isSelected: Bool {
        didSet {
            configure( isSelected: isSelected)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(isSelected: Bool) {
        //        titleLabel.text = title
        titleLabel.textColor = isSelected ? .customBlue : .gray
        //        underlineView.isHidden = !isSelected
    }
}

