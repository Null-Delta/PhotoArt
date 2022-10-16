//
//  CollectionTransitionController.swift
//  PhotoArt
//
//  Created by Rustam Khakhuk on 15.10.2022.
//

import UIKit

class CollectionTransitionController {
    // input params
    private var fromCollection: UICollectionView
    private var toCollection: UICollectionView
    private var fromLayout: GalleryLayout
    private var toLayout: GalleryLayout
    private var cellIndex: Int
    private var cellScaling: CGFloat

    // help params
    private var fromCellCenter: CGPoint!
    private var toCellCenter: CGPoint!

    private var fromOffsetStart: CGFloat!
    private var toOffsetStart: CGFloat!

    private var fromLayoutXOffsetInterpolator: Interpolator
    private var toLayoutXOffsetInterpolator: Interpolator

    private var fromLayoutYOffsetInterpolator: Interpolator
    private var toLayoutYOffsetInterpolator: Interpolator

    var progress: CGFloat = 0 {
        didSet {
            fromCollection.alpha = Interpolator.rangeValue(from: 1, to: 0, progress: progress)
            toCollection.alpha = Interpolator.rangeValue(from: 0, to: 1, progress: progress)

            fromLayout.scale = Interpolator.rangeValue(from: 1, to: cellScaling, progress: progress)
            fromLayout.offset = fromLayoutXOffsetInterpolator.value(progress: progress)
            fromCollection.contentOffset.y = fromLayoutYOffsetInterpolator.value(progress: progress)

            toLayout.scale = Interpolator.rangeValue(from: 1 / cellScaling, to: 1, progress: progress)
            toLayout.offset = toLayoutXOffsetInterpolator.value(progress: progress)
            toCollection.contentOffset.y = toLayoutYOffsetInterpolator.value(progress: progress)
        }
    }

    init(from: UICollectionView, to: UICollectionView, cell: Int, scaling: CGFloat) {
        self.fromCollection = from
        self.toCollection = to

        self.fromLayout = fromCollection.collectionViewLayout as! GalleryLayout
        self.toLayout = toCollection.collectionViewLayout as! GalleryLayout

        self.cellIndex = cell - fromLayout.itemsOffset
        self.cellScaling = scaling

        // replace cell to center of collection's row
        toLayout.itemsOffset = (toLayout.countOfColumns / 2 - (cellIndex % toLayout.countOfColumns))
        if toLayout.itemsOffset < 0 {
            toLayout.itemsOffset = toLayout.countOfColumns + toLayout.itemsOffset
        }

        // set cell scale like in "from" collection
        fromLayout.scale = 1
        toLayout.scale = 1 / cellScaling
        toCollection.contentOffset.y = 0

        let fromCellAttribute = fromLayout.layoutAttributesForItem(at: IndexPath(item: cellIndex + fromLayout.itemsOffset, section: 0))!
        let toCellAttribute = toLayout.layoutAttributesForItem(at: IndexPath(item: cellIndex + toLayout.itemsOffset, section: 0))!

        fromCellCenter = fromCellAttribute.frame.center - fromCollection.contentOffset
        toCellCenter = toCellAttribute.frame.center - toCollection.contentOffset

        print(fromCellCenter.x, fromLayout.offset)
        print(toCellCenter.x, toLayout.offset)

        // change contentOffset to set target cell in "to" and "from" collections in one place
        toCollection.contentOffset.y += (toCellCenter.y - fromCellCenter.y)
        //toLayout.offset = (fromCellCenter.x - toCellCenter.x)

        let fromContentOffset = fromCollection.bounds.width / 2.0 - fromCellCenter.x * scaling

        fromLayoutXOffsetInterpolator = Interpolator(from: 0, to: fromContentOffset)
        toLayoutXOffsetInterpolator = Interpolator(from: toLayout.offset, to: 0)

        fromLayoutYOffsetInterpolator = Interpolator(
            from: fromCollection.contentOffset.y,
            to: -(fromCollection.superview!.bounds.height / 2 - (fromCellCenter.y + fromCollection.contentOffset.y) * scaling)
        )

        toLayoutYOffsetInterpolator = Interpolator(
            from: toCollection.contentOffset.y,
            to: -(toCollection.superview!.bounds.height / 2 - (toCellCenter.y) * scaling)
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
