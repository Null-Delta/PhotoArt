//
//  ColorButton.swift
//  PhotoArt
//
//  Created by Rustam Khakhuk on 11.10.2022.
//

import UIKit

class ColorButton: UIView {
    var color: UIColor {
        get {
            return colorView.backgroundColor!
        }

        set {
            colorView.backgroundColor = newValue
        }
    }

    private var onColorCanged: (UIColor) -> Void

    private var colorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 9

        return view
    }()

    lazy private var gradientView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false

        view.widthAnchor.constraint(equalToConstant: 32).isActive = true
        view.heightAnchor.constraint(equalToConstant: 32).isActive = true

        view.layer.cornerRadius = 16
        view.layer.insertSublayer(gradientLayer, at: 0)

        let mask = UIView()
        mask.layer.cornerRadius = 16
        mask.layer.borderWidth = 3
        mask.backgroundColor = .clear
        mask.frame = CGRect(origin: .zero, size: CGSize(width: 32, height: 32))

        view.addSubview(mask)
        view.mask = mask

        return view
    }()

    lazy private var gradientLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 1, green: 0, blue: 0, alpha: 1).cgColor,
            UIColor(red: 1, green: 1, blue: 0, alpha: 1).cgColor,
            UIColor(red: 0, green: 1, blue: 0, alpha: 1).cgColor,
            UIColor(red: 0, green: 1, blue: 1, alpha: 1).cgColor,
            UIColor(red: 0, green: 0, blue: 1, alpha: 1).cgColor,
            UIColor(red: 1, green: 0, blue: 1, alpha: 1).cgColor,
            UIColor(red: 1, green: 0, blue: 0, alpha: 1).cgColor
        ]

        gradient.type = .conic
        gradient.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: -1)
        gradient.locations = [
            0.00,
            0.16,
            0.33,
            0.49,
            0.66,
            0.82,
            1.00
        ]

        gradient.cornerRadius = 16

        return gradient
    }()

    lazy private var longPressGesture: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer()

        gesture.minimumPressDuration = 0.25
        gesture.addTarget(self, action: #selector(onLongPress))
        return gesture
    }()

    lazy private var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(onTap))

        return gesture
    }()

    lazy private var gradientPickerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 20
        view.layer.cornerCurve = .continuous
        view.widthAnchor.constraint(equalToConstant: 320).isActive = true
        view.backgroundColor = .black
        view.heightAnchor.constraint(equalToConstant: 320).isActive = true

        view.layer.mask = gradientPickerMask.layer

        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = .zero
        view.layer.shadowOpacity = 0.25
        view.layer.shadowRadius = 8

        view.addSubview(targetView)
        targetView.frame.origin = CGPoint(x: 0, y: 320 - 32)

        return view
    }()

    lazy private var gradientPickerMask: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.frame = CGRect(origin: CGPoint(x: 7, y: 320 - 25), size: CGSize(width: 18, height: 18))
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
        gradient.cornerRadius = 16
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
        gradient.cornerRadius = 16
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
        gradient.cornerRadius = 16
        gradient.cornerCurve = .continuous

        return gradient
    }()

    lazy private var targetView: UIView = {
        let view = UIView()
        view.frame = CGRect(origin: .zero, size: CGSize(width: 32, height: 32))
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 2

        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.25
        view.layer.shadowOffset = .zero
        return view
    }()

    private func coordToColor(position: CGPoint) -> UIColor {
        var normalisedPosition = CGPoint(x: (position.x - 16) / 288.0, y: (position.y - 16.0) / 288.0)

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

    @objc private func onLongPress() {
        switch longPressGesture.state {
        case .began:
            addSubview(gradientPickerView)

            NSLayoutConstraint.activate([
                gradientPickerView.bottomAnchor.constraint(equalTo: bottomAnchor),
                gradientPickerView.leftAnchor.constraint(equalTo: leftAnchor),
            ])

            self.layoutIfNeeded()
            gradientPickerView.layer.insertSublayer(gradientPickerLayer, at: 0)

            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut) {
                self.gradientPickerMask.frame.size = CGSize(width: 900, height: 900)
                self.gradientPickerMask.center = CGPoint(x: 16, y: 320 - 16)
                self.gradientPickerMask.layer.cornerRadius = 450
            }

        case .changed:
            let position = longPressGesture.location(in: gradientPickerView)
            let normalizedPosition = CGPoint(
                x: max(16, min(304, position.x)),
                y: max(16, min(304, position.y))
            )

            UIView.animate(withDuration: 0.1) {
                self.targetView.center = normalizedPosition
                self.targetView.backgroundColor = self.coordToColor(position: normalizedPosition)
            }

            break

        case .ended:
            let coordinate = longPressGesture.location(in: gradientPickerView)
            color = coordToColor(position: coordinate)
            onColorCanged(color)

            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                self.gradientPickerMask.frame.size = CGSize(width: 0, height: 0)
                self.gradientPickerMask.center = CGPoint(x: 16, y: 320 - 16)
                self.gradientPickerMask.layer.cornerRadius = 0
            }, completion: { [unowned self] _ in
                targetView.frame.origin = CGPoint(x: 0, y: 320 - 32)
                targetView.backgroundColor = .white

                gradientPickerView.removeFromSuperview()
                gradientPickerView.layer.sublayers?.remove(at: 0)

                NSLayoutConstraint.deactivate([
                    gradientPickerView.bottomAnchor.constraint(equalTo: bottomAnchor),
                    gradientPickerView.leftAnchor.constraint(equalTo: leftAnchor),
                ])
            })

        default:
            break
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        gradientLayer.frame = bounds
    }

    @objc private func onTap() {
        let controller = ColorPickerController()
        controller.modalPresentationStyle = .formSheet
        controller.onFinish = { color in
            self.color = color
            self.onColorCanged(color)
        }
        controller.isModalInPresentation = true
        controller.setColor(color: self.color)

        self.parentViewController!.present(controller, animated: true)
    }

    init(onColorCanged: @escaping (UIColor) -> Void) {
        self.onColorCanged = onColorCanged
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(colorView)
        addSubview(gradientView)

        addGestureRecognizer(longPressGesture)
        addGestureRecognizer(tapGesture)

        NSLayoutConstraint.activate([
            colorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: centerYAnchor),
            colorView.widthAnchor.constraint(equalToConstant: 18),
            colorView.heightAnchor.constraint(equalToConstant: 18),

            gradientView.centerXAnchor.constraint(equalTo: centerXAnchor),
            gradientView.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
