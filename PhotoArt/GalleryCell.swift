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
            UIView.animate(withDuration: 0.25, animations: {
                self.preview.image = newValue
            })
        }
    }

    private var loadingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.backgroundColor = UIColor.white.withAlphaComponent(0.2).cgColor

        return view
    }()

    var bordered: Bool = false {
        didSet {
            preview.layer.borderWidth = bordered ? 1 : 0
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(loadingView)
        contentView.addSubview(preview)

        NSLayoutConstraint.activate([
            loadingView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            loadingView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            loadingView.topAnchor.constraint(equalTo: contentView.topAnchor),
            loadingView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            preview.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            preview.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            preview.topAnchor.constraint(equalTo: contentView.topAnchor),
            preview.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
