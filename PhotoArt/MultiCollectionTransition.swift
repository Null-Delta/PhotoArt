//
//  MultiCollectionTransition.swift
//  PhotoArt
//
//  Created by Rustam Khakhuk on 17.10.2022.
//

import UIKit

class MultiCollectionTransition {
    private var collestions: [UICollectionView]
    private var layouts: [GalleryLayout]

    private var cellIndex: Int
    private var scaleFactors: [CGFloat]!
    private var cellCenters: [CGPoint]!
    private var startOffsetsY: [CGFloat]!

    private var screenSize: CGSize!
    private var screenCenter: CGPoint!

    private var layoutXOffsetInterpolators: [Interpolator]!
    private var layoutYOffsetInterpolators: [Interpolator]!

    private var progress: CGFloat = 0 {
        didSet {
//            fromCollection.alpha = Interpolator.rangeValue(from: 1, to: 0, progress: progress)
//            toCollection.alpha = Interpolator.rangeValue(from: 0, to: 1, progress: progress)
//
//            let fromScale = Interpolator.rangeValue(from: 1, to: cellScaling, progress: progress)
//
//            fromCollection.transform =
//                .init(
//                    translationX: fromLayoutXOffsetInterpolator.value(progress: progress),
//                    y: fromLayoutYOffsetInterpolator.value(progress: progress)
//                )
//                .scaledBy(x: fromScale, y: fromScale)
//            fromCollection.contentOffset.y = fromScreenOffsetY
//
//            let toScale = Interpolator.rangeValue(from: 1 / cellScaling, to: 1, progress: progress)
//
//            toCollection.transform =
//                .init(
//                    translationX: toLayoutXOffsetInterpolator.value(progress: progress),
//                    y: toLayoutYOffsetInterpolator.value(progress: progress)
//                )
//                .scaledBy(x: toScale, y: toScale)
//            toCollection.contentOffset.y = toScreenOffsetY
        }
    }

    init(collections: [UICollectionView], cell: Int) {
        self.collestions = collections
        self.layouts = collections.map { $0.collectionViewLayout as! GalleryLayout }
        self.cellIndex = cell

        self.cellCenters = layouts.map { layout in
            let attribute = layout.layoutAttributesForItem(at: IndexPath(item: cellIndex + layout.itemsOffset, section: 0))!
            return attribute.frame.center - layout.collectionView!.contentOffset
        }

        for i in 1..<collections.count {
            scaleFactors.append(CGFloat(layouts[i].countOfColumns) / CGFloat(layouts[i - 1].countOfColumns))
        }

        screenSize = collections.first!.superview!.bounds.size
        screenCenter = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)

    }

    func startAnimation(from: UICollectionView) {
        guard let currentIndex = collestions.firstIndex(of: from) else { return }

        for collectionIndex in 0..<collestions.count {
            let layout = layouts[collectionIndex]

            if collectionIndex != currentIndex {
                layout.itemsOffset = (layout.countOfColumns / 2 - (cellIndex % layout.countOfColumns))
                if layout.itemsOffset < 0 {
                    layout.itemsOffset = layout.countOfColumns + layout.itemsOffset
                }
            }
            
            cellCenters[collectionIndex] = layout.layoutAttributesForItem(at: IndexPath(item: cellIndex + layout.itemsOffset, section: 0))!.frame.center - (collectionIndex == currentIndex ? .zero : layout.collectionView!.contentOffset)
            
            if collectionIndex != currentIndex {
                collestions[collectionIndex].contentOffset.y += (cellCenters[collectionIndex].y - screenCenter.y)
                collestions[collectionIndex].reloadData()

//                layoutXOffsetInterpolators[collectionIndex] = Interpolator(
//                    from: <#T##CGFloat#>,
//                    to: 0
//                )
//                
//                toLayoutXOffsetInterpolator = Interpolator(
//                    from: fromCellCenter.x - toCellCenter.x,
//                    to: 0
//                )
//
//                toLayoutYOffsetInterpolator = Interpolator(
//                    from: (fromCellCenter.y - screenCenter.y),
//                    to: 0
//                )
            }

            startOffsetsY[collectionIndex] = collestions[collectionIndex].contentOffset.y
        }
    }

    func updateAnimation(progress: CGFloat) {
        self.progress = progress
    }
}
