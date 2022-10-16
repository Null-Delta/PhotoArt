//
//  PencilTool.swift
//  PhotoArt
//
//  Created by Rustam Khakhuk on 12.10.2022.
//

import UIKit
import PencilKit

class PencilTool: DefaultDrawTool {

    init(onTap: @escaping () -> Void = { }) {
        super.init(tool: PKInkingTool(.pencil, color: .blue, width: 10), onTap: onTap)

        color = .blue
        width = 10


        toolWidthGradient.colors = [
            UIColor.black.withAlphaComponent(0.2).cgColor,
            UIColor.black.withAlphaComponent(0.2).cgColor,
            UIColor.black.withAlphaComponent(0).cgColor,
            UIColor.black.withAlphaComponent(0).cgColor,
            UIColor.black.withAlphaComponent(0.2).cgColor,
            UIColor.black.withAlphaComponent(0.2).cgColor
        ]

        toolWidthGradient.locations = [0, 0.26, 0.29, 0.71, 0.74, 1]

        toolWidthGradient.frame.size.width = 16
        toolWidth.frame.size.width = 16
        toolWidth.frame.origin.x = 1

        setBase(base: .pencilBase)
        setTip(tip: .pencilTip.withRenderingMode(.alwaysTemplate))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
