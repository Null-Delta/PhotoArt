//
//  EditorNavigationBar.swift
//  PhotoArt
//
//  Created by Rustam Khakhuk on 10.10.2022.
//

import UIKit
import Combine
import PencilKit

class EditorNavigationBar: UIView {

    var isZoomOutEnabled: Bool {
        get {
            return zoomOutButton.alpha != 0
        }

        set {
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn) {
                self.zoomOutButton.alpha = newValue ? 1 : 0
                self.zoomOutButton.transform = CGAffineTransform(scaleX: newValue ? 1 : 0.5, y: newValue ? 1 : 0.5)
            }
        }
    }

    var isUndoEnabled: Bool {
        get {
            return undoButton.isEnabled
        }
        set {
            undoButton.isEnabled = newValue
        }
    }

    var isClearEnabled: Bool {
        get {
            return clearAllButton.isEnabled
        }
        set {
            clearAllButton.isEnabled = newValue
        }
    }

    private var onZoomOut: () -> () = { }
    private var onUndo: () -> () = { }
    private var onClearAll: () -> () = { }

    lazy private var blurView: UIView = {
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterial))
        blur.translatesAutoresizingMaskIntoConstraints = false
        blur.clearBlur()

        return blur
    }()

    lazy private var gradientView: UIView = {
        let view = UIView()

        view.layer.addSublayer(gradient)
        return view
    }()

    lazy private var gradient: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        gradient.colors = [
            UIColor.black.withAlphaComponent(0.5).cgColor,
            UIColor.black.withAlphaComponent(0.5).cgColor,
            UIColor.black.withAlphaComponent(0.0).cgColor,
        ]
        gradient.type = .axial

        return gradient
    }()

    lazy private var gradientMask: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        gradient.colors = [
            UIColor.black.withAlphaComponent(1).cgColor,
            UIColor.black.withAlphaComponent(1).cgColor,
            UIColor.black.withAlphaComponent(0.0).cgColor,
        ]
        gradient.type = .axial

        return gradient
    }()

    lazy private var undoButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(named: "undo"), for: .normal)
        btn.tintColor = .white
        btn.isEnabled = false

        btn.addTarget(self, action: #selector(undoClick), for: .touchUpInside)

        return btn
    }()

    lazy private var clearAllButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Clear All", for: .normal)
        btn.tintColor = .white
        btn.isEnabled = false

        btn.addTarget(self, action: #selector(clearAllClick), for: .touchUpInside)

        return btn
    }()

    lazy private var zoomOutButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Zoom Out", for: .normal)
        btn.setImage(UIImage(named: "zoomOut"), for: .normal)
        btn.tintColor = .white

        btn.alpha = 0
        btn.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)

        btn.addTarget(self, action: #selector(zoomOutClick), for: .touchUpInside)

        return btn
    }()

    private var cancellables = Set<AnyCancellable>()

    override func layoutSubviews() {
        super.layoutSubviews()

        gradient.frame = CGRect(origin: .zero, size: CGSize(width: bounds.width, height: bounds.height + 24))
        gradientMask.frame = CGRect(origin: .zero, size: CGSize(width: bounds.width, height: bounds.height + 24))

        blurView.layer.mask = gradientMask
    }

    @objc private func zoomOutClick() {
        onZoomOut()
    }

    @objc private func undoClick() {
        onUndo()
    }

    @objc private func clearAllClick() {
        onClearAll()
    }

    init(
        onZoomOut: @escaping () -> () = { },
        onUndo: @escaping () -> () = { },
        onClearAll: @escaping () -> () = { }
    ) {
        super.init(frame: .zero)

        self.onZoomOut = onZoomOut
        self.onUndo = onUndo
        self.onClearAll = onClearAll

        addSubview(gradientView)
        addSubview(blurView)

        addSubview(undoButton)
        addSubview(zoomOutButton)
        addSubview(clearAllButton)

        NSLayoutConstraint.activate([
            gradientView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            gradientView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 24),
            gradientView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0),
            gradientView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0),

            blurView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 24),
            blurView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0),
            blurView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0),

            undoButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            undoButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 12),
            undoButton.widthAnchor.constraint(equalToConstant: 24),
            undoButton.heightAnchor.constraint(equalToConstant: 24),

            zoomOutButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            zoomOutButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            zoomOutButton.heightAnchor.constraint(equalToConstant: 24),

            clearAllButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            clearAllButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -12),
            clearAllButton.heightAnchor.constraint(equalToConstant: 24),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
