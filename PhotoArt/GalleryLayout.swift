//
//  GalleryLayout.swift
//  PhotoArt
//
//  Created by Rustam Khakhuk on 14.10.2022.
//

import UIKit

class GalleryLayout: UICollectionViewLayout {

    private(set) var cellSize: CGFloat = 0

    var itemsOffset: Int = 0

    private var needRecalculate: Bool = true

    private(set) var countOfColumns = 9
    private var countOfItems: Int = 0

    private var attributes: [UICollectionViewLayoutAttributes] = []

    private func binarySearch(rect: CGRect, step: Int? = nil, position: Int = 0) -> Int {
        var left = 0
        var right = attributes.count + countOfColumns - 1

        while(left != right) {
            let index = (left + right) / 2

            if rect.intersects(attributes[index].frame) {
                return index
            } else if attributes[index].frame.minY > rect.maxY {
                right = index - 1
            } else {
                left = index + 1
            }
        }

        return left
    }

    private func isIn(top: CGFloat, bottom: CGFloat, rect: CGRect) -> Bool {
        rect.minY >= top && rect.minY <= bottom ||
        rect.maxY >= top && rect.maxY <= bottom ||
        rect.minY < top && rect.maxY > bottom
    }

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
        countOfItems = collectionView!.numberOfItems(inSection: 0) + countOfColumns

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
        let lastItem = min(Int(floor(rect.maxY / cellSize)) * countOfColumns + countOfColumns, countOfItems - 1)

        for index in firstItem..<lastItem {
            visibleAttributes.append(attributes[index])
        }

        return visibleAttributes
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return attributes[indexPath.item]
    }
}
