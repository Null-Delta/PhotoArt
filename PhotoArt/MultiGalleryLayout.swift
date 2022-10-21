//
//  MultiGalleryLayout.swift
//  PhotoArt
//
//  Created by Rustam Khakhuk on 20.10.2022.
//

import UIKit

class MultiGalleryLayout: GalleryLayout {

    override var collectionViewContentSize: CGSize {
        return CGSize(width: collectionView!.frame.width, height: CGFloat(countOfItems) * cellSize)
    }

    override func prepare() {
        guard needRecalculate else { return }

        cellSize = collectionView!.bounds.width / CGFloat(countOfColumns)

        attributes.removeAll()
        needRecalculate = false
        countOfItems = collectionView!.numberOfItems(inSection: 0) + 1

        for index in 0..<countOfItems {
            let attribure = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: index, section: 0))

            attribure.frame = CGRect(
                x: 0,
                y: CGFloat(index) * cellSize,
                width: collectionView!.frame.width,
                height: cellSize
            )

            attributes.append(attribure)
        }
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleAttributes: [UICollectionViewLayoutAttributes] = []

        let firstItem = max(0, Int(floor(rect.minY / cellSize)))
        let lastItem = min(Int(floor(rect.maxY / cellSize)) + 1, countOfItems - 1)

        for index in firstItem..<lastItem {
            visibleAttributes.append(attributes[index])
        }

        return visibleAttributes
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return attributes[indexPath.item]
    }
}
