//
//  FontSizeSlider.swift
//  PhotoArt
//
//  Created by Rustam Khakhuk on 27.10.2022.
//

import UIKit

class FontSizeSlider: UIView {

    var onChange: (CGFloat) -> () = { _ in }

    lazy private var background: FontSliderBackground = {
        let bg = FontSliderBackground(frame: .zero)
        bg.translatesAutoresizingMaskIntoConstraints = false
        bg.isOpaque = true
        bg.backgroundColor = .clear

        return bg
    }()

    lazy private var toggle: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.backgroundColor = .white

        return view
    }()

    private var togglePosition: NSLayoutConstraint!

    var value: CGFloat {
        get {
            return 1 - (toggle.frame.origin.y) / (208.0)
        }

        set {
            togglePosition.constant = (208.0) * (1 - newValue) + 16
            layoutIfNeeded()
        }
    }

    lazy private var gesture: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(onGesture))
        gesture.minimumPressDuration = 0

        return gesture
    }()

    @objc private func onGesture() {
        let location = gesture.location(in: self).y
        print(location)
        print("here")
        switch gesture.state {
        case .began, .changed:
            togglePosition.constant = max(16, min(224.0, location))
            print(togglePosition.constant)
            layoutIfNeeded()

            onChange(value)
            break

        default:
            break
        }
    }

    init() {
        super.init(frame: .zero)

        addSubview(background)
        addSubview(toggle)

        addGestureRecognizer(gesture)

        togglePosition = toggle.centerYAnchor.constraint(equalTo: topAnchor, constant: 16 + (224.0 * (1 - value)))

        NSLayoutConstraint.activate([
            background.leftAnchor.constraint(equalTo: leftAnchor),
            background.rightAnchor.constraint(equalTo: rightAnchor),
            background.topAnchor.constraint(equalTo: topAnchor),
            background.bottomAnchor.constraint(equalTo: bottomAnchor),

            toggle.centerXAnchor.constraint(equalTo: leftAnchor),
            togglePosition,
            toggle.widthAnchor.constraint(equalToConstant: 32),
            toggle.heightAnchor.constraint(equalToConstant: 32)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class FontSliderBackground: UIView {
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!

        context.move(to: .zero)
        context.addArc(center: CGPoint(x: 0, y: 16), radius: 16, startAngle: CGFloat.pi, endAngle: 0, clockwise: false)
        context.addLine(to: CGPoint(x: 2, y: bounds.height - 2))
        context.addArc(center: CGPoint(x: 0, y: bounds.height - 2), radius: 2, startAngle: 0, endAngle: CGFloat.pi / 2, clockwise: false)
        context.closePath()

        UIColor.white.withAlphaComponent(0.25).setFill()
        context.fillPath()
    }
}
