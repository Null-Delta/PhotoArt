//
//  DefaultTool.swift
//  PhotoArt
//
//  Created by Rustam Khakhuk on 13.10.2022.
//

import UIKit
import PencilKit

class DefaultTool: UIView, Tool {
    var tool: PKTool

    var centerXConstraint: NSLayoutConstraint?
    var defaultXConstraint: NSLayoutConstraint?

    var state: ToolState = .normal {
        didSet {
            guard oldValue != state else { return }

            if oldValue == .centerized {
                NSLayoutConstraint.deactivate([ centerXConstraint! ])
                NSLayoutConstraint.activate([ defaultXConstraint! ])
            }

            if state == .centerized {
                NSLayoutConstraint.activate([ centerXConstraint! ])
                NSLayoutConstraint.deactivate([ defaultXConstraint! ])
            } else if state == .normal {
                NSLayoutConstraint.deactivate([ centerXConstraint! ])
                NSLayoutConstraint.activate([ defaultXConstraint! ])
                transform = .identity
            }

        }
    }

    var onTap: () -> Void = { }

    lazy private var toolBase: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.image = .penBase
        view.translatesAutoresizingMaskIntoConstraints = false

        view.widthAnchor.constraint(equalToConstant: 18).isActive = true
        return view
    }()

    lazy private var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tap))

        return gesture
    }()

    @objc private func tap() {
        onTap()
    }

    func hideTool() {
        transform = CGAffineTransform(translationX: 0, y: 32)
        alpha = 0
    }

    func showTool() {
        transform = .identity
        alpha = 1
    }

    func setBase(base: UIImage) {
        toolBase.image = base
    }

    init(tool: PKTool, onTap: @escaping () -> Void = { }) {
        self.onTap = onTap
        self.tool = tool

        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(toolBase)
        addGestureRecognizer(tapGesture)

        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 18),
            heightAnchor.constraint(equalToConstant: 79),

            toolBase.leftAnchor.constraint(equalTo: leftAnchor),
            toolBase.rightAnchor.constraint(equalTo: rightAnchor),
            toolBase.topAnchor.constraint(equalTo: topAnchor),
            toolBase.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
