//
//  CGSize+Extensions.swift
//  PhotoArt
//
//  Created by Rustam Khakhuk on 16.10.2022.
//

import Foundation

extension CGSize {
    static func +(lp: CGSize, rp: CGSize) -> CGSize {
        return CGSize(width: lp.width + rp.width, height: lp.height + rp.height)
    }

    static func -(lp: CGSize, rp: CGSize) -> CGSize {
        return CGSize(width: lp.width - rp.width, height: lp.height - rp.height)
    }

    static func *(lp: CGSize, rv: CGFloat) -> CGSize {
        return CGSize(width: lp.width * rv, height: lp.height * rv)
    }

    static func *(rv: CGFloat, lp: CGSize) -> CGSize {
        return CGSize(width: lp.width * rv, height: lp.height * rv)
    }

    static func /(lp: CGSize, rv: CGFloat) -> CGSize {
        return CGSize(width: lp.width / rv, height: lp.height / rv)
    }
}
