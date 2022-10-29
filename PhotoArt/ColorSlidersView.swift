//
//  SlidersView.swift
//  PhotoArt
//
//  Created by Rustam Khakhuk on 28.10.2022.
//

import UIKit

class ColorSlidersView: UIView {
    var color: UIColor = .red {
        didSet {
            print(color.r, color.g, color.b)
            redSlider.startColor = UIColor(red: 0, green: color.g, blue: color.b, alpha: 1)
            redSlider.endColor = UIColor(red: 1, green: color.g, blue: color.b, alpha: 1)
            redSlider.value = color.r

            greenSlider.startColor = UIColor(red: color.r, green: 0, blue: color.b, alpha: 1)
            greenSlider.endColor = UIColor(red: color.r, green: 1, blue: color.b, alpha: 1)
            greenSlider.value = color.g

            blueSlider.startColor = UIColor(red: color.r, green: color.g, blue: 0, alpha: 1)
            blueSlider.endColor = UIColor(red: color.r, green: color.g, blue: 1, alpha: 1)
            blueSlider.value = color.b
        }
    }

    var onColorChange: (UIColor) -> Void = { _ in }

    lazy private var redSlider: ColorSlider = {
        let slider = ColorSlider(
            onChange: { [unowned self] newValue in
                color = UIColor(red: newValue, green: color.g, blue: color.b, alpha: 1)
                onColorChange(color)
            }
        )

        slider.title = "RED"

        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()

    lazy private var greenSlider: ColorSlider = {
        let slider = ColorSlider(
            onChange: { [unowned self] newValue in
                color = UIColor(red: color.r, green: newValue, blue: color.b, alpha: 1)
                onColorChange(color)
            }
        )

        slider.title = "GREEN"

        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()

    lazy private var blueSlider: ColorSlider = {
        let slider = ColorSlider(
            onChange: { [unowned self] newValue in
                color = UIColor(red: color.r, green: color.g, blue: newValue, alpha: 1)
                onColorChange(color)
            }
        )

        slider.title = "BLUE"

        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()

    init() {
        super.init(frame: .zero)

        addSubview(redSlider)
        addSubview(greenSlider)
        addSubview(blueSlider)

        NSLayoutConstraint.activate([
            redSlider.leftAnchor.constraint(equalTo: leftAnchor),
            redSlider.rightAnchor.constraint(equalTo: rightAnchor),
            redSlider.topAnchor.constraint(equalTo: topAnchor),

            greenSlider.leftAnchor.constraint(equalTo: leftAnchor),
            greenSlider.rightAnchor.constraint(equalTo: rightAnchor),
            greenSlider.topAnchor.constraint(equalTo: redSlider.bottomAnchor, constant: 28),

            blueSlider.leftAnchor.constraint(equalTo: leftAnchor),
            blueSlider.rightAnchor.constraint(equalTo: rightAnchor),
            blueSlider.topAnchor.constraint(equalTo: greenSlider.bottomAnchor, constant: 28),

            bottomAnchor.constraint(equalTo: blueSlider.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
