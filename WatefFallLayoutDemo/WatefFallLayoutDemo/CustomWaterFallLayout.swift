//
//  CustomWaterFallLayout.swift
//  WatefFallLayoutDemo
//
//  Created by Mohammad Noor on 30/10/24.
//

import UIKit

//1. ---- Define the Delegate Protocol in delegator
protocol CustomWaterFallLayoutDelegate: AnyObject {
    //this func provides the size of the photo
    func collectionView(_ collectionView: UICollectionView, sizeOfPhotoAtIndexPath indexPath: IndexPath ) -> CGSize
    
}

class CustomWaterFallLayout: UICollectionViewLayout {
    //3. -----  take a weak var where will get the data
    weak var delegate: CustomWaterFallLayoutDelegate!
    
    var numOfColumns = 2
    var cellPadding: CGFloat = 3
    
    fileprivate var cache = [UICollectionViewLayoutAttributes]() //collection attributes array
    
    fileprivate var contentHeight: CGFloat = 0
    fileprivate var contentWidth: CGFloat { //collectionView width
        guard let collectionView = collectionView else {
            return 0
        }
        return collectionView.bounds.width
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    //calculate the position of collection view cells
    override func prepare() {
        guard cache.isEmpty, let collectionView = collectionView else {
            return
        }
        
        let columnWidth = contentWidth / CGFloat(numOfColumns)
        var xOffset = [CGFloat]()
        
        for column in 0..<numOfColumns {
            xOffset.append(CGFloat(column) * columnWidth) //x val of from where the column will begin
        }
        
        var column = 0
        var yOffset = [CGFloat](repeating: 0, count: numOfColumns)
        
        for item in 0..<collectionView.numberOfItems(inSection: 0) {
            
            let indexPath = IndexPath(item: item, section: 0)
            //4. ----- get the gata by calling the function
            let photoSize = delegate.collectionView(collectionView, sizeOfPhotoAtIndexPath: indexPath)
            
            let cellWidth = columnWidth
            var cellHeight = photoSize.height * cellWidth / photoSize.width
            cellHeight = cellPadding * 2 + cellHeight
            
            let frame = CGRect(x: xOffset[column], y: yOffset[column], width: cellWidth, height: cellHeight)
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)
            
            contentHeight = max(contentHeight, frame.maxY)
            yOffset[column] += cellHeight
            
//            if numOfColumns > 1 {
//                
//                column = (column+1)%numOfColumns
//            }
            
            var targetColumn = 0
            var minYOffset = yOffset[0]
            for col in 1..<numOfColumns {
                if yOffset[col] < minYOffset {
                    minYOffset = yOffset[col]
                    targetColumn = col
                }
            }
            column = targetColumn
            
            
            
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
        
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        
        return visibleLayoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func invalidateLayout() {
        super.invalidateLayout()
        cache.removeAll()
    }
    
    
}
