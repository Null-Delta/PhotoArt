//
//  ColorPickerController.swift
//  PhotoArt
//
//  Created by Rustam Khakhuk on 27.10.2022.
//

import UIKit

class ColorPickerController: UIViewController {

    var onFinish: (UIColor) -> Void = { _ in }

    func setColor(color: UIColor) {
        selectedColorView.color = color
    }

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
        btn.setImage(UIImage(systemName: "xmark"), for: .normal)
        btn.tintColor = .white

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
        segments.addTarget(self, action: #selector(onSegmentChanged), for: .valueChanged)

        return segments
    }()

    @objc private func onSegmentChanged() {
        if segmentPicker.selectedSegmentIndex == 0 {
            gridView.isHidden = false
            spectrumView.isHidden = true
            slidersView.isHidden = true
        } else if segmentPicker.selectedSegmentIndex == 2 {
            gridView.isHidden = true
            spectrumView.isHidden = true
            slidersView.isHidden = false
        } else {
            gridView.isHidden = true
            spectrumView.isHidden = false
            slidersView.isHidden = true
        }
    }

    @objc private func onExit() {
        onFinish(selectedColorView.color)
        dismiss(animated: true)
    }

    @objc private func onKeyboardShow(notification: NSNotification) {
        guard let responser = view.firstResponder else { return }
        let location = responser.convert(responser.bounds, to: view)

        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {

            let offset = max(0, (location.maxY + 16) - (view.frame.height - keyboardSize.height))

            print(offset)

            UIView.animate(withDuration: 0.25) { [unowned self] in
                view.frame.origin.y = -offset
            }
        }
    }

    @objc private func onKeyboardHide() {
        UIView.animate(withDuration: 0.25) { [unowned self] in
            view.frame.origin.y = 0
        }
    }

    lazy private var selectedColorView: SelectedColorView = {
        let view = SelectedColorView()
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()

    lazy private var separator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white.withAlphaComponent(0.1)
        return view
    }()

    lazy private var opasitySlider: ColorSlider = {
        let slider = ColorSlider(
            onChange: { [unowned self] value in
                selectedColorView.color = UIColor(red: slidersView.color.r, green: slidersView.color.g, blue: slidersView.color.b, alpha: value)
            }
        )
        
        slider.title = "OPASITY"

        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()

    lazy private var slidersView: ColorSlidersView = {
        let sliders = ColorSlidersView()
        sliders.translatesAutoresizingMaskIntoConstraints = false
        sliders.color = .blue
        sliders.onColorChange = { [unowned self] color in
            gridView.clearSelection()
            spectrumView.clearSelection()
            opasitySlider.startColor = color.withAlphaComponent(0)
            opasitySlider.endColor = color.withAlphaComponent(1)

            selectedColorView.color = UIColor(red: slidersView.color.r, green: slidersView.color.g, blue: slidersView.color.b, alpha: opasitySlider.value)
        }

        return sliders
    }()

    lazy private var gridView: ColorGridView = {
        let grid = ColorGridView()
        grid.translatesAutoresizingMaskIntoConstraints = false

        grid.onColorChange = { [unowned self] color in
            slidersView.color = color
            spectrumView.clearSelection()
            opasitySlider.startColor = color.withAlphaComponent(0)
            opasitySlider.endColor = color.withAlphaComponent(1)
            selectedColorView.color = UIColor(red: slidersView.color.r, green: slidersView.color.g, blue: slidersView.color.b, alpha: opasitySlider.value)
        }

        return grid
    }()

    lazy private var spectrumView: SpectrumView = {
        let specView = SpectrumView()
        specView.onColorChanged = { [unowned self] color in
            gridView.clearSelection()
            slidersView.color = color
            opasitySlider.startColor = color.withAlphaComponent(0)
            opasitySlider.endColor = color.withAlphaComponent(1)
            selectedColorView.color = UIColor(red: slidersView.color.r, green: slidersView.color.g, blue: slidersView.color.b, alpha: opasitySlider.value)
        }

        return specView
    }()

    lazy private var savedColorsController: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 32, height: 32)
        layout.scrollDirection = .horizontal

        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)

        collection.register(SavedColorCell.self, forCellWithReuseIdentifier: "savedColor")

        collection.dataSource = self
        collection.delegate = self

        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.backgroundColor = .clear
        collection.isPagingEnabled = true
        return collection
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        slidersView.layoutIfNeeded()
        opasitySlider.layoutIfNeeded()

        spectrumView.clearSelection()
        gridView.clearSelection()
        slidersView.color = UIColor(red: selectedColorView.color.r, green: selectedColorView.color.g, blue: selectedColorView.color.b, alpha: 1)
        opasitySlider.value = selectedColorView.color.a
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let spacing = (savedColorsController.bounds.width - 32 * 6) / 6
        (savedColorsController.collectionViewLayout as! UICollectionViewFlowLayout).minimumLineSpacing = spacing
        (savedColorsController.collectionViewLayout as! UICollectionViewFlowLayout).sectionInset = UIEdgeInsets(top: 0, left: spacing / 2, bottom: 0, right: spacing / 2)
    }

    override func viewDidLoad() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)

        view.addSubview(backgroundView)
        view.addSubview(exitBtn)
        view.addSubview(titleLabel)
        view.addSubview(segmentPicker)
        view.addSubview(selectedColorView)
        view.addSubview(separator)

        view.addSubview(opasitySlider)

        view.addSubview(slidersView)
        view.addSubview(gridView)
        view.addSubview(spectrumView)

        view.addSubview(savedColorsController)

        slidersView.isHidden = true
        spectrumView.isHidden = true

        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardShow), name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)

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
            opasitySlider.bottomAnchor.constraint(equalTo: separator.topAnchor, constant: -24),

            slidersView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 110),
            slidersView.leftAnchor.constraint(equalTo: backgroundView.leftAnchor, constant: 16),
            slidersView.rightAnchor.constraint(equalTo: backgroundView.rightAnchor, constant: -16),

            gridView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 110),
            gridView.leftAnchor.constraint(equalTo: backgroundView.leftAnchor, constant: 16),
            gridView.rightAnchor.constraint(equalTo: backgroundView.rightAnchor, constant: -16),
            gridView.heightAnchor.constraint(equalTo: gridView.widthAnchor, multiplier: 10.0 / 12.0),

            spectrumView.topAnchor.constraint(equalTo: gridView.topAnchor),
            spectrumView.leftAnchor.constraint(equalTo: gridView.leftAnchor),
            spectrumView.rightAnchor.constraint(equalTo: gridView.rightAnchor),
            spectrumView.bottomAnchor.constraint(equalTo: gridView.bottomAnchor),

            savedColorsController.leftAnchor.constraint(equalTo: selectedColorView.rightAnchor, constant: 16),
            savedColorsController.topAnchor.constraint(equalTo: selectedColorView.topAnchor, constant: 0),
            savedColorsController.rightAnchor.constraint(equalTo: backgroundView.rightAnchor, constant: -16),
            savedColorsController.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)

        ])
    }
}

extension ColorPickerController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 100
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "savedColor", for: indexPath) as! SavedColorCell
        cell.color = .red

        cell.select = selectedColorView.color == cell.color
        return cell
    }
}

extension ColorPickerController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! SavedColorCell

        self.setColor(color: cell.color)
        cell.select = true
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? SavedColorCell else { return }
        cell.select = false
    }
}
