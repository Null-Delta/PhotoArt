//
//  ColorSlider.swift
//  PhotoArt
//
//  Created by Rustam Khakhuk on 27.10.2022.
//

import UIKit

class ColorSlider: UIView {
    var startColor: UIColor = .white {
        didSet {
            gradient.colors = [startColor.cgColor, endColor.cgColor]
            gradient.removeAllAnimations()
        }
    }
    
    var endColor: UIColor = .black {
        didSet {
            gradient.colors = [startColor.cgColor, endColor.cgColor]
            gradient.removeAllAnimations()
        }
    }

    var value: CGFloat = 0 {
        didSet {
            toggleConstraint.constant = (background.frame.width - 36) * value + 18
            field.text = "\(Int(maxValue * value))"
            layoutIfNeeded()
        }
    }

    var maxValue: CGFloat = 255

    var postFix: String = ""

    var title: String {
        get {
            return titleLabel.text ?? ""
        }
        set {
            titleLabel.text = newValue
        }
    }

    lazy private var field: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false

        field.font = .systemFont(ofSize: 17, weight: .semibold)
        field.textColor = .white
        field.text = "255"
        field.textAlignment = .center
        field.backgroundColor = .black
        field.layer.cornerRadius = 8

        field.delegate = self
        field.keyboardType = .numberPad

        field.inputAccessoryView = bar
        
        return field
    }()

    lazy private var bar: UIToolbar = {
        let bar = UIToolbar()

        bar.setItems([
            UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(onDone))
        ], animated: false)

        bar.sizeToFit()

        return bar
    }()

    @objc private func onDone() {
        endEditing(true)
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
        view.clipsToBounds = true

        view.backgroundColor = UIColor(patternImage: .background)
        return view
    }()

    lazy private var gradient: CAGradientLayer = {
        let gradient = CAGradientLayer()

        gradient.colors = [UIColor.red.withAlphaComponent(0).cgColor, UIColor.red.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        return gradient
    }()

    lazy private var toggle: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 15
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 3
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false

        return view
    }()

    lazy private var gesture: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(onGesture))
        gesture.minimumPressDuration = 0

        return gesture
    }()

    private var toggleConstraint: NSLayoutConstraint!

    var onChange: (CGFloat) -> () = { _ in }

    @objc private func onGesture() {
        let location = min(max(18, gesture.location(in: background).x), background.frame.width - 18)

        switch gesture.state {
        case .began, .changed:
            value = (location - 18) / (background.frame.width - 36)
            onChange(value)
        default:
            break
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        gradient.frame = background.bounds
        background.layer.addSublayer(gradient)
    }

    init(onChange: @escaping (CGFloat) -> () = { _ in }) {
        self.onChange = onChange

        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false
        addSubview(background)
        addSubview(titleLabel)
        addSubview(toggle)
        addSubview(field)

        background.addGestureRecognizer(gesture)

        toggleConstraint = toggle.centerXAnchor.constraint(equalTo: background.leftAnchor, constant: 18)

        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 4),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),

            background.leftAnchor.constraint(equalTo: leftAnchor),
            background.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            background.heightAnchor.constraint(equalToConstant: 36),
            background.rightAnchor.constraint(equalTo: field.leftAnchor, constant: -12),

            bottomAnchor.constraint(equalTo: background.bottomAnchor),

            toggle.heightAnchor.constraint(equalToConstant: 30),
            toggle.widthAnchor.constraint(equalToConstant: 30),
            toggle.centerYAnchor.constraint(equalTo: background.centerYAnchor),
            toggleConstraint,

            field.rightAnchor.constraint(equalTo: rightAnchor),
            field.widthAnchor.constraint(equalToConstant: 72),
            field.heightAnchor.constraint(equalTo: background.heightAnchor),
            field.centerYAnchor.constraint(equalTo: background.centerYAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension ColorSlider: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        value = min(max(0, CGFloat(Int(textField.text ?? "0") ?? 0) / maxValue), 1)
        onChange(value)
    }
}
