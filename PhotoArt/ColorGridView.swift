//
//  ColorGridView.swift
//  PhotoArt
//
//  Created by Rustam Khakhuk on 28.10.2022.
//

import UIKit

class ColorGridView: UIView {

    var selectedColor: UIColor = .red

    func clearSelection() {
        selectedColor = .clear
        collection.reloadData()
    }

    var onColorChange: (UIColor) -> Void = { _ in }

    lazy private var collection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.translatesAutoresizingMaskIntoConstraints = false

        collection.register(GridCell.self, forCellWithReuseIdentifier: "colorCell")
        collection.dataSource = self
        collection.delegate = self
        collection.backgroundColor = .clear
        collection.clipsToBounds = false
        return collection
    }()


    var colors: [UIColor] = {
        var array: [UIColor] = []

        for i in 0..<12 {
            array.append(UIColor(red: CGFloat(12 - i) / 12.0, green: CGFloat(12 - i) / 12.0, blue: CGFloat(12 - i) / 12.0, alpha: 1))
        }

        for i in 0..<9 {
            array.append(UIColor(red: 1, green: 0, blue: 0, alpha: 1))
            array.append(UIColor(red: 1, green: 1, blue: 0, alpha: 1))
            array.append(UIColor(red: 0, green: 1, blue: 0, alpha: 1))
            array.append(UIColor(red: 0, green: 1, blue: 1, alpha: 1))
            array.append(UIColor(red: 0, green: 0, blue: 1, alpha: 1))
            array.append(UIColor(red: 1, green: 0, blue: 1, alpha: 1))
            array.append(UIColor(red: 1, green: 0, blue: 1, alpha: 1))
            array.append(UIColor(red: 1, green: 0, blue: 1, alpha: 1))
            array.append(UIColor(red: 1, green: 0, blue: 1, alpha: 1))
            array.append(UIColor(red: 1, green: 0, blue: 1, alpha: 1))
            array.append(UIColor(red: 1, green: 0, blue: 1, alpha: 1))
            array.append(UIColor(red: 1, green: 0, blue: 1, alpha: 1))
        }

        return array
    }()

    override func layoutSubviews() {
        super.layoutSubviews()

        collection.layoutIfNeeded()
        (collection.collectionViewLayout as! UICollectionViewFlowLayout).itemSize = CGSize(width: collection.frame.width / 12, height: collection.frame.width / 12)
        collection.collectionViewLayout.invalidateLayout()
        collection.reloadData()
    }

    init() {
        super.init(frame: .zero)

        addSubview(collection)

        NSLayoutConstraint.activate([
            collection.topAnchor.constraint(equalTo: topAnchor),
            collection.leftAnchor.constraint(equalTo: leftAnchor),
            collection.rightAnchor.constraint(equalTo: rightAnchor),
            collection.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ColorGridView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        colors.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "colorCell", for: indexPath) as! GridCell
        cell.color = colors[indexPath.item]

        switch indexPath.item {
        case 0:
            cell.cornerMask = .layerMinXMinYCorner
        case 11:
            cell.cornerMask = .layerMaxXMinYCorner
        case 108:
            cell.cornerMask = .layerMinXMaxYCorner
        case 119:
            cell.cornerMask = .layerMaxXMaxYCorner

        default:
            cell.cornerMask = []
        }

        cell.select = selectedColor == colors[indexPath.item]

        return cell
    }
}

extension ColorGridView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! GridCell
        collectionView.bringSubviewToFront(cell)

        cell.select = true
        onColorChange(cell.color)
        selectedColor = cell.color
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! GridCell
        cell.select = false
    }
}

class GridCell: UICollectionViewCell {
    var color: UIColor {
        get {
            return colorView.backgroundColor!
        }
        set {
            colorView.backgroundColor = newValue
        }
    }

    private var colorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        view.layer.maskedCorners = []

        return view
    }()

    private var selectedBorder: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 3
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 3

        return view
    }()

    var cornerMask: CACornerMask = [] {
        didSet {
            colorView.layer.maskedCorners = cornerMask
        }
    }

    var select: Bool {
        get {
            return selectedBorder.alpha == 1
        }

        set {
            selectedBorder.alpha = newValue ? 1 : 0
        }
    }


    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(colorView)
        contentView.addSubview(selectedBorder)
        contentView.backgroundColor = .clear

        NSLayoutConstraint.activate([
            colorView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            colorView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor),
            colorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            selectedBorder.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: -1),
            selectedBorder.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 1),
            selectedBorder.topAnchor.constraint(equalTo: contentView.topAnchor, constant: -1),
            selectedBorder.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 1),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
