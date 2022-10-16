//
//  CGRect+Extensions.swift
//  PhotoArt
//
//  Created by Rustam Khakhuk on 16.10.2022.
//

import Foundation

extension CGRect {
    var center: CGPoint {
        return CGPoint(
            x: origin.x + size.width / 2,
            y: origin.y + size.height / 2
        )
    }
}
