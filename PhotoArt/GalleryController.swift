//
//  GalleryController.swift
//  PhotoArt
//
//  Created by Rustam Khakhuk on 13.10.2022.
//

import UIKit
import Photos
import PencilKit

class OverridedAsset {
    var preview: UIImage
    var sourcePreview: UIImage
    var source: Any
    var texts: [Text]
    var drawing: PKDrawing

    init(preview: UIImage, sourcePreview: UIImage, source: Any, texts: [Text], drawing: PKDrawing) {
        self.preview = preview
        self.sourcePreview = sourcePreview
        self.source = source
        self.texts = texts
        self.drawing = drawing
    }
}

class GalleryController: UIViewController {

    private var heroTransition: HeroTransitioningDelegate?

    private var assets: PHFetchResult<PHAsset>!
    private var manager: PHCachingImageManager = PHCachingImageManager()

    private var overridedAssets: [Int: OverridedAsset] = [:]
    private var cachesMiniatures: [Int: UIImage] = [:]

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
    }

    override func viewDidLoad() {
        view.addSubview(collection)
        view.addSubview(blurView)
        view.backgroundColor = .black

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

        self.assets = PHAsset.fetchAssets(with: options)
    }
}

extension GalleryController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard
            let layout = collectionView.collectionViewLayout as? GalleryLayout,
            indexPath.item - layout.itemsOffset >= 0
        else { return }

        if layout.countOfColumns == 13 {
            collection.animateZoom(atIndex: indexPath.item)
        } else {
            guard
                let cell = collectionView.cellForItem(at: indexPath) as? GalleryCell
            else { return }
            let size = CGSize(width: view.bounds.width * UIScreen.main.scale, height: view.bounds.height * UIScreen.main.scale)

            if overridedAssets[indexPath.item - layout.itemsOffset] != nil {
                cell.image = overridedAssets[indexPath.item - layout.itemsOffset]?.preview
                heroTransition = HeroTransitioningDelegate(fromView: cell.contentView.subviews[1] as! UIImageView, fromViewFrame: cell.convert(cell.bounds, to: view))

                let editor = EditorViewController()
                editor.overridedAsset = overridedAssets[indexPath.item - layout.itemsOffset]
                editor.image = cell.image ?? UIImage(named: "testImage")!
                editor.video = overridedAssets[indexPath.item - layout.itemsOffset]?.source as? AVAsset
                editor.modalPresentationStyle = .overFullScreen
                editor.transitioningDelegate = heroTransition
                editor.onEdit = { [unowned self] newAsset in
                    overridedAssets[indexPath.item - layout.itemsOffset] = newAsset
                    collection.reloadItem(at: indexPath.item)
                    cell.image = newAsset.preview
                }
                cell.isLoading = false

                present(editor, animated: true)

            } else {
                cell.isLoading = true

                if assets.object(at: indexPath.item - layout.itemsOffset).mediaType == .image {
                    DispatchQueue.global(qos: .userInteractive).async { [unowned self] in
                        let requestOptions = PHImageRequestOptions()
                        requestOptions.isSynchronous = true
                        requestOptions.isNetworkAccessAllowed = true

                        manager.requestImage(
                            for: assets.object(at: indexPath.item - layout.itemsOffset),
                            targetSize: size,
                            contentMode: .aspectFit,
                            options: requestOptions
                        ) { [unowned self] (image, data) -> Void in
                            DispatchQueue.main.async { [unowned self] in
                                cell.image = image
                                heroTransition = HeroTransitioningDelegate(fromView: cell.contentView.subviews[1] as! UIImageView, fromViewFrame: cell.convert(cell.bounds, to: view))

                                let editor = EditorViewController()
                                editor.image = image ?? UIImage(named: "testImage")!
                                editor.modalPresentationStyle = .overFullScreen
                                editor.transitioningDelegate = heroTransition
                                editor.onEdit = { [unowned self] newAsset in
                                    overridedAssets[indexPath.item - layout.itemsOffset] = newAsset
                                    collection.reloadItem(at: indexPath.item)
                                    cell.image = newAsset.preview
                                }

                                cell.isLoading = false

                                present(editor, animated: true)
                            }
                        }
                    }
                } else {
                    cell.isLoading = true

                    DispatchQueue.global(qos: .userInteractive).async { [unowned self] in
                        let requestVideoOptions = PHVideoRequestOptions()
                        requestVideoOptions.deliveryMode = .mediumQualityFormat
                        requestVideoOptions.isNetworkAccessAllowed = true

                        let requestOptions = PHImageRequestOptions()
                        requestOptions.isSynchronous = true
                        requestOptions.isNetworkAccessAllowed = true

                        manager.requestImage(
                            for: assets.object(at: indexPath.item - layout.itemsOffset),
                            targetSize: size,
                            contentMode: .aspectFit,
                            options: requestOptions
                        ) { [unowned self] (image, data) -> Void in

                            guard image != nil else { return }

                            manager.requestAVAsset(
                                forVideo: assets.object(at: indexPath.item - layout.itemsOffset),
                                options: requestVideoOptions,
                                resultHandler: { video, _, _ in
                                    guard video != nil else { return }

                                    DispatchQueue.main.async { [unowned self] in
                                        heroTransition = HeroTransitioningDelegate(fromView: cell.contentView.subviews[1] as! UIImageView, fromViewFrame: cell.convert(cell.bounds, to: view))
                                        cell.image = image

                                        let editor = EditorViewController()
                                        editor.video = video
                                        editor.image = image!
                                        editor.modalPresentationStyle = .overFullScreen
                                        editor.transitioningDelegate = heroTransition
                                        editor.onEdit = { [unowned self] newAsset in
                                            overridedAssets[indexPath.item - layout.itemsOffset] = newAsset
                                            collection.reloadItem(at: indexPath.item)
                                            cell.image = newAsset.preview
                                        }
                                        cell.isLoading = false

                                        present(editor, animated: true)
                                    }
                                }
                            )
                        }
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

        return assets.count + layout.itemsOffset
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let layout = collectionView.collectionViewLayout as? GalleryLayout
        else { return UICollectionViewCell() }

        let imageSize: CGSize = CGSize(width: layout.cellSize, height: layout.cellSize)

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photo", for: indexPath) as! GalleryCell

        cell.bordered = layout.countOfColumns <= 5
        cell.image = nil

        guard
            indexPath.item - layout.itemsOffset >= 0
        else {
            return cell
        }

        if overridedAssets[indexPath.item - layout.itemsOffset] != nil {
           cell.image = overridedAssets[indexPath.item - layout.itemsOffset]?.preview
        } else if cachesMiniatures[indexPath.item - layout.itemsOffset] != nil && layout.countOfColumns == 13 {
            cell.image = cachesMiniatures[indexPath.item - layout.itemsOffset]
        }  else {
            if assets.object(at: indexPath.item - layout.itemsOffset).mediaType == .image || layout.countOfColumns == 13 {
                cell.time = nil
            } else {
                cell.time = toTime(time: assets.object(at: indexPath.item - layout.itemsOffset).duration)
            }

            DispatchQueue.global(qos: .unspecified).async {[unowned self] in
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                options.isNetworkAccessAllowed = true

                manager.requestImage(
                    for: assets.object(at: indexPath.item - layout.itemsOffset),
                    targetSize: imageSize,
                    contentMode: .aspectFill,
                    options: options
                ) { (image, _) -> Void in
                    DispatchQueue.main.async {
                        if layout.countOfColumns == 13 {
                            self.cachesMiniatures[indexPath.item - layout.itemsOffset] = image
                        }
                        cell.image = image
                    }
                }
            }
        }

        return cell
    }

    private func toTime(time: TimeInterval) -> String {
        return "\(Int(time / 60)):\(Int(time)%60)"
    }
}

extension GalleryController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
