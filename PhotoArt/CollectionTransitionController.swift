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
    
    private var cellIndex: Int
    private var cellScaling: CGFloat

    // help params
    private var fromCellCenter: CGPoint!
    private var toCellCenter: CGPoint!
    private var screenSize: CGSize!
    private var screenCenter: CGPoint!

    private var fromOffsetStart: CGFloat!
    private var toOffsetStart: CGFloat!

    private var toScreenOffsetY: CGFloat!
    private var fromScreenOffsetY: CGFloat!

    private var fromLayoutXOffsetInterpolator: Interpolator
    private var toLayoutXOffsetInterpolator: Interpolator

    private var fromLayoutYOffsetInterpolator: Interpolator
    private var toLayoutYOffsetInterpolator: Interpolator

    var progress: CGFloat = 0 {
        didSet {
            fromCollection.alpha = progress < 0.5 ? 1 : 1 - (progress - 0.5) * 2
            toCollection.alpha = Interpolator.rangeValue(from: 0, to: 1, progress: progress)

            let fromScale = Interpolator.rangeValue(from: 1, to: cellScaling, progress: progress)

            fromCollection.transform =
                .init(
                    translationX: fromLayoutXOffsetInterpolator.value(progress: progress),
                    y: fromLayoutYOffsetInterpolator.value(progress: progress)
                )
                .scaledBy(x: fromScale, y: fromScale)
            fromCollection.contentOffset.y = fromScreenOffsetY

            let toScale = Interpolator.rangeValue(from: 1 / cellScaling, to: 1, progress: progress)

            toCollection.transform =
                .init(
                    translationX: toLayoutXOffsetInterpolator.value(progress: progress),
                    y: toLayoutYOffsetInterpolator.value(progress: progress)
                )
                .scaledBy(x: toScale, y: toScale)
            toCollection.contentOffset.y = toScreenOffsetY
        }
    }

    init(from: UICollectionView, to: UICollectionView, cell: Int) {
        self.fromCollection = from
        self.toCollection = to

        self.fromLayout = fromCollection.collectionViewLayout as! GalleryLayout
        self.toLayout = toCollection.collectionViewLayout as! GalleryLayout

        self.cellIndex = cell - fromLayout.itemsOffset
        self.cellScaling = CGFloat(fromLayout.countOfColumns) / CGFloat(toLayout.countOfColumns)

        print(fromLayout.countOfColumns)
        print(toLayout.countOfColumns)
        print(cellScaling)

        // replace cell to center of collection's row
        toLayout.itemsOffset = (toLayout.countOfColumns / 2 - (cellIndex % toLayout.countOfColumns))
        if toLayout.itemsOffset < 0 {
            toLayout.itemsOffset = toLayout.countOfColumns + toLayout.itemsOffset
        }

        // set cell size like in "from" collection
        let fromCellAttribute = fromLayout.layoutAttributesForItem(at: IndexPath(item: cellIndex + fromLayout.itemsOffset, section: 0))!
        let toCellAttribute = toLayout.layoutAttributesForItem(at: IndexPath(item: cellIndex + toLayout.itemsOffset, section: 0))!

        screenSize = fromCollection.superview!.bounds.size
        screenCenter = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)

        fromCellCenter = fromCellAttribute.center - fromCollection.contentOffset
        toCellCenter = toCellAttribute.center - toCollection.contentOffset

        toCollection.contentOffset.y += (toCellCenter.y - screenCenter.y)
        toCollection.reloadData()

        toScreenOffsetY = toCollection.contentOffset.y
        fromScreenOffsetY = fromCollection.contentOffset.y

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
