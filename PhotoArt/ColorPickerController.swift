//
//  ColorPickerController.swift
//  PhotoArt
//
//  Created by Rustam Khakhuk on 27.10.2022.
//

import UIKit

class ColorPickerController: UIViewController {

    var onFinish: (UIColor) -> Void = { _ in }

    var savedColors: [UIColor] = []

    func setColor(color: UIColor) {
        selectedColorView.color = color
        savedColorsController.reloadData()
    }

    lazy private var backgroundView: UIView = {
        let view = UIView()

        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.backgroundColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1)

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
        UserDefaults.standard.set(savedColors.map { $0.hex }, forKey: "savedColors")
        onFinish(selectedColorView.color)
        dismiss(animated: true)
    }

    @objc private func onKeyboardShow(notification: NSNotification) {
        guard let responser = view.firstResponder else { return }
        let location = responser.convert(responser.bounds, to: view)

        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            print("open")
            let offset = min(0, (view.frame.height - keyboardSize.height) - (location.maxY + 16))

            UIView.animate(withDuration: 0.25) { [unowned self] in
                backgroundView.transform = .identity.translatedBy(x: 0, y: offset)
            }
        }
    }

    @objc private func onKeyboardHide() {
        UIView.animate(withDuration: 0.25) { [unowned self] in
            backgroundView.transform = .identity
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
                savedColorsController.reloadData()
            }
        )

        slider.maxValue = 100
        
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
            savedColorsController.reloadData()
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
            savedColorsController.reloadData()
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
            savedColorsController.reloadData()
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
        opasitySlider.startColor = selectedColorView.color.withAlphaComponent(0)
        opasitySlider.endColor = selectedColorView.color.withAlphaComponent(1)
        savedColorsController.reloadData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let spacing = (savedColorsController.bounds.width - 32 * 6) / 6
        (savedColorsController.collectionViewLayout as! UICollectionViewFlowLayout).minimumLineSpacing = spacing
        (savedColorsController.collectionViewLayout as! UICollectionViewFlowLayout).sectionInset = UIEdgeInsets(top: 0, left: spacing / 2, bottom: 0, right: spacing / 2)
    }

    override func viewDidLoad() {

        savedColors = UserDefaults.standard.array(forKey: "savedColors")?.compactMap { UIColor(hex: $0 as! String ) } ?? []

        view.addSubview(backgroundView)
        backgroundView.addSubview(exitBtn)
        backgroundView.addSubview(titleLabel)
        backgroundView.addSubview(segmentPicker)
        backgroundView.addSubview(selectedColorView)
        backgroundView.addSubview(separator)

        backgroundView.addSubview(opasitySlider)

        backgroundView.addSubview(slidersView)
        backgroundView.addSubview(gridView)
        backgroundView.addSubview(spectrumView)

        backgroundView.addSubview(savedColorsController)

        slidersView.isHidden = true
        spectrumView.isHidden = true

        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardShow), name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
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

            titleLabel.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 32),

            segmentPicker.leftAnchor.constraint(equalTo: backgroundView.leftAnchor, constant: 16),
            segmentPicker.rightAnchor.constraint(equalTo: backgroundView.rightAnchor, constant: -16),
            segmentPicker.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 58),

            selectedColorView.widthAnchor.constraint(equalToConstant: 82),
            selectedColorView.heightAnchor.constraint(equalToConstant: 82),
            selectedColorView.leftAnchor.constraint(equalTo: backgroundView.leftAnchor, constant: 16),
            selectedColorView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),

            separator.heightAnchor.constraint(equalToConstant: 1),
            separator.leftAnchor.constraint(equalTo: backgroundView.leftAnchor, constant: 16),
            separator.rightAnchor.constraint(equalTo: backgroundView.rightAnchor, constant: -16),
            separator.bottomAnchor.constraint(equalTo: selectedColorView.topAnchor, constant: -22),

            opasitySlider.leftAnchor.constraint(equalTo: backgroundView.leftAnchor, constant: 16),
            opasitySlider.rightAnchor.constraint(equalTo: backgroundView.rightAnchor, constant: -16),
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
        return savedColors.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "savedColor", for: indexPath) as! SavedColorCell
        
        cell.isAdditive = indexPath.item == savedColors.count

        if !cell.isAdditive {
            cell.color = savedColors[indexPath.item]
            cell.select = selectedColorView.color == cell.color
        } else {
            cell.select = false
            cell.color = .clear
        }

        cell.onLongPress = { [unowned self] in
            guard let index = collectionView.indexPath(for: cell) else { return }
            savedColors.remove(at: index.item)
            collectionView.deleteItems(at: [index])
        }

        return cell
    }
}

extension ColorPickerController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if indexPath.item == savedColors.count {
            savedColors.append(selectedColorView.color)
            collectionView.insertItems(at: [indexPath])
        } else {
            let cell = collectionView.cellForItem(at: indexPath) as! SavedColorCell

            self.setColor(color: cell.color)
            spectrumView.clearSelection()
            gridView.clearSelection()
            slidersView.color = UIColor(red: selectedColorView.color.r, green: selectedColorView.color.g, blue: selectedColorView.color.b, alpha: 1)
            opasitySlider.value = selectedColorView.color.a
            opasitySlider.startColor = selectedColorView.color.withAlphaComponent(0)
            opasitySlider.endColor = selectedColorView.color.withAlphaComponent(1)

            collectionView.reloadData()
        }
    }

}
