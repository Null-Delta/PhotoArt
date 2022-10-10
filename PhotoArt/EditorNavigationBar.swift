//
//  EditorNavigationBar.swift
//  PhotoArt
//
//  Created by Rustam Khakhuk on 10.10.2022.
//

import UIKit
import Combine

class EditorNavigationBar: UIView {

    lazy private var undoButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(named: "undo"), for: .normal)
        btn.tintColor = .white

        return btn
    }()

    lazy private var clearAllButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Clear All", for: .normal)
        btn.tintColor = .white

        return btn
    }()

    lazy private var zoomOutButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Zoom Out", for: .normal)
        btn.setImage(UIImage(named: "zoomOut"), for: .normal)
        btn.tintColor = .white

        return btn
    }()

    private var cancellables = Set<AnyCancellable>()

    init() {
        super.init(frame: .zero)

        backgroundColor = .black

        addSubview(undoButton)
        addSubview(zoomOutButton)
        addSubview(clearAllButton)

        NSLayoutConstraint.activate([
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
