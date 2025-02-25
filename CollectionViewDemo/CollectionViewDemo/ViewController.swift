//
//  ViewController.swift
//  CollectionViewDemo
//
//  Created by Mohammad Noor on 28/10/24.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    let vehicles = ["Honda", "Toyota", "Maroti", "BMW", "TATA", "Lamborgini", "Mahindra", "Tesla", "Xiaomi", "Jeep Rubilion", "Royal Enfield", "Marcedeez"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTheCollectionView()
    }
    
    func setTheCollectionView() {
//        
//        let layout = UICollectionViewFlowLayout()
//        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
//        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
//        layout.minimumInteritemSpacing = 10
//        layout.minimumLineSpacing = 15
//        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
//
//        
//        collectionView.collectionViewLayout = layout
        collectionView.delegate = self
        collectionView.dataSource = self
//        collectionView.register(CustomCollectionViewCell.nib(), forCellWithReuseIdentifier: CustomCollectionViewCell.idetifier)
        
    }


}
extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        print("tapped \(indexPath)")
    }
}

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        vehicles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomCollectionViewCell.idetifier, for: indexPath) as! CustomCollectionViewCell
        
        cell.configure(with: vehicles[indexPath.row])
        
        return cell
    }
}


extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Determine the width based on the text length
        let text = vehicles[indexPath.row]
        let width = text.size(withAttributes: [.font: UIFont.systemFont(ofSize: 17)]).width + 2// Add padding
        return CGSize(width: width, height: 50) // Fixed height
    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 10
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 10
//    }
}
class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)

        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        attributes?.forEach { layoutAttribute in
            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left
            }

            layoutAttribute.frame.origin.x = leftMargin

            leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
            maxY = max(layoutAttribute.frame.maxY , maxY)
        }

        return attributes
    }
}
