//
//  LassoTool.swift
//  PhotoArt
//
//  Created by Rustam Khakhuk on 13.10.2022.
//

import UIKit
import PencilKit

class LassoTool: DefaultTool {

    init(onTap: @escaping () -> Void = { }) {
        super.init(tool: PKLassoTool(), onTap: onTap)

        setBase(base: .lassoBase)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
