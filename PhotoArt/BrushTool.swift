//
//  BrushTool.swift
//  PhotoArt
//
//  Created by Rustam Khakhuk on 13.10.2022.
//

import UIKit
import PencilKit

class BrushTool: DefaultDrawTool {

    init(onTap: @escaping () -> Void = { }) {
        super.init(tool: PKInkingTool(.marker, color: .yellow, width: 10), onTap: onTap)

        color = .yellow
        width = 10

        setBase(base: .brushBase)
        setTip(tip: .brushTip.withRenderingMode(.alwaysTemplate))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
