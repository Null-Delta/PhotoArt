//
//  CGPoint+Extensions.swift
//  PhotoArt
//
//  Created by Rustam Khakhuk on 10.10.2022.
//

import Foundation

extension CGPoint {
    static func +(lp: CGPoint, rp: CGPoint) -> CGPoint {
        return CGPoint(x: lp.x + rp.x, y: lp.y + rp.y)
    }

    static func -(lp: CGPoint, rp: CGPoint) -> CGPoint {
        return CGPoint(x: lp.x - rp.x, y: lp.y - rp.y)
    }

    static func *(lp: CGPoint, rv: CGFloat) -> CGPoint {
        return CGPoint(x: lp.x * rv, y: lp.y * rv)
    }

    static func *(rv: CGFloat, lp: CGPoint) -> CGPoint {
        return CGPoint(x: lp.x * rv, y: lp.y * rv)
    }

    static func /(lp: CGPoint, rv: CGFloat) -> CGPoint {
        return CGPoint(x: lp.x / rv, y: lp.y / rv)
    }
}
