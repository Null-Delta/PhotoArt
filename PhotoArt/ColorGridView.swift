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

        array.append(UIColor(hex: "#00374A")!)
        array.append(UIColor(hex: "#011D57")!)
        array.append(UIColor(hex: "#11053B")!)
        array.append(UIColor(hex: "#2E063D")!)
        array.append(UIColor(hex: "#3C071B")!)
        array.append(UIColor(hex: "#5C0701")!)
        array.append(UIColor(hex: "#5A1C00")!)
        array.append(UIColor(hex: "#583300")!)
        array.append(UIColor(hex: "#563D00")!)
        array.append(UIColor(hex: "#666100")!)
        array.append(UIColor(hex: "#4F5504")!)
        array.append(UIColor(hex: "#263E0F")!)

        array.append(UIColor(hex: "#004D65")!)
        array.append(UIColor(hex: "#012F7B")!)
        array.append(UIColor(hex: "#1A0A52")!)
        array.append(UIColor(hex: "#450D59")!)
        array.append(UIColor(hex: "#551029")!)
        array.append(UIColor(hex: "#831100")!)
        array.append(UIColor(hex: "#7B2900")!)
        array.append(UIColor(hex: "#7A4A00")!)
        array.append(UIColor(hex: "#785800")!)
        array.append(UIColor(hex: "#8D8602")!)
        array.append(UIColor(hex: "#6F760A")!)
        array.append(UIColor(hex: "#38571A")!)

        array.append(UIColor(hex: "#016E8F")!)
        array.append(UIColor(hex: "#0042A9")!)
        array.append(UIColor(hex: "#2C0977")!)
        array.append(UIColor(hex: "#61187C")!)
        array.append(UIColor(hex: "#791A3D")!)
        array.append(UIColor(hex: "#B51A00")!)
        array.append(UIColor(hex: "#AD3E00")!)
        array.append(UIColor(hex: "#A96800")!)
        array.append(UIColor(hex: "#A67B01")!)
        array.append(UIColor(hex: "#C4BC00")!)
        array.append(UIColor(hex: "#9BA50E")!)
        array.append(UIColor(hex: "#4E7A27")!)

        array.append(UIColor(hex: "#008CB4")!)
        array.append(UIColor(hex: "#0056D6")!)
        array.append(UIColor(hex: "#371A94")!)
        array.append(UIColor(hex: "#7A219E")!)
        array.append(UIColor(hex: "#99244F")!)
        array.append(UIColor(hex: "#E22400")!)
        array.append(UIColor(hex: "#DA5100")!)
        array.append(UIColor(hex: "#D38301")!)
        array.append(UIColor(hex: "#D19D01")!)
        array.append(UIColor(hex: "#F5EC00")!)
        array.append(UIColor(hex: "#C3D117")!)
        array.append(UIColor(hex: "#669D34")!)

        array.append(UIColor(hex: "#00A1D8")!)
        array.append(UIColor(hex: "#0061FD")!)
        array.append(UIColor(hex: "#4D22B2")!)
        array.append(UIColor(hex: "#982ABC")!)
        array.append(UIColor(hex: "#B92D5D")!)
        array.append(UIColor(hex: "#FF4015")!)
        array.append(UIColor(hex: "#FF6A00")!)
        array.append(UIColor(hex: "#FFAB01")!)
        array.append(UIColor(hex: "#FCC700")!)
        array.append(UIColor(hex: "#FEFB41")!)
        array.append(UIColor(hex: "#D9EC37")!)
        array.append(UIColor(hex: "#76BB40")!)

        array.append(UIColor(hex: "#01C7FC")!)
        array.append(UIColor(hex: "#3A87FD")!)
        array.append(UIColor(hex: "#5E30EB")!)
        array.append(UIColor(hex: "#BE38F3")!)
        array.append(UIColor(hex: "#E63B7A")!)
        array.append(UIColor(hex: "#FE6250")!)
        array.append(UIColor(hex: "#FE8648")!)
        array.append(UIColor(hex: "#FEB43F")!)
        array.append(UIColor(hex: "#FECB3E")!)
        array.append(UIColor(hex: "#FFF76B")!)
        array.append(UIColor(hex: "#E4EF65")!)
        array.append(UIColor(hex: "#96D35F")!)

        array.append(UIColor(hex: "#52D6FC")!)
        array.append(UIColor(hex: "#74A7FF")!)
        array.append(UIColor(hex: "#864FFD")!)
        array.append(UIColor(hex: "#D357FE")!)
        array.append(UIColor(hex: "#EE719E")!)
        array.append(UIColor(hex: "#FF8C82")!)
        array.append(UIColor(hex: "#FEA57D")!)
        array.append(UIColor(hex: "#FEC777")!)
        array.append(UIColor(hex: "#FED977")!)
        array.append(UIColor(hex: "#FFF994")!)
        array.append(UIColor(hex: "#EAF28F")!)
        array.append(UIColor(hex: "#B1DD8B")!)

        array.append(UIColor(hex: "#93E3FC")!)
        array.append(UIColor(hex: "#A7C6FF")!)
        array.append(UIColor(hex: "#B18CFE")!)
        array.append(UIColor(hex: "#E292FE")!)
        array.append(UIColor(hex: "#F4A4C0")!)
        array.append(UIColor(hex: "#FFB5AF")!)
        array.append(UIColor(hex: "#FFC5AB")!)
        array.append(UIColor(hex: "#FED9A8")!)
        array.append(UIColor(hex: "#FDE4A8")!)
        array.append(UIColor(hex: "#FFFBB9")!)
        array.append(UIColor(hex: "#F1F7B7")!)
        array.append(UIColor(hex: "#CDE8B5")!)

        array.append(UIColor(hex: "#CBF0FF")!)
        array.append(UIColor(hex: "#D2E2FE")!)
        array.append(UIColor(hex: "#D8C9FE")!)
        array.append(UIColor(hex: "#EFCAFE")!)
        array.append(UIColor(hex: "#F9D3E0")!)
        array.append(UIColor(hex: "#FFDAD8")!)
        array.append(UIColor(hex: "#FFE2D6")!)
        array.append(UIColor(hex: "#FEECD4")!)
        array.append(UIColor(hex: "#FEF1D5")!)
        array.append(UIColor(hex: "#FDFBDD")!)
        array.append(UIColor(hex: "#F6FADB")!)
        array.append(UIColor(hex: "#DEEED4")!)

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
