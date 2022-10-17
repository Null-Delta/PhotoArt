//
//  GalleryGrid.swift
//  PhotoArt
//
//  Created by Rustam Khakhuk on 17.10.2022.
//

import UIKit

class GalleryGrid: UIView {
    private var layout1 = GalleryLayout(countOfColumns: 1)
    private var layout3 = GalleryLayout(countOfColumns: 3)
    private var layout5 = GalleryLayout(countOfColumns: 5)
    private var layout7 = GalleryLayout(countOfColumns: 7)
    private var layout9 = GalleryLayout(countOfColumns: 9)

    var delegate: UICollectionViewDelegate?
    var dataSource: UICollectionViewDataSource?

    private var currentCollection: UICollectionView!

    private var allCollections: [UICollectionView] = []

    private var animator: ValueAnimator? = nil
    private var transitionController: CollectionTransitionController?

    lazy private var pinchGesture: UIPinchGestureRecognizer = {
        let gesture = UIPinchGestureRecognizer(target: self, action: #selector(onZoom))
        return gesture
    }()

    private func getNextAfter(collection: UICollectionView) -> UICollectionView {
        var index = allCollections.firstIndex(of: collection)! - 1
        if index < 0 {
            index = allCollections.count - 1
        }

        return allCollections[index]
    }

    private func getNextBefore(collection: UICollectionView) -> UICollectionView {
        let index = allCollections.firstIndex(of: collection)! + 1

        return allCollections[index % allCollections.count]
    }

    private var zoomCellIndex: Int

    private var wasZoomStarted = false

    private var localScale: CGFloat = 1
    private var lastScale: CGFloat = 1
    private var lastVelocity: CGFloat = 0

    private var globalScale: CGFloat {
        return max(1, min(localScale * pinchGesture.scale, 13))
    }
    private var progress: CGFloat {
        if lastVelocity >= 0 {
            switch globalScale {
            case 1...2.6:
                return (globalScale - 1) / 1.6
            case 2.6...(2.6 * 5.0 / 3.0):
                return (globalScale - 2.6) / ((2.6 * 5.0 / 3.0) - 2.6)
            case (2.6 * 5.0 / 3.0)...13:
                return (globalScale - (2.6 * 5.0 / 3.0)) / (13 - (2.6 * 5.0 / 3.0))
            default:
                return 0
            }
        } else {
            switch globalScale {
            case 1..<2.6:
                return (globalScale - 1) / 1.6
            case 2.6..<(2.6 * 5.0 / 3.0):
                return (globalScale - 2.6) / ((2.6 * 5.0 / 3.0) - 2.6)
            case (2.6 * 5.0 / 3.0)...13:
                return (globalScale - (2.6 * 5.0 / 3.0)) / (13 - (2.6 * 5.0 / 3.0))
            default:
                return 0
            }
        }
    }
    private var wasJump: Int {
        let b = CGFloat(2.6 * 5.0 / 3.0)
        if ![2.6, b].filter({ lastScale < $0 && globalScale > $0 }).isEmpty { return 1 }
        if ![2.6, b].filter({ lastScale > $0 && globalScale < $0 }).isEmpty { return -1 }
        return 0
    }

    var isAnimationUpscale: Bool {
        guard let controller = transitionController else { return false }
        return controller.toLayout.countOfColumns < controller.fromLayout.countOfColumns
    }

    func getPerfectScale(for value: CGFloat) -> CGFloat {
        if lastVelocity > 0 {
            switch localScale * value {
            case ..<2.6:
                return 2.6 / localScale
            case 2.6..<(2.6 * 5.0 / 3.0):
                return (2.6 * 5.0 / 3.0) / localScale
            case (2.6 * 5.0 / 3.0)...:
                return 13 / localScale
            default:
                return value
            }
        } else {
            switch localScale * value {
            case ..<2.6:
                return 1 / localScale
            case 2.6..<(2.6 * 5.0 / 3.0):
                return 2.6 / localScale
            case (2.6 * 5.0 / 3.0)...:
                return (2.6 * 5.0 / 3.0) / localScale
            default:
                return value
            }
        }
    }

    private func aaa() {
        if wasJump == -1 {
            transitionController?.progress = 0
            currentCollection = isAnimationUpscale ? transitionController?.fromCollection : transitionController?.toCollection
            zoomCellIndex = currentCollection.indexPathForItem(at: pinchGesture.location(in: currentCollection))!.item

            let nextCollection = getNextBefore(collection: currentCollection)
            transitionController = CollectionTransitionController(from: currentCollection, to: nextCollection, cell: zoomCellIndex)
            transitionController?.progress = progress

        } else if wasJump == 1 {
            transitionController?.progress = 1
            currentCollection = isAnimationUpscale ? transitionController?.toCollection : transitionController?.fromCollection
            zoomCellIndex = currentCollection.indexPathForItem(at: pinchGesture.location(in: currentCollection))!.item

            let nextCollection = getNextAfter(collection: currentCollection)
            transitionController = CollectionTransitionController(from: currentCollection, to: nextCollection, cell: zoomCellIndex)
            transitionController?.progress = progress
        } else {
            transitionController?.progress = min(1, max(0, progress))
        }
        lastScale = globalScale
    }

    @objc private func onZoom() {
        //print(globalScale)
        switch pinchGesture.state {
        case .began:
            guard
                !(pinchGesture.velocity > 0 && allCollections.firstIndex(of: currentCollection) == 0),
                !(pinchGesture.velocity < 0 && allCollections.firstIndex(of: currentCollection) == allCollections.count - 1)
            else {
                return
            }

            zoomCellIndex = currentCollection.indexPathForItem(at: pinchGesture.location(in: currentCollection))!.item
            let nextCollection = pinchGesture.velocity > 0 ? getNextAfter(collection: currentCollection) : getNextBefore(collection: currentCollection)
            transitionController = CollectionTransitionController(from: currentCollection, to: nextCollection, cell: zoomCellIndex)
            transitionController?.progress = pinchGesture.velocity > 0 ? 0 : 1
            wasZoomStarted = true
            lastScale = globalScale

        case .changed:
            guard wasZoomStarted else { return }
            aaa()

        case .ended:
            guard wasZoomStarted else { return }
            wasZoomStarted = false
            pinchGesture.isEnabled = false
            lastVelocity = pinchGesture.velocity

            let d = 0.25
            let lastScale = getPerfectScale(for: pinchGesture.scale + (pinchGesture.velocity * d) / ((1 - d)))
            let deltaScale = lastScale - pinchGesture.scale

            animator = ValueAnimator(duration: 0.75, animation: {[unowned self] progress in
                pinchGesture.scale = lastScale - ((1 - progress) * deltaScale)
                aaa()
            }, curve: { x in
                return 1 - pow(1 - x, 4)
            }, complition: { [unowned self] isComplete in
                print(globalScale)
                self.transitionController!.progress = progress
                currentCollection = self.transitionController!.toCollection
                print((currentCollection.collectionViewLayout as! GalleryLayout).countOfColumns)

                self.transitionController = nil
                animator = nil
                localScale = globalScale
                pinchGesture.scale = 1
                pinchGesture.isEnabled = true
            })

            animator?.start()

        default:
            break
        }
    }

    init(
        delegate: UICollectionViewDelegate? = nil,
        dataSource: UICollectionViewDataSource? = nil
    ) {
        self.delegate = delegate
        self.zoomCellIndex = 0
        self.dataSource = dataSource

        super.init(frame: .zero)

        addGestureRecognizer(pinchGesture)

        let layouts = [
            GalleryLayout(countOfColumns: 1),
            GalleryLayout(countOfColumns: 3),
            GalleryLayout(countOfColumns: 5),
            GalleryLayout(countOfColumns: 13)
        ]

        for i in 0..<layouts.count {
            let collection = UICollectionView(frame: .zero, collectionViewLayout: layouts[i])

            collection.translatesAutoresizingMaskIntoConstraints = false
            collection.register(GalleryCell.self, forCellWithReuseIdentifier: "photo")
            collection.delegate = delegate
            collection.dataSource = dataSource
            collection.clipsToBounds = false

            allCollections.append(collection)
        }

        currentCollection = allCollections.last

        for collection in allCollections {
            addSubview(collection)
            collection.alpha = collection == currentCollection ? 1 : 0

            NSLayoutConstraint.activate([
                collection.leftAnchor.constraint(equalTo: leftAnchor),
                collection.rightAnchor.constraint(equalTo: rightAnchor),
                collection.topAnchor.constraint(equalTo: topAnchor),
                collection.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        }


    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
