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

    private var zoomCellIndex: Int
    private var pinchOffset: CGFloat = 0

    private var zoomScale: CGFloat {
        get {
            switch (currentCollection.collectionViewLayout as! GalleryLayout).countOfColumns {
            case 13:
                return 13.0 / 5.0
            case 5:
                return 5.0 / 3.0
            case 3:
                return 3
            default:
                return 1
            }
        }
    }

    private var scaledZoom: CGFloat {
        return (pinchGesture.scale * zoomScale - 1 - pinchOffset)
    }
    @objc private func onZoom() {
        switch pinchGesture.state {
        case .began:
            zoomCellIndex = currentCollection.indexPathForItem(at: pinchGesture.location(in: currentCollection))!.item
            let nextCollection = getNextAfter(collection: currentCollection)
            transitionController = CollectionTransitionController(from: currentCollection, to: nextCollection, cell: zoomCellIndex)
            transitionController?.progress = 0

        case .changed:
            print(pinchGesture.scale - 1 - pinchOffset)
            if (pinchGesture.scale - 1 - pinchOffset > 1) {
                transitionController?.progress = 1
                pinchOffset += 1

                currentCollection = transitionController!.toCollection
                zoomCellIndex = currentCollection.indexPathForItem(at: pinchGesture.location(in: currentCollection))!.item
                let nextCollection = getNextAfter(collection: currentCollection)

                self.transitionController = nil

                transitionController = CollectionTransitionController(from: currentCollection, to: nextCollection, cell: zoomCellIndex)
                transitionController?.progress = pinchGesture.scale - 1 - pinchOffset
            } else {
                transitionController?.progress = min(1, max(0, pinchGesture.scale - 1 - pinchOffset))
            }

        case .ended:
            pinchGesture.isEnabled = false
            pinchOffset = 0

            let d = 0.25
            var lastScale = ceil(pinchGesture.scale + (pinchGesture.velocity * d) / ((1 - d)))
            if (lastScale - pinchGesture.scale) > 3 {
                lastScale -= lastScale - floor(lastScale - pinchGesture.scale)
            }
            let deltaScale = lastScale - pinchGesture.scale

            animator = ValueAnimator(duration: 1, animation: {[unowned self] progress in
                pinchGesture.scale = lastScale - ((1 - progress) * deltaScale)
                print(pinchGesture.scale - 1 - pinchOffset)

                if (pinchGesture.scale - 1 - pinchOffset > 1) {
                    self.transitionController!.progress = 1
                    pinchOffset += 1

                    currentCollection = self.transitionController!.toCollection

                    zoomCellIndex = currentCollection.indexPathForItem(at: pinchGesture.location(in: currentCollection))!.item
                    let nextCollection = getNextAfter(collection: currentCollection)

                    self.transitionController = nil

                    self.transitionController = CollectionTransitionController(from: currentCollection, to: nextCollection, cell: zoomCellIndex)
                    self.transitionController?.progress = pinchGesture.scale - 1 - pinchOffset
                } else {
                    self.transitionController?.progress = min(1, max(0, pinchGesture.scale - 1 - pinchOffset))
                }
            }, curve: { x in
                return 1 - pow(1 - x, 3)
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
