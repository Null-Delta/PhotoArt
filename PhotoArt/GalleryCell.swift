//
//  GalleryCell.swift
//  PhotoArt
//
//  Created by Rustam Khakhuk on 13.10.2022.
//

import UIKit

class GalleryCell: UICollectionViewCell {
    lazy private var preview: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill

        view.clipsToBounds = true
        return view
    }()

    var image: UIImage? {
        get {
            return preview.image
        }

        set {
            preview.image = newValue
            if newValue == nil {
                loadingView.layer.removeAllAnimations()

                let animation = CABasicAnimation(keyPath: "backgroundColor")
                animation.toValue = UIColor.white.withAlphaComponent(0).cgColor
                animation.fromValue = UIColor.white.withAlphaComponent(0.2).cgColor
                animation.duration = 1
                animation.autoreverses = true
                animation.repeatCount = .infinity
                animation.timingFunction = .init(name: .easeInEaseOut)

                loadingView.layer.add(animation, forKey: "backgroundColor")
            }
        }
    }

    private var loadingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.backgroundColor = UIColor.white.withAlphaComponent(0.2).cgColor

        return view
    }()

    private var loadingImageView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return view
    }()

    var isLoadingImage: Bool = false {
        didSet {
            loadingImageView.alpha = isLoadingImage ? 1 : 0
            if isLoadingImage {
                loadingImageView.startAnimating()
            }
        }
    }

    var bordered: Bool = false {
        didSet {
            preview.layer.borderWidth = bordered ? 0.5 : 0
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(loadingView)
        contentView.addSubview(preview)
        contentView.addSubview(loadingImageView)

        NSLayoutConstraint.activate([
            loadingView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            loadingView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            loadingView.topAnchor.constraint(equalTo: contentView.topAnchor),
            loadingView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            preview.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            preview.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            preview.topAnchor.constraint(equalTo: contentView.topAnchor),
            preview.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            loadingImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            loadingImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            loadingImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            loadingImageView.heightAnchor.constraint(equalTo: contentView.heightAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
