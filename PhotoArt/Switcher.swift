//
//  Switcher.swift
//  PhotoArt
//
//  Created by Rustam Khakhuk on 12.10.2022.
//

import UIKit

enum SwitcherState {
    case switcher, slider
}

class Switcher: UIView {

    var sliderPosition: CGFloat = 0 {
        didSet {
            sliderPositionConstraint.constant = (bounds.width - 28) * sliderPosition
        }
    }

    var state: SwitcherState = .switcher {
        didSet {
            if state == .switcher {
                tapGesture.isEnabled = true
                slideGesture.isEnabled = false
            } else {
                tapGesture.isEnabled = false
                slideGesture.isEnabled = true
            }

            (backgroundView.layer as! TransformBackgroundLayer).progress = state == .switcher ? 0.0 : 1.0
            (backgroundView.layer as! TransformBackgroundLayer).fillAlpha = state == .switcher ? 0.1 : 0.2

            let anim = CABasicAnimation(keyPath: "progress")
            anim.fromValue = state == .switcher ? 1.0 : 0.0
            anim.toValue = state == .switcher ? 0.0 : 1.0
            anim.timingFunction = .init(name: .easeInEaseOut)
            anim.duration = 0.25

            let anim2 = CABasicAnimation(keyPath: "fillAlpha")
            anim2.fromValue = state == .switcher ? 0.2 : 0.1
            anim2.toValue = state == .switcher ? 0.1 : 0.2
            anim2.timingFunction = .init(name: .easeInEaseOut)
            anim2.duration = 0.25

            backgroundView.layer.add(anim, forKey: "progress")
            backgroundView.layer.add(anim2, forKey: "fillAlpha")

            if state == .switcher {
                backgroundHeightConstraint.constant = 32
                NSLayoutConstraint.deactivate(sliderConstraints)
                NSLayoutConstraint.deactivate([sliderPositionConstraint])
                NSLayoutConstraint.activate(switchConstraints)

                if selection == 0 {
                    NSLayoutConstraint.activate([ leftSelectionConstraint ])
                } else {
                    NSLayoutConstraint.activate([ rightSelectionConstraint ])
                }
            } else {
                backgroundHeightConstraint.constant = 24
                NSLayoutConstraint.deactivate(switchConstraints)
                if selection == 0 {
                    NSLayoutConstraint.deactivate([ leftSelectionConstraint ])
                } else {
                    NSLayoutConstraint.deactivate([ rightSelectionConstraint ])
                }

                NSLayoutConstraint.activate(sliderConstraints)
                NSLayoutConstraint.activate([sliderPositionConstraint])

            }

            UIView.animate(withDuration: 0.25, delay: 0,options: .curveEaseInOut) { [unowned self] in
                firstLabel.alpha = state == .switcher ? 1 : 0
                secondLabel.alpha = state == .switcher ? 1 : 0
                highlightView.backgroundColor = UIColor.white.withAlphaComponent(state == .switcher ? 0.3 : 1)

                layoutIfNeeded()
            }
        }
    }
    
    var firstText: String {
        get {
            return firstLabel.text!
        }

        set {
            firstLabel.text = newValue
        }
    }

    var secondText: String {
        get {
            return secondLabel.text!
        }

        set {
            secondLabel.text = newValue
        }
    }

    var selection: Int = 0 {
        didSet {
            guard oldValue != selection else { return }

            onSelectionChanged(selection)

            if selection == 0 {
                NSLayoutConstraint.activate([ leftSelectionConstraint ])
                NSLayoutConstraint.deactivate([ rightSelectionConstraint ])
            } else {
                NSLayoutConstraint.activate([ rightSelectionConstraint ])
                NSLayoutConstraint.deactivate([ leftSelectionConstraint ])
            }

            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.9) {
                self.layoutIfNeeded()
            }
        }
    }

    lazy private var sliderConstraints = [
        highlightView.widthAnchor.constraint(equalToConstant: 28),
        highlightView.heightAnchor.constraint(equalToConstant: 28),
        highlightView.centerYAnchor.constraint(equalTo: centerYAnchor),
    ]

    lazy private var sliderPositionConstraint = highlightView.leftAnchor.constraint(equalTo: leftAnchor)
    lazy private var backgroundHeightConstraint = backgroundView.heightAnchor.constraint(equalToConstant: 32)


    lazy private var switchConstraints = [
        highlightView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5, constant: -4),
        highlightView.heightAnchor.constraint(equalToConstant: 28),
        highlightView.centerYAnchor.constraint(equalTo: centerYAnchor),
    ]

    private var onSelectionChanged: (Int) -> Void
    private var onSliderChanged: (CGFloat) -> Void

    lazy private var firstLabel: UILabel = {
        let lbl = UILabel(frame: .zero)

        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textColor = .white
        lbl.textAlignment = .center
        lbl.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        
        return lbl
    }()

    lazy private var secondLabel: UILabel = {
        let lbl = UILabel(frame: .zero)

        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textColor = .white
        lbl.textAlignment = .center
        lbl.font = UIFont.systemFont(ofSize: 13, weight: .semibold)

        return lbl
    }()


    lazy private var backgroundView: TransformBackground = {
        let view = TransformBackground()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 32).isActive = true
        return view
    }()

    lazy private var highlightView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 32).isActive = true
        view.layer.cornerRadius = 14

        view.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        return view
    }()

    private var leftSelectionConstraint: NSLayoutConstraint!
    private var rightSelectionConstraint: NSLayoutConstraint!

    lazy private var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(onTap))

        return gesture
    }()

    lazy private var slideGesture: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(onSlide))

        gesture.minimumPressDuration = 0.0
        return gesture
    }()

    @objc private func onTap() {
        selection = tapGesture.location(in: self).x < bounds.width / 2 ? 0 : 1
    }

    @objc private func onSlide() {
        switch slideGesture.state {
        case .began, .changed, .ended:
            let position = (max(14, min(slideGesture.location(in: self).x, bounds.width - 14)) - 14) / (bounds.width - 28)
            sliderPosition = position

            layoutIfNeeded()

            onSliderChanged(position)
            break

        default:
            break
        }
    }

    init(
        onSelectionChanged: @escaping (Int) -> Void,
        onSliderChanged: @escaping (CGFloat) -> Void
    ) {
        self.onSelectionChanged = onSelectionChanged
        self.onSliderChanged = onSliderChanged
        
        super.init(frame: .zero)

        addSubview(backgroundView)
        addSubview(highlightView)
        addSubview(firstLabel)
        addSubview(secondLabel)

        addGestureRecognizer(tapGesture)
        addGestureRecognizer(slideGesture)

        tapGesture.isEnabled = true
        slideGesture.isEnabled = false

        leftSelectionConstraint = highlightView.centerXAnchor.constraint(equalTo: firstLabel.centerXAnchor)
        rightSelectionConstraint = highlightView.centerXAnchor.constraint(equalTo: secondLabel.centerXAnchor)

        NSLayoutConstraint.activate([
            backgroundView.leftAnchor.constraint(equalTo: leftAnchor),
            backgroundView.rightAnchor.constraint(equalTo: rightAnchor),
            backgroundView.centerYAnchor.constraint(equalTo: centerYAnchor),
            backgroundHeightConstraint,

            switchConstraints[0],
            switchConstraints[1],
            switchConstraints[2],
            leftSelectionConstraint,

            firstLabel.leftAnchor.constraint(equalTo: leftAnchor),
            firstLabel.rightAnchor.constraint(equalTo: centerXAnchor),
            firstLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            secondLabel.leftAnchor.constraint(equalTo: centerXAnchor),
            secondLabel.rightAnchor.constraint(equalTo: rightAnchor),
            secondLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class TransformBackground: UIView {
    override class var layerClass: AnyClass {
        return TransformBackgroundLayer.self
    }

    override func draw(_ rect: CGRect) { }

    init() {
        super.init(frame: .zero)
        isOpaque = false

        (layer as! TransformBackgroundLayer).progress = 0
        (layer as! TransformBackgroundLayer).fillAlpha = 0.1
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class TransformBackgroundLayer: CALayer {
    @NSManaged var progress: CGFloat
    @NSManaged var fillAlpha: CGFloat

    override class func needsDisplay(forKey key: String) -> Bool {
        if key == "progress" || key == "fillAlpha" {
            return true
        }
        return super.needsDisplay(forKey: key)
    }


    override func draw(in ctx: CGContext) {
        let radius = bounds.height / 2

        ctx.beginPath()
        ctx.setFillColor(UIColor.white.withAlphaComponent(fillAlpha).cgColor)

        ctx.move(to: CGPoint(x: radius - ((radius - 2) * progress), y: radius - (radius * 2 - (radius - 2) * 2 * progress) / 2))
        ctx.addLine(to: CGPoint(x: bounds.width - radius, y: 0))

        ctx.addArc(center: CGPoint(x: bounds.width - radius, y: radius), radius: radius, startAngle: CGFloat.pi, endAngle: CGFloat.pi / 2, clockwise: false)

        ctx.addLine(to: CGPoint(x: bounds.width - radius, y: radius * 2))
        ctx.addLine(to: CGPoint(x: radius - ((radius - 2) * progress), y: radius + (radius * 2 - (radius - 2) * 2 * progress) / 2))

        ctx.addArc(center: CGPoint(x: radius - ((radius - 2) * progress), y: radius), radius: radius - ((radius - 2) * progress), startAngle: CGFloat.pi / 2, endAngle: -CGFloat.pi / 2, clockwise: false)

        ctx.closePath()
        ctx.fillPath()
    }
}

