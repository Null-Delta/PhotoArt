//
//  GalleryController.swift
//  PhotoArt
//
//  Created by Rustam Khakhuk on 13.10.2022.
//

import UIKit
import Photos

class GalleryController: UIViewController {

    private var heroTransition: HeroTransitioningDelegate?
    private var accessTransitionDelegate = AccessTransitioningDelegate()

    private var assets: PHFetchResult<PHAsset>!

    lazy private var collection9: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout9)
        collection.translatesAutoresizingMaskIntoConstraints = false

        collection.register(GalleryCell.self, forCellWithReuseIdentifier: "photo")

        collection.delegate = self
        collection.dataSource = self

        return collection
    }()

    lazy private var collection5: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout5)
        collection.translatesAutoresizingMaskIntoConstraints = false

        collection.register(GalleryCell.self, forCellWithReuseIdentifier: "photo2")

        collection.delegate = self
        collection.dataSource = self

        return collection
    }()

    lazy private var pinchGesture: UIPinchGestureRecognizer = {
        let gesture = UIPinchGestureRecognizer(target: self, action: #selector(onZoom))

        return gesture
    }()

    private var layout3 = GalleryLayout(countOfColumns: 3)
    private var layout5 = GalleryLayout(countOfColumns: 3)
    private var layout9 = GalleryLayout(countOfColumns: 5)

    private var transitionProgress = 0.0

    lazy private var blurView: UIView = {
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        blur.translatesAutoresizingMaskIntoConstraints = false
        blur.clearBlur()

        return blur
    }()

    lazy private var backgroundMask: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        gradient.colors = [
            UIColor.black.withAlphaComponent(1).cgColor,
            UIColor.black.withAlphaComponent(1).cgColor,
            UIColor.black.withAlphaComponent(0).cgColor,
        ]
        gradient.type = .axial

        return gradient
    }()

    private var transition: CollectionTransitionController!

    private var current = 9

    @objc private func onZoom() {

        switch pinchGesture.state {
        case .began:
            let cellIndex: IndexPath
            if current == 9 {
                cellIndex = collection9.indexPathForItem(at: pinchGesture.location(in: collection9))!
                collection5.isHidden = false
                collection5.alpha = 0

            } else {
                cellIndex = collection5.indexPathForItem(at: pinchGesture.location(in: collection5))!
                collection9.isHidden = false
                collection9.alpha = 0
            }

            if current == 9 {
                transition = CollectionTransitionController(from: collection9, to: collection5, cell: cellIndex.item, scaling: 1.6666)
                current = 5
            } else {
                transition = CollectionTransitionController(from: collection5, to: collection9, cell: cellIndex.item, scaling: 0.6)

                current = 9
            }

        case .changed:
            transition.progress = min(1, max(0, pinchGesture.scale - 1))

            break
        case .ended:
            transition.progress = 1
            if current == 5 {
                collection9.removeGestureRecognizer(pinchGesture)
                collection5.addGestureRecognizer(pinchGesture)
            } else {
                collection5.removeGestureRecognizer(pinchGesture)
                collection9.addGestureRecognizer(pinchGesture)

            }

            break
        default:
            break
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundMask.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.safeAreaInsets.top)
        blurView.layer.mask = backgroundMask
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let accessController = AccessController()
        accessController.modalPresentationStyle = .overFullScreen
        accessController.transitioningDelegate = accessTransitionDelegate

        present(accessController, animated: false)
    }

    override func viewDidLoad() {
        view.addSubview(collection9)
        view.addSubview(collection5)
        view.addSubview(blurView)

        collection9.addGestureRecognizer(pinchGesture)

        collection5.isHidden = true

        NSLayoutConstraint.activate([
            collection9.leftAnchor.constraint(equalTo: view.leftAnchor),
            collection9.rightAnchor.constraint(equalTo: view.rightAnchor),
            collection9.topAnchor.constraint(equalTo: view.topAnchor),
            collection9.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            collection5.leftAnchor.constraint(equalTo: view.leftAnchor),
            collection5.rightAnchor.constraint(equalTo: view.rightAnchor),
            collection5.topAnchor.constraint(equalTo: view.topAnchor),
            collection5.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            blurView.topAnchor.constraint(equalTo: view.topAnchor),
            blurView.leftAnchor.constraint(equalTo: view.leftAnchor),
            blurView.rightAnchor.constraint(equalTo: view.rightAnchor),
            blurView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        ])

        loadPhotos()
    }

    private func loadPhotos() {
        let photos = PHPhotoLibrary.authorizationStatus()
        if photos == .notDetermined {
            PHPhotoLibrary.requestAuthorization({status in })
        }

        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

        self.assets = PHAsset.fetchAssets(with: .image, options: options)

    }
}

extension GalleryController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard
            let layout = collectionView.collectionViewLayout as? GalleryLayout,
            let cell = collectionView.cellForItem(at: indexPath) as? GalleryCell,
            indexPath.item - layout.itemsOffset >= 0
        else { return }

        cell.isLoadingImage = true

        DispatchQueue.global(qos: .userInteractive).async { [unowned self] in
            let requestOptions = PHImageRequestOptions()
            requestOptions.isSynchronous = true
            requestOptions.isNetworkAccessAllowed = true

            PHImageManager.default().requestImage(
                for: assets.object(at: indexPath.item - layout.itemsOffset),
                targetSize: CGSize(width: view.bounds.width * UIScreen.main.scale, height: view.bounds.height * UIScreen.main.scale),
                contentMode: .aspectFit,
                options: requestOptions
            ) { [weak self] (image, _) -> Void in
                DispatchQueue.main.async {
                    cell.isLoadingImage = false
                    cell.image = image
                    self!.heroTransition = HeroTransitioningDelegate(fromView: cell.contentView.subviews[1] as! UIImageView, fromViewFrame: cell.convert(cell.bounds, to: self!.view))

                    let editor = EditorViewController()
                    editor.image = image ?? UIImage(named: "testImage")!
                    editor.modalPresentationStyle = .overFullScreen
                    editor.transitioningDelegate = self!.heroTransition

                    self!.present(editor, animated: true)
                }
            }
        }
    }
}

extension GalleryController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let layout = collectionView.collectionViewLayout as? GalleryLayout else { return 0 }
        return assets.count + layout.itemsOffset
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let layout = collectionView.collectionViewLayout as? GalleryLayout
        else { return UICollectionViewCell() }

        let cell: GalleryCell

        if collectionView === collection9 {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photo", for: indexPath) as! GalleryCell
            cell.bordered = false
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photo2", for: indexPath) as! GalleryCell
            cell.bordered = true
        }

        cell.image = nil
        cell.isLoadingImage = false

        guard
            indexPath.item - layout.itemsOffset >= 0
        else {
            return cell
        }

        DispatchQueue.global(qos: .userInteractive).async {[unowned self] in
            let options = PHImageRequestOptions()
            options.isSynchronous = true
            options.isNetworkAccessAllowed = true

            PHImageManager.default().requestImage(
                for: assets.object(at: indexPath.item - layout.itemsOffset),
                targetSize: CGSize(width: 128, height: 128),
                contentMode: .aspectFill,
                options: options
            ) { (image, _) -> Void in
                DispatchQueue.main.async {
                    cell.image = image ?? UIImage(named: "testImage")
                }
            }
        }

        return cell
    }


}
