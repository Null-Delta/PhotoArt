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
            self.preview.image = newValue
        }
    }

    private var loadingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.backgroundColor = UIColor.white.withAlphaComponent(0.2).cgColor

        return view
    }()

    private var rotateView: UIActivityIndicatorView = {
        let rotation = UIActivityIndicatorView(style: .medium)
        rotation.translatesAutoresizingMaskIntoConstraints = false
        rotation.alpha = 0
        rotation.backgroundColor = UIColor.black.withAlphaComponent(0.5)

        return rotation
    }()

    private var timeLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = ""
        lbl.shadowColor = .black
        lbl.shadowOffset = .zero
        lbl.layer.shadowOpacity = 0.25
        lbl.layer.shadowRadius = 8
        lbl.font = .systemFont(ofSize: 12, weight: .medium)
        lbl.textColor = .white
        return lbl
    }()

    var bordered: Bool = false {
        didSet {
            preview.layer.borderWidth = bordered ? 1 : 0
        }
    }

    var time: String? {
        get {
            return timeLabel.text
        }

        set {
            timeLabel.text = newValue
        }
    }

    var isLoading: Bool {
        get {
            return rotateView.alpha != 0
        }

        set {
            if newValue {
                rotateView.startAnimating()
            } else {
                rotateView.stopAnimating()
            }

            UIView.animate(withDuration: 0.25) { [unowned self] in
                rotateView.alpha = newValue ? 1 : 0
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(loadingView)
        contentView.addSubview(preview)
        contentView.addSubview(timeLabel)
        contentView.addSubview(rotateView)

        NSLayoutConstraint.activate([
            loadingView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            loadingView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            loadingView.topAnchor.constraint(equalTo: contentView.topAnchor),
            loadingView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            preview.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            preview.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            preview.topAnchor.constraint(equalTo: contentView.topAnchor),
            preview.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            timeLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8),
            timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            rotateView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            rotateView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            rotateView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            rotateView.heightAnchor.constraint(equalTo: contentView.heightAnchor),

        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
