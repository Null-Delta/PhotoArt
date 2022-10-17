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

    private var currentZoom: CGFloat = 1
    private var animatedCollection: UICollectionView?
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
    private var pinchOffset: CGFloat = 0

    private var isUnscale = false
    private var wasZoomStarted = false

    private func aaa() {
        guard
            !(!isUnscale && signScale > 1 && allCollections.firstIndex(of: currentCollection)! == 1),
            !(isUnscale && signScale > 0 && allCollections.firstIndex(of: currentCollection)! == 0),
            !(isUnscale && signScale < -1 && allCollections.firstIndex(of: currentCollection)! == allCollections.count - 2),
            !(!isUnscale && signScale < 0 && allCollections.firstIndex(of: currentCollection)! == allCollections.count - 1),
            !(normalizedScale < 0 && allCollections.firstIndex(of: transitionController!.toCollection)! == 3)
        else {
            return
        }
        
        if !isUnscale {
            if signScale > 1 {
                isUnscale = false
                transitionController?.progress = 1
                pinchOffset += 1

                currentCollection = transitionController!.toCollection
                zoomCellIndex = currentCollection.indexPathForItem(at: pinchGesture.location(in: currentCollection))!.item
                let nextCollection = getNextAfter(collection: currentCollection)

                self.transitionController = nil

                transitionController = CollectionTransitionController(from: currentCollection, to: nextCollection, cell: zoomCellIndex)
                transitionController?.progress = unsignScale
            } else if signScale < 0 {
                isUnscale = true
                transitionController?.progress = 0
                pinchOffset -= 1

                currentCollection = transitionController!.fromCollection

                zoomCellIndex = currentCollection.indexPathForItem(at: pinchGesture.location(in: currentCollection))!.item
                let nextCollection = getNextBefore(collection: currentCollection)

                self.transitionController = nil

                transitionController = CollectionTransitionController(from: currentCollection, to: nextCollection, cell: zoomCellIndex)
                transitionController?.progress = unsignScale
            } else {
                transitionController?.progress = min(1, max(0, unsignScale))
            }
        } else if isUnscale {
            if signScale > 0 {
                isUnscale = false
                transitionController?.progress = 0
                pinchOffset += 1

                currentCollection = transitionController!.fromCollection
                zoomCellIndex = currentCollection.indexPathForItem(at: pinchGesture.location(in: currentCollection))!.item
                let nextCollection = getNextAfter(collection: currentCollection)

                self.transitionController = nil

                transitionController = CollectionTransitionController(from: currentCollection, to: nextCollection, cell: zoomCellIndex)
                transitionController?.progress = unsignScale
            } else if signScale < -1 {
                isUnscale = true
                transitionController?.progress = 1
                pinchOffset -= 0.5

                currentCollection = transitionController!.toCollection

                zoomCellIndex = currentCollection.indexPathForItem(at: pinchGesture.location(in: currentCollection))!.item
                let nextCollection = getNextBefore(collection: currentCollection)

                self.transitionController = nil

                transitionController = CollectionTransitionController(from: currentCollection, to: nextCollection, cell: zoomCellIndex)
                transitionController?.progress = unsignScale
            } else {
                transitionController?.progress = min(1, max(0, unsignScale))
            }
        }
    }

    var normalizedScale: CGFloat {
        return pinchGesture.scale - 1 - pinchOffset
    }

    var unsignScale: CGFloat {
        if !isUnscale {
            return normalizedScale
        } else {
            return 1 / normalizedScale - 1
        }
    }

    var signScale: CGFloat {
        if !isUnscale {
            return unsignScale
        } else {
            return -unsignScale
        }
    }

    var normalizedPinch: CGFloat {
        if pinchGesture.scale > 1 {
            return pinchGesture.scale
        } else {
            return 1 / pinchGesture.scale
        }
    }

    @objc private func onZoom() {
        print(pinchGesture.scale)

        switch pinchGesture.state {
        case .began:
            pinchOffset = 0

            guard
                !(normalizedScale > 0 && allCollections.firstIndex(of: currentCollection)! == 0),
                !(normalizedScale < 0 && allCollections.firstIndex(of: currentCollection)! == allCollections.count - 1)
            else {
                return
            }

            zoomCellIndex = currentCollection.indexPathForItem(at: pinchGesture.location(in: currentCollection))!.item
            let nextCollection: UICollectionView
            if normalizedScale > 0 {
                isUnscale = false
                nextCollection = getNextAfter(collection: currentCollection)
                transitionController = CollectionTransitionController(from: currentCollection, to: nextCollection, cell: zoomCellIndex)
                transitionController?.progress = unsignScale
            } else {
                pinchOffset -= 1
                isUnscale = true
                nextCollection = getNextBefore(collection: currentCollection)
                transitionController = CollectionTransitionController(from: currentCollection, to: nextCollection, cell: zoomCellIndex)
                transitionController?.progress = unsignScale
            }
            wasZoomStarted = true


        case .changed:
            guard wasZoomStarted else { return }
            aaa()

        case .ended:
            guard wasZoomStarted else { return }
            pinchGesture.isEnabled = false
            wasZoomStarted = false

//            let velocity = isUnscale ? 0.0 : 0.0
//            let d = 0.25

//            let lastScale = isUnscale ?
//            floor(pinchGesture.scale + (velocity * d) / ((1 - d))) :
//            ceil(pinchGesture.scale + (velocity * d) / ((1 - d)))
//
//            let deltaScale = lastScale - pinchGesture.scale
            let deltaProgress = 1 - self.transitionController!.progress

            animator = ValueAnimator(duration: 0.5, animation: {[unowned self] progress in
                //pinchGesture.scale = lastScale - ((1 - progress) * deltaScale)
                self.transitionController?.progress = 1 - deltaProgress * (1 - progress)
                //aaa()
            }, curve: { x in
                return 1  - (1 - x) * (1 - x)
            }, complition: { [unowned self] isComplete in
                pinchGesture.isEnabled = true

                currentCollection = self.transitionController!.toCollection
                self.transitionController = nil
                animator = nil
                pinchGesture.scale = 1
                pinchOffset = 0
            })

            animator?.start()

        default:
            break
        }
    }

    
    init(delegate: UICollectionViewDelegate? = nil, dataSource: UICollectionViewDataSource? = nil) {
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

        currentCollection = allCollections.last!

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
