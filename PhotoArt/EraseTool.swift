//
//  EraseTool.swift
//  PhotoArt
//
//  Created by Rustam Khakhuk on 13.10.2022.
//

import UIKit
import PencilKit

class EraseTool: DefaultTool {
    
    init(onTap: @escaping () -> Void = { }) {
        super.init(tool: PKEraserTool(.bitmap), onTap: onTap)
        
        setBase(base: .eraser)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
