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
    private var manager: PHCachingImageManager = PHCachingImageManager()

    lazy private var collection: GalleryGrid = {
        let collection = GalleryGrid(delegate: self, dataSource: self)
        collection.translatesAutoresizingMaskIntoConstraints = false

        return collection
    }()

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
        view.addSubview(collection)
        view.addSubview(blurView)

        NSLayoutConstraint.activate([
            collection.leftAnchor.constraint(equalTo: view.leftAnchor),
            collection.rightAnchor.constraint(equalTo: view.rightAnchor),
            collection.topAnchor.constraint(equalTo: view.topAnchor),
            collection.bottomAnchor.constraint(equalTo: view.bottomAnchor),

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
            indexPath.item - layout.itemsOffset >= 0
        else { return }


        if layout is MultiGalleryLayout {
            collection.animateZoom(atIndex: indexPath.item * layout.countOfColumns + 1)
        } else {
            guard
                let cell = collectionView.cellForItem(at: indexPath) as? GalleryCell
            else { return }
            let size = CGSize(width: view.bounds.width * UIScreen.main.scale, height: view.bounds.height * UIScreen.main.scale)

            DispatchQueue.global(qos: .userInteractive).async { [unowned self] in
                let requestOptions = PHImageRequestOptions()
                requestOptions.isSynchronous = true
                requestOptions.isNetworkAccessAllowed = true

                manager.requestImage(
                    for: assets.object(at: indexPath.item - layout.itemsOffset),
                    targetSize: size,
                    contentMode: .aspectFit,
                    options: requestOptions
                ) { [weak self] (image, _) -> Void in
                    DispatchQueue.main.async {
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

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x != 0 {
            scrollView.contentOffset.x = 0
        }
    }
}

extension GalleryController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let layout = collectionView.collectionViewLayout as? GalleryLayout else { return 0 }

        if layout is MultiGalleryLayout {
            return Int(ceil(CGFloat(assets.count) / CGFloat(layout.countOfColumns)))
        } else {
            return assets.count + layout.itemsOffset
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let layout = collectionView.collectionViewLayout as? GalleryLayout
        else { return UICollectionViewCell() }

        var imageSize: CGSize = CGSize(width: layout.cellSize, height: layout.cellSize)

        if layout is MultiGalleryLayout {
            imageSize = CGSize(width: imageSize.width / 5, height: imageSize.height / 5)
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "multi_photo", for: indexPath) as! MultiGalleryCell
            cell.clearImages()
            
            for assetIndex in 0..<13 {
                let globalIndex = indexPath.item * layout.countOfColumns + assetIndex - layout.itemsOffset

                guard
                    globalIndex >= 0,
                    globalIndex < assets.count
                else {
                    cell.updateImage(at: assetIndex, image: nil)
                    continue
                }

                DispatchQueue.global(qos: .userInitiated).async {[unowned self] in
                    let options = PHImageRequestOptions()
                    options.isSynchronous = false
                    options.isNetworkAccessAllowed = false
                    options.deliveryMode = .fastFormat

                    manager.requestImage(
                        for: assets.object(at: globalIndex),
                        targetSize: imageSize,
                        contentMode: .aspectFill,
                        options: options
                    ) { (image, _) -> Void in
                        DispatchQueue.main.async {
                            cell.updateImage(at: assetIndex, image: image)
                        }
                    }
                }
            }

            return cell

        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photo", for: indexPath) as! GalleryCell

            cell.bordered = layout.countOfColumns <= 5
            cell.image = nil

            guard
                indexPath.item - layout.itemsOffset >= 0
            else {
                return cell
            }

            DispatchQueue.global(qos: .default).async {[unowned self] in
                let options = PHImageRequestOptions()
                options.isSynchronous = false
                options.isNetworkAccessAllowed = true

                manager.requestImage(
                    for: assets.object(at: indexPath.item - layout.itemsOffset),
                    targetSize: imageSize,
                    contentMode: .aspectFill,
                    options: options
                ) { (image, _) -> Void in
                    DispatchQueue.main.async {
                        cell.image = image
                    }
                }
            }
            return cell
        }
    }
}
