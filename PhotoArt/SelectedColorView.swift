//
//  SelectedColorView.swift
//  PhotoArt
//
//  Created by Rustam Khakhuk on 29.10.2022.
//

import UIKit

class SelectedColorView: UIView {
    var color: UIColor {
        get {
            return colorView.backgroundColor!
        }
        set {
            colorView.backgroundColor = newValue
        }
    }

    var colorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints  = false

        return view
    }()

    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!

        UIColor.white.setFill()
        context.fill([rect])

        context.move(to: .zero)
        context.addLine(to: CGPoint(x: rect.width, y: 0))
        context.addLine(to: CGPoint(x: 0, y: rect.height))

        context.closePath()

        UIColor.black.setFill()

        context.fillPath()
    }

    init() {
        super.init(frame: .zero)

        addSubview(colorView)

        NSLayoutConstraint.activate([
            colorView.leftAnchor.constraint(equalTo: leftAnchor),
            colorView.rightAnchor.constraint(equalTo: rightAnchor),
            colorView.topAnchor.constraint(equalTo: topAnchor),
            colorView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
