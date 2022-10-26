//
//  TextAlignmentButton.swift
//  PhotoArt
//
//  Created by Rustam Khakhuk on 25.10.2022.
//

import UIKit

class TextAlignmentButton: UIView {
    var alignment: NSTextAlignment = .center {
        didSet {
            setAlignment(for: alignment)
        }
    }

    var onAlignmentChange: (NSTextAlignment) -> () = { _ in }

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
        switch alignment {
        case .left:
            alignment = .center
        case .center:
            alignment = .right
        default:
            alignment = .left
        }

        setAlignment(for: alignment)
        onAlignmentChange(alignment)
    }

    private func setAlignment(for alignment: NSTextAlignment) {
        switch alignment {
        case .left:
            previewImage.image = UIImage(named: "textLeft")
        case .center:
            previewImage.image = UIImage(named: "textCenter")
        default:
            previewImage.image = UIImage(named: "textRight")
        }
    }

    override init(frame: CGRect) {
        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false

        addSubview(previewImage)
        addGestureRecognizer(tapGesture)

        setAlignment(for: alignment)

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
