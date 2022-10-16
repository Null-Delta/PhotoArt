//
//  GalleryLayout.swift
//  PhotoArt
//
//  Created by Rustam Khakhuk on 14.10.2022.
//

import UIKit

class GalleryLayout: UICollectionViewLayout {

    var cellSize: CGFloat = 32 {
        didSet {
            invalidateLayout()
        }
    }

    var offset: CGFloat = 0.0 {
        didSet {
            invalidateLayout()
        }
    }

    var itemsOffset: Int = 0 {
        didSet {
            needRecalculate = true
            invalidateLayout()
        }
    }

    private var needRecalculate: Bool = true

    private(set) var countOfColumns = 9
    private var countOfItems: Int = 0

    private var attributes: [UICollectionViewLayoutAttributes] = []

    private func binarySearch(rect: CGRect, step: Int? = nil, position: Int = 0) -> Int {
        var left = 0
        var right = attributes.count + itemsOffset - 1

        while(left != right) {
            let index = (left + right) / 2
            let attrRect = fullFrame(at: index)

            if rect.intersects(attrRect) {
                return index
            } else if attrRect.minY > rect.maxY {
                right = index - 1
            } else {
                left = index + 1
            }
        }

        return left
    }

    private func fullFrame(at: Int) -> CGRect {
        return CGRect(
            origin: attributes[at].frame.origin * cellSize + CGPoint(x: offset, y: 0),
            size: attributes[at].size * cellSize
        )
    }

    private func isIn(top: CGFloat, bottom: CGFloat, rect: CGRect) -> Bool {
        rect.minY >= top && rect.minY <= bottom ||
        rect.maxY >= top && rect.maxY <= bottom ||
        rect.minY < top && rect.maxY > bottom
    }

    override var collectionViewContentSize: CGSize {
        return CGSize(width: collectionView!.frame.width, height: ceil(CGFloat(countOfItems + itemsOffset) / CGFloat(countOfColumns)) * cellSize)
    }

    init(countOfColumns: Int) {
        self.countOfColumns = countOfColumns
        super.init()
    }

    override func prepare() {
        guard needRecalculate else { return }

        attributes.removeAll()
        needRecalculate = false
        countOfItems = collectionView!.numberOfItems(inSection: 0) + itemsOffset

        for index in 0..<countOfItems {
            let attribure = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: index, section: 0))

            attribure.frame = CGRect(
                x: CGFloat((index % Int(countOfColumns))),
                y: floor(CGFloat(index) / CGFloat(countOfColumns)),
                width: 1,
                height: 1
            )

            attributes.append(attribure)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
//        return attributes.filter { attr in
//            rect.intersects(CGRect(origin: attr.frame.origin * cellSize + CGPoint(x: offset, y: 0), size: attr.frame.size * cellSize))
//        }.map { attr in
//            let attr2 = UICollectionViewLayoutAttributes(forCellWith: attr.indexPath)
//            attr2.frame = CGRect(origin: attr.frame.origin * cellSize + CGPoint(x: offset, y: 0), size: attr.frame.size * cellSize)
//            return attr2
//        }

        var visibleAttributes: [UICollectionViewLayoutAttributes] = []

        let firstItem = binarySearch(rect: rect)

        for index in firstItem..<attributes.count {
            let frame = fullFrame(at: index)

            if isIn(top: rect.minY, bottom: rect.maxY, rect: frame) {
                let attr = UICollectionViewLayoutAttributes(forCellWith: attributes[index].indexPath)
                attr.frame = frame

                visibleAttributes.append(attr)
            } else {
                break
            }
        }

        for index in (0..<firstItem).reversed() {
            let frame = fullFrame(at: index)

            if isIn(top: rect.minY, bottom: rect.maxY, rect: frame) {
                let attr = UICollectionViewLayoutAttributes(forCellWith: attributes[index].indexPath)
                attr.frame = frame

                visibleAttributes.append(attr)
            } else {
                break
            }
        }

        return visibleAttributes
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return attributes[indexPath.item]
    }
}
