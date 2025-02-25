

import UIKit

protocol TemplateHeaderCollectionViewCellDelegate: AnyObject {
    func didSelectCell(_ cell: TemplateHeaderCollectionViewCell)
}


class TemplateHeaderCollectionViewCell: UICollectionViewCell {
    static let identifier = TemplateHeaderCollectionViewCell.self.description()
    weak var delegate: TemplateHeaderCollectionViewCellDelegate?
    
    //    let underlineView: UIView = {
    //        let view = UIView()
    //        view.backgroundColor = .selectedBlue // Set color for selected state underline
    //        view.isHidden = true // Hidden by default for unselected state
    //        return view
    //    }()
    
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
        //        contentView.addSubview(underlineView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        //        underlineView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            //            underlineView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            //            underlineView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            //            underlineView.widthAnchor.constraint(equalTo: titleLabel.widthAnchor),
            //            underlineView.heightAnchor.constraint(equalToConstant: 2)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(isSelected: Bool) {
        //        titleLabel.text = title
        titleLabel.textColor = isSelected ? .selectedBlue : .gray
        //        underlineView.isHidden = !isSelected
    }
}

