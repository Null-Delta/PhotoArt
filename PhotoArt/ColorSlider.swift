//
//  ColorSlider.swift
//  PhotoArt
//
//  Created by Rustam Khakhuk on 27.10.2022.
//

import UIKit

class ColorSlider: UIView {
    var startColor: UIColor = .white
    var endColor: UIColor = .black
    var value: CGFloat = 0
    var title: String {
        get {
            return titleLabel.text ?? ""
        }
        set {
            titleLabel.text = newValue
        }
    }

    lazy private var titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = .systemFont(ofSize: 13, weight: .medium)
        lbl.textColor = .gray
        return lbl
    }()

    lazy private var background: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 18

        view.backgroundColor = .red
        return view
    }()

    lazy private var gradient: CAGradientLayer = {
        let gradient = CAGradientLayer()

        return gradient
    }()

    init() {
        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false
        addSubview(background)
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 4),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),

            background.leftAnchor.constraint(equalTo: leftAnchor),
            background.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            background.heightAnchor.constraint(equalToConstant: 36),
            background.rightAnchor.constraint(equalTo: rightAnchor),

            bottomAnchor.constraint(equalTo: background.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
