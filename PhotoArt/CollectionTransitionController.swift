//
//  CollectionTransitionController.swift
//  PhotoArt
//
//  Created by Rustam Khakhuk on 15.10.2022.
//

import UIKit

class CollectionTransitionController {
    // input params
    private(set) var fromCollection: UICollectionView
    private(set) var toCollection: UICollectionView
    private(set) var fromLayout: GalleryLayout
    private(set) var toLayout: GalleryLayout
    
    private var cellScaling: CGFloat

    private var fromLayoutXOffsetInterpolator: Interpolator
    private var toLayoutXOffsetInterpolator: Interpolator

    private var fromLayoutYOffsetInterpolator: Interpolator
    private var toLayoutYOffsetInterpolator: Interpolator

    var progress: CGFloat = 0 {
        didSet {
            let normalizedProgress = toLayout.countOfColumns < fromLayout.countOfColumns ? progress : 1 - progress

            fromCollection.alpha = normalizedProgress < 0.5 ? 1 : 1 - (normalizedProgress - 0.5) * 2
            toCollection.alpha = normalizedProgress

            let fromScale = Interpolator.rangeValue(from: 1, to: cellScaling, progress: normalizedProgress)

            fromCollection.transform =
                .init(
                    translationX: fromLayoutXOffsetInterpolator.value(progress: normalizedProgress),
                    y: fromLayoutYOffsetInterpolator.value(progress: normalizedProgress)
                )
                .scaledBy(x: fromScale, y: fromScale)

            let toScale = Interpolator.rangeValue(from: 1 / cellScaling, to: 1, progress: normalizedProgress)

            toCollection.transform =
                .init(
                    translationX: toLayoutXOffsetInterpolator.value(progress: normalizedProgress),
                    y: toLayoutYOffsetInterpolator.value(progress: normalizedProgress)
                )
                .scaledBy(x: toScale, y: toScale)
        }
    }

    init(from: UICollectionView, to: UICollectionView, cell: Int) {
        self.fromCollection = from
        self.toCollection = to

        self.fromLayout = fromCollection.collectionViewLayout as! GalleryLayout
        self.toLayout = toCollection.collectionViewLayout as! GalleryLayout

        self.cellScaling = CGFloat(fromLayout.countOfColumns) / CGFloat(toLayout.countOfColumns)

        let cellIndex = cell - fromLayout.itemsOffset
        // replace cell to center of collection's row
        toLayout.itemsOffset = (toLayout.countOfColumns / 2 - (cellIndex % toLayout.countOfColumns))
        if toLayout.itemsOffset < 0 {
            toLayout.itemsOffset = toLayout.countOfColumns + toLayout.itemsOffset
        }

        toCollection.reloadData()

        // set cell size like in "from" collection
        let fromCellAttribute = fromLayout.layoutAttributesForItem(at: IndexPath(item: cellIndex + fromLayout.itemsOffset, section: 0))!
        let toCellAttribute = toLayout.layoutAttributesForItem(at: IndexPath(item: cellIndex + toLayout.itemsOffset, section: 0))!

        let screenSize = fromCollection.superview!.bounds.size
        let screenCenter = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)

        let fromCellCenter = fromCellAttribute.center - fromCollection.contentOffset
        let toCellCenter = toCellAttribute.center - toCollection.contentOffset

        toCollection.contentOffset.y += (toCellCenter.y - screenCenter.y)

        fromLayoutXOffsetInterpolator = Interpolator(
            from: 0,
            to: (screenCenter.x - fromCellCenter.x) * cellScaling
        )

        fromLayoutYOffsetInterpolator = Interpolator(
            from: 0,
            to: (screenCenter.y - fromCellCenter.y) * cellScaling
        )

        toLayoutXOffsetInterpolator = Interpolator(
            from: fromCellCenter.x - toCellCenter.x,
            to: 0
        )

        toLayoutYOffsetInterpolator = Interpolator(
            from: (fromCellCenter.y - screenCenter.y),
            to: 0
        )
    }
}

class Interpolator {
    var from: CGFloat
    var to: CGFloat

    init(from: CGFloat, to: CGFloat) {
        self.from = from
        self.to = to
    }

    static func rangeValue(from: CGFloat, to: CGFloat, progress: CGFloat) -> CGFloat {
        return from + (to - from) * progress
    }

    func value(progress: CGFloat) -> CGFloat {
        return from + (to - from) * progress
    }
}
