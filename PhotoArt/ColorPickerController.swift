//
//  ColorPickerController.swift
//  PhotoArt
//
//  Created by Rustam Khakhuk on 27.10.2022.
//

import UIKit

class ColorPickerController: UIViewController {
    lazy private var backgroundView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .systemThickMaterialDark))

        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.backgroundColor = .white

        return view
    }()

    lazy private var exitBtn: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.cornerRadius = 16

        btn.backgroundColor = UIColor.gray.withAlphaComponent(0.25)
        btn.addTarget(self, action: #selector(onExit), for: .touchUpInside)
        
        return btn
    }()

    lazy private var titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = .systemFont(ofSize: 17, weight: .semibold)

        lbl.text = "Colors"
        return lbl
    }()

    lazy private var segmentPicker: UISegmentedControl = {
        let segments = UISegmentedControl(items: ["Grid", "Spectrum", "Sliders"])
        segments.translatesAutoresizingMaskIntoConstraints = false
        segments.selectedSegmentIndex = 0

        return segments
    }()

    @objc private func onExit() {
        dismiss(animated: true)
    }

    lazy private var selectedColorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()

    lazy private var separator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white.withAlphaComponent(0.1)
        return view
    }()

    lazy private var opasitySlider: ColorSlider = {
        let slider = ColorSlider()
        slider.title = "OPASITY"

        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()

    override func viewDidLoad() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)

        view.addSubview(backgroundView)
        view.addSubview(exitBtn)
        view.addSubview(titleLabel)
        view.addSubview(segmentPicker)
        view.addSubview(selectedColorView)
        view.addSubview(separator)

        view.addSubview(opasitySlider)

        NSLayoutConstraint.activate([
            backgroundView.leftAnchor.constraint(equalTo: view.leftAnchor),
            backgroundView.rightAnchor.constraint(equalTo: view.rightAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -640),

            exitBtn.widthAnchor.constraint(equalToConstant: 32),
            exitBtn.heightAnchor.constraint(equalToConstant: 32),
            exitBtn.rightAnchor.constraint(equalTo: backgroundView.rightAnchor, constant: -16),
            exitBtn.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 16),

            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 32),

            segmentPicker.leftAnchor.constraint(equalTo: backgroundView.leftAnchor, constant: 16),
            segmentPicker.rightAnchor.constraint(equalTo: backgroundView.rightAnchor, constant: -16),
            segmentPicker.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 58),

            selectedColorView.widthAnchor.constraint(equalToConstant: 82),
            selectedColorView.heightAnchor.constraint(equalToConstant: 82),
            selectedColorView.leftAnchor.constraint(equalTo: backgroundView.leftAnchor, constant: 16),
            selectedColorView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),

            separator.heightAnchor.constraint(equalToConstant: 1),
            separator.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            separator.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            separator.bottomAnchor.constraint(equalTo: selectedColorView.topAnchor, constant: -22),

            opasitySlider.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            opasitySlider.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            opasitySlider.bottomAnchor.constraint(equalTo: separator.topAnchor, constant: -24)
        ])
    }
}
