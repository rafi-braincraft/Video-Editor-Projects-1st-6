

import UIKit


class GeneratorCollectionHeaderCell: UICollectionReusableView {
    
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setTitleLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init (coder:) has not been implemented.")
    }
    
    private func setTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
                titleLabel.font = .boldSystemFont(ofSize: 18)
        titleLabel.textColor = .reverseSystemBackground
                
                addSubview(titleLabel)
                
                NSLayoutConstraint.activate([
                    titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
                    titleLabel.centerYAnchor.constraint(equalTo: bottomAnchor, constant: -15)
                ])
    }
    
    func configure(title: String) {
        titleLabel.text = title
        titleLabel.textColor = .reverseSystemBackground
    }
    
}



