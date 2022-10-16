//
//  Tool.swift
//  PhotoArt
//
//  Created by Rustam Khakhuk on 12.10.2022.
//

import Foundation
import PencilKit

enum ToolState {
    case normal, selected, centerized
}

protocol Tool {
    var state: ToolState { get set }
    var onTap: () -> Void { get set }

    func hideTool()
    func showTool()
}

protocol DrawTool: Tool {
    var color: UIColor { get set }
    var width: CGFloat { get set }
}

protocol EditorTool {

}

extension PKInkingTool: EditorTool { }
extension PKEraserTool: EditorTool { }
