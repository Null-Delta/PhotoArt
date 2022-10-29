//
//  SpectrumView.swift
//  PhotoArt
//
//  Created by Rustam Khakhuk on 28.10.2022.
//

import UIKit

class SpectrumView: UIView {

    var onColorChanged: (UIColor) -> () = { _ in }

    func clearSelection() {
        toggle.isHidden = true
    }

    lazy private var gradientPickerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    lazy private var gradientPickerLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()

        gradient.frame = CGRect(origin: .zero, size: CGSize(width: 320, height: 320))

        gradient.colors = [
            UIColor(red: 1, green: 0, blue: 0, alpha: 1).cgColor,
            UIColor(red: 1, green: 1, blue: 0, alpha: 1).cgColor,
            UIColor(red: 0, green: 1, blue: 0, alpha: 1).cgColor,
            UIColor(red: 0, green: 1, blue: 1, alpha: 1).cgColor,
            UIColor(red: 0, green: 0, blue: 1, alpha: 1).cgColor,
            UIColor(red: 1, green: 0, blue: 1, alpha: 1).cgColor,
            UIColor(red: 1, green: 0, blue: 0, alpha: 1).cgColor
        ]

        gradient.type = .axial
        gradient.startPoint = CGPoint(x: 0.5, y: 0.05)
        gradient.endPoint = CGPoint(x: 0.5, y: 0.95)
        gradient.locations = [
            0.00,
            0.16,
            0.33,
            0.49,
            0.66,
            0.82,
            1.00
        ]
        gradient.cornerRadius = 8
        gradient.cornerCurve = .continuous

        gradient.insertSublayer(gradientPickerLightLayer, at: 0)

        return gradient
    }()

    lazy private var gradientPickerLightLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()

        gradient.frame = CGRect(origin: .zero, size: CGSize(width: 320, height: 320))

        gradient.colors = [
            UIColor(red: 1, green: 1, blue: 1, alpha: 1.00).cgColor,
            UIColor(red: 1, green: 1, blue: 1, alpha: 0.9914).cgColor,
            UIColor(red: 1, green: 1, blue: 1, alpha: 0.9645).cgColor,
            UIColor(red: 1, green: 1, blue: 1, alpha: 0.9183).cgColor,
            UIColor(red: 1, green: 1, blue: 1, alpha: 0.8526).cgColor,
            UIColor(red: 1, green: 1, blue: 1, alpha: 0.7682).cgColor,
            UIColor(red: 1, green: 1, blue: 1, alpha: 0.6681).cgColor,
            UIColor(red: 1, green: 1, blue: 1, alpha: 0.5573).cgColor,
            UIColor(red: 1, green: 1, blue: 1, alpha: 0.4427).cgColor,
            UIColor(red: 1, green: 1, blue: 1, alpha: 0.3319).cgColor,
            UIColor(red: 1, green: 1, blue: 1, alpha: 0.2318).cgColor,
            UIColor(red: 1, green: 1, blue: 1, alpha: 0.1474).cgColor,
            UIColor(red: 1, green: 1, blue: 1, alpha: 0.0817).cgColor,
            UIColor(red: 1, green: 1, blue: 1, alpha: 0.0355).cgColor,
            UIColor(red: 1, green: 1, blue: 1, alpha: 0.0086).cgColor,
            UIColor(red: 1, green: 1, blue: 1, alpha: 0.000).cgColor,
        ]

        gradient.type = .axial
        gradient.startPoint = CGPoint(x: 0.05, y: 0.5)
        gradient.endPoint = CGPoint(x: 0.4, y: 0.5)
        gradient.cornerRadius = 8
        gradient.cornerCurve = .continuous

        gradient.insertSublayer(gradientPickerDarkLayer, at: 0)

        return gradient
    }()

    lazy private var gradientPickerDarkLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()

        gradient.frame = CGRect(origin: .zero, size: CGSize(width: 320, height: 320))

        gradient.colors = [
            UIColor(red: 0, green: 0, blue: 0, alpha: 1.00).cgColor,
            UIColor(red: 0, green: 0, blue: 0, alpha: 0.9914).cgColor,
            UIColor(red: 0, green: 0, blue: 0, alpha: 0.9645).cgColor,
            UIColor(red: 0, green: 0, blue: 0, alpha: 0.9183).cgColor,
            UIColor(red: 0, green: 0, blue: 0, alpha: 0.8526).cgColor,
            UIColor(red: 0, green: 0, blue: 0, alpha: 0.7682).cgColor,
            UIColor(red: 0, green: 0, blue: 0, alpha: 0.6681).cgColor,
            UIColor(red: 0, green: 0, blue: 0, alpha: 0.5573).cgColor,
            UIColor(red: 0, green: 0, blue: 0, alpha: 0.4427).cgColor,
            UIColor(red: 0, green: 0, blue: 0, alpha: 0.3319).cgColor,
            UIColor(red: 0, green: 0, blue: 0, alpha: 0.2318).cgColor,
            UIColor(red: 0, green: 0, blue: 0, alpha: 0.1474).cgColor,
            UIColor(red: 0, green: 0, blue: 0, alpha: 0.0817).cgColor,
            UIColor(red: 0, green: 0, blue: 0, alpha: 0.0355).cgColor,
            UIColor(red: 0, green: 0, blue: 0, alpha: 0.0086).cgColor,
            UIColor(red: 0, green: 0, blue: 0, alpha: 0.000).cgColor,
        ].reversed()

        gradient.type = .axial
        gradient.startPoint = CGPoint(x: 0.6, y: 0.5)
        gradient.endPoint = CGPoint(x: 0.95, y: 0.5)
        gradient.cornerRadius = 8
        gradient.cornerCurve = .continuous

        return gradient
    }()

    lazy private var toggle: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 12
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 3

        view.backgroundColor = .red

        return view
    }()

    private var toggleXConstraint: NSLayoutConstraint!
    private var toggleYConstraint: NSLayoutConstraint!


    lazy private var gesture: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(onGesture))
        gesture.minimumPressDuration = 0

        return gesture
    }()

    @objc private func onGesture() {
        toggle.isHidden = false

        var location = gesture.location(in: self)
        location.x = min(frame.width, max(0, location.x))
        location.y = min(frame.height, max(0, location.y))

        switch gesture.state {
        case .began, .changed:
            let color = coordToColor(position: location)
            onColorChanged(color)
            toggle.backgroundColor = color

            toggleXConstraint.constant = location.x
            toggleYConstraint.constant = location.y

            layoutIfNeeded()
            break

        default:
            break
        }
    }

    private func coordToColor(position: CGPoint) -> UIColor {
        var normalisedPosition = CGPoint(x: position.x / frame.width, y: position.y / frame.height)

        normalisedPosition.y = max(0, min(1, normalisedPosition.y))
        normalisedPosition.x = max(0, min(1, normalisedPosition.x))

        let accentColor = UIColor.between(gradient: [
            UIColor(red: 1, green: 0, blue: 0, alpha: 1),
            UIColor(red: 1, green: 1, blue: 0, alpha: 1),
            UIColor(red: 0, green: 1, blue: 0, alpha: 1),
            UIColor(red: 0, green: 1, blue: 1, alpha: 1),
            UIColor(red: 0, green: 0, blue: 1, alpha: 1),
            UIColor(red: 1, green: 0, blue: 1, alpha: 1),
            UIColor(red: 1, green: 0, blue: 0, alpha: 1)
        ], value: normalisedPosition.y)

        let whiteValue = max(0, 1 - normalisedPosition.x / 0.4)
        let darkValue = max(0, 1 - (1 - normalisedPosition.x) / 0.4)

        print(normalisedPosition)
        print(whiteValue)
        print(darkValue)

        let deltaR = 1 - accentColor.r
        let deltaG = 1 - accentColor.g
        let deltaB = 1 - accentColor.b

        let whitedColor = UIColor(
            red: accentColor.r + deltaR * whiteValue,
            green: accentColor.g + deltaG * whiteValue,
            blue: accentColor.b + deltaB * whiteValue,
            alpha: 1
        )

        let darkedColor = UIColor(
            red: whitedColor.r * (1 - darkValue),
            green: whitedColor.g * (1 - darkValue),
            blue: whitedColor.b * (1 - darkValue),
            alpha: 1
        )

        return darkedColor
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        gradientPickerLayer.frame = gradientPickerView.bounds
        gradientPickerLightLayer.frame = gradientPickerView.bounds
        gradientPickerDarkLayer.frame = gradientPickerView.bounds

        gradientPickerView.layer.addSublayer(gradientPickerLayer)
        gradientPickerView.layer.addSublayer(gradientPickerLightLayer)
        gradientPickerView.layer.addSublayer(gradientPickerDarkLayer)
    }

    init() {
        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false

        addSubview(gradientPickerView)
        addSubview(toggle)

        addGestureRecognizer(gesture)

        toggleXConstraint = toggle.centerXAnchor.constraint(equalTo: leftAnchor, constant: 0)
        toggleYConstraint = toggle.centerYAnchor.constraint(equalTo: topAnchor, constant: 0)

        NSLayoutConstraint.activate([
            gradientPickerView.leftAnchor.constraint(equalTo: leftAnchor),
            gradientPickerView.rightAnchor.constraint(equalTo: rightAnchor),
            gradientPickerView.topAnchor.constraint(equalTo: topAnchor),
            gradientPickerView.bottomAnchor.constraint(equalTo: bottomAnchor),

            toggle.widthAnchor.constraint(equalToConstant: 24),
            toggle.heightAnchor.constraint(equalToConstant: 24),
            toggleXConstraint,
            toggleYConstraint
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
