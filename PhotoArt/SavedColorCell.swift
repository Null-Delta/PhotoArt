//
//  SavedColorCell.swift
//  PhotoArt
//
//  Created by Rustam Khakhuk on 29.10.2022.
//

import UIKit

class SavedColorCell: UICollectionViewCell {

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

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(colorView)
        contentView.addSubview(colorBorder)
        contentView.backgroundColor = .clear

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
