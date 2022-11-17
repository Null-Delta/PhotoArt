//
//  SavedColorCell.swift
//  PhotoArt
//
//  Created by Rustam Khakhuk on 29.10.2022.
//

import UIKit

class SavedColorCell: UICollectionViewCell {

    var onLongPress: () -> () = { }
    var onAdd: () -> () = { }

    lazy private var colorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        view.backgroundColor = .red

        return view
    }()

    lazy private var colorBorder: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.borderColor = UIColor.blue.cgColor
        view.layer.borderWidth = 2
        view.backgroundColor = .clear

        return view
    }()

    lazy private var imageView: UIImageView = {
        let img = UIImageView()

        img.clipsToBounds = true
        img.layer.cornerRadius = 16
        img.backgroundColor = .darkGray
        img.contentMode = .center
        img.image = UIImage(systemName: "plus")?.withAlignmentRectInsets(.init(top: 4, left: 4, bottom: 4, right: 4))
        img.tintColor = .white
        return img
    }()

    var select: Bool {
        get {
            return colorBorder.layer.borderWidth == 16
        }
        set {
            colorBorder.layer.borderWidth = newValue ? 4 : 16
        }
    }

    var color: UIColor {
        get {
            return colorView.backgroundColor!
        }

        set {
            colorView.backgroundColor = newValue
            colorBorder.layer.borderColor = newValue.cgColor
        }
    }

    var isAdditive: Bool {
        get {
            return imageView.alpha == 1
        }

        set {
            imageView.alpha = newValue ? 1 : 0
        }
    }

    lazy private var longGesture: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(onGesture))
        gesture.minimumPressDuration = 0.25

        return gesture
    }()

    @objc private func onGesture() {
        guard !isAdditive else { return }

        UIMenuController.shared.menuItems = [
            UIMenuItem(title: "Delete", action: #selector(onDelete))
        ]

        UIMenuController.shared.showMenu(from: contentView, rect: contentView.bounds)
    }

    @objc private func onDelete() {
        onLongPress()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(colorView)
        contentView.addSubview(colorBorder)
        contentView.addSubview(imageView)

        imageView.frame = CGRect(x: 0, y: 0, width: 32, height: 32)

        contentView.backgroundColor = .clear

        contentView.addGestureRecognizer(longGesture)

        NSLayoutConstraint.activate([
            colorView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 8),
            colorView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8),
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            colorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            colorBorder.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            colorBorder.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            colorBorder.topAnchor.constraint(equalTo: contentView.topAnchor),
            colorBorder.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
