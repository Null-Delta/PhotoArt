//
//  GalleryLayout.swift
//  PhotoArt
//
//  Created by Rustam Khakhuk on 14.10.2022.
//

import UIKit

class GalleryLayout: UICollectionViewLayout {

    var cellSize: CGFloat = 0

    var itemsOffset: Int = 0

    var needRecalculate: Bool = true

    var countOfColumns = 9
    var countOfItems: Int = 0

    var attributes: [UICollectionViewLayoutAttributes] = []

    override var collectionViewContentSize: CGSize {
        return CGSize(width: collectionView!.frame.width, height: ceil(CGFloat(countOfItems + countOfColumns) / CGFloat(countOfColumns)) * cellSize)
    }

    init(countOfColumns: Int) {
        self.countOfColumns = countOfColumns
        super.init()
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
                x: CGFloat((index % Int(countOfColumns))) * cellSize,
                y: floor(CGFloat(index) / CGFloat(countOfColumns)) * cellSize,
                width: cellSize,
                height: cellSize
            )

            attributes.append(attribure)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleAttributes: [UICollectionViewLayoutAttributes] = []

        let firstItem = max(0, Int(floor(rect.minY / cellSize)) * countOfColumns)
        let lastItem = max(0, min(Int(floor(rect.maxY / cellSize)) * countOfColumns + countOfColumns, countOfItems - 1))

        for index in firstItem..<lastItem {
            visibleAttributes.append(attributes[index])
        }

        return visibleAttributes
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return attributes[indexPath.item]
    }
}
