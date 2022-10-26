//
//  EditMenu.swift
//  PhotoArt
//
//  Created by Rustam Khakhuk on 25.10.2022.
//

import UIKit

struct EditMenuItem {
    var action: () -> ()
    var name: String
}

class EditMenu: UIView {
    var items: [EditMenuItem]

//    lazy private var stack: UIStackView = {
//        let stack = UIStackView(frame: .zero)
//
//    }()

    override init(frame: CGRect) {
        items = []

        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

