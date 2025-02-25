//
//  GeneratorViewController.swift
//  QR_Scanner
//
//  Created by Mohammad Noor on 11/11/24.
//

import UIKit

class GeneratorViewController: UIViewController {

    @IBOutlet weak var cardTypeCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCollectionView()
        
    }
    
    var imageSet : [UIImage] = [
        UIImage(named: "Category-Main SMS")!,
        UIImage(named: "Category-Main Url")!,
        UIImage(named: "Category-Main Mail")!,
        UIImage(named: "Category-Main App Store")!,
        UIImage(named: "Category-Main WiFi")!,
        UIImage(named: "Category-Main Text")!,
        UIImage(named: "Category-Main X")!,
        UIImage(named: "Category-Main Facebook")!,
        UIImage(named: "Category-Main More")!
    ]
    
    func setUpCollectionView() {
        let layout = UICollectionViewFlowLayout()
//        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 15
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        cardTypeCollectionView.collectionViewLayout = layout
        cardTypeCollectionView.delegate = self
        cardTypeCollectionView.dataSource = self
        cardTypeCollectionView.register(GeneratorCollectionViewCell.self, forCellWithReuseIdentifier: GeneratorCollectionViewCell.identifier)
        cardTypeCollectionView.register(GeneratorCollectionHeaderCell.self,
                                        forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                         withReuseIdentifier: GeneratorCollectionHeaderCell.self.description())
        //collectionView.register(CustomCollectionViewCell.nib(), forCellWithReuseIdentifier: GeneratorCollectionViewCell.identifier)
    }
}

extension GeneratorViewController: UICollectionViewDelegate {
    
}

extension GeneratorViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GeneratorCollectionViewCell.identifier, for: indexPath) as! GeneratorCollectionViewCell
        cell.imageView.image = imageSet[indexPath.item]
        //cell.imageView.clipsToBounds = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        imageSet.count
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                       withReuseIdentifier: GeneratorCollectionHeaderCell.self.description(),
                                                                       for: indexPath) as! GeneratorCollectionHeaderCell
            switch indexPath.section {
            case 0:
                cell.configure(title: "Card Type")

            default:
                cell.configure(title: "")
            }
            
            cell.backgroundColor = .systemBackground
            
            return cell
        }

        
        return UICollectionReusableView()
    }
}

extension GeneratorViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let v = (UIScreen.main.bounds.width - 40) / 3.0
        return CGSize(width: v, height: v*90/119.0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 50)
    }
}
