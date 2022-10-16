//
//  PenTool.swift
//  PhotoArt
//
//  Created by Rustam Khakhuk on 13.10.2022.
//

import UIKit
import PencilKit

class PenTool: DefaultDrawTool {

    init(onTap: @escaping () -> Void = { }) {
        super.init(tool: PKInkingTool(.pen, color: .white, width: 10), onTap: onTap)

        color = .white
        width = 10

        setBase(base: .penBase)
        setTip(tip: .penTip.withRenderingMode(.alwaysTemplate))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
