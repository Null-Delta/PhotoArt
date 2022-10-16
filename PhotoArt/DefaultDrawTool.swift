//
//  DefaultDrawTool.swift
//  PhotoArt
//
//  Created by Rustam Khakhuk on 13.10.2022.
//

import UIKit
import PencilKit

class DefaultDrawTool: DefaultTool, DrawTool {
    var color: UIColor = .white {
        didSet {
            toolTip.tintColor = color
            toolWidth.backgroundColor = color
            currentTool.color = color
        }
    }

    var width: CGFloat = 10 {
        didSet {
            currentTool.width = width
            tool = currentTool

            toolWidth.frame.size.height = width / 2
            toolWidthGradient.frame.size.height = width / 2
            toolWidthGradient.removeAllAnimations()
        }
    }

    var currentTool: PKInkingTool!

    lazy private var toolTip: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.image = .penTip.withRenderingMode(.alwaysTemplate)
        view.tintColor = color
        view.translatesAutoresizingMaskIntoConstraints = false

        view.widthAnchor.constraint(equalToConstant: 18).isActive = true
        return view
    }()

    lazy var toolWidth: UIView = {
        let view = UIView()
        view.backgroundColor = color
        view.layer.cornerRadius = 1

        view.layer.insertSublayer(toolWidthGradient, at: 0)
        return view
    }()

    lazy var toolWidthGradient: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(x: 0, y: 0, width: 16, height: 6)
        gradient.colors = [
            UIColor.black.withAlphaComponent(0.2).cgColor,
            UIColor.black.withAlphaComponent(0.0).cgColor,
            UIColor.black.withAlphaComponent(0.0).cgColor,
            UIColor.black.withAlphaComponent(0.2).cgColor,
        ]
        gradient.type = .axial
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.locations = [0, 0.2, 0.8, 1]
        return gradient
    }()

    func setTip(tip: UIImage) {
        toolTip.image = tip
    }

    init(tool: PKInkingTool, onTap: @escaping () -> Void = { }) {
        super.init(tool: tool, onTap: onTap)

        currentTool = tool

        addSubview(toolTip)
        addSubview(toolWidth)

        toolWidth.frame = CGRect(x: 1, y: 38, width: 16, height: 6)

        NSLayoutConstraint.activate([
            toolTip.leftAnchor.constraint(equalTo: leftAnchor),
            toolTip.rightAnchor.constraint(equalTo: rightAnchor),
            toolTip.topAnchor.constraint(equalTo: topAnchor),
            toolTip.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
