//
//  TextStyleButton.swift
//  PhotoArt
//
//  Created by Rustam Khakhuk on 25.10.2022.
//

import UIKit

class TextStyleButton: UIView {
    var style: TextStyle = .normal {
        didSet {
            setImage(for: style)
        }
    }

    var onStyleChange: (TextStyle) -> () = { _ in }


    lazy private var previewImage: UIImageView = {
        let img = UIImageView(frame: .zero)
        img.translatesAutoresizingMaskIntoConstraints = false

        return img
    }()

    lazy private var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(onTap))

        return gesture
    }()

    @objc private func onTap() {
        switch style {
        case .normal:
            style = .outlined
        case .outlined:
            style = .background
        case .background:
            style = .transparent
        case .transparent:
            style = .normal
        }

        setImage(for: style)
        onStyleChange(style)
    }

    private func setImage(for style: TextStyle) {
        switch style {
        case .normal:
            previewImage.image = UIImage(named: "default")
        case .outlined:
            previewImage.image = UIImage(named: "stroke")
        case .background:
            previewImage.image = UIImage(named: "filled")
        case .transparent:
            previewImage.image = UIImage(named: "semi")
        }
    }

    override init(frame: CGRect) {
        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false

        addSubview(previewImage)
        addGestureRecognizer(tapGesture)

        setImage(for: style)

        NSLayoutConstraint.activate([
            previewImage.leftAnchor.constraint(equalTo: leftAnchor),
            previewImage.rightAnchor.constraint(equalTo: rightAnchor),
            previewImage.topAnchor.constraint(equalTo: topAnchor),
            previewImage.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
