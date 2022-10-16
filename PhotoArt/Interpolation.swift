//
//  Interpolation.swift
//  PhotoArt
//
//  Created by Rustam Khakhuk on 15.10.2022.
//

import Foundation

func interpolate(from: CGFloat, to: CGFloat, progress: CGFloat) -> CGFloat {
    assert(progress >= 0.0 && progress <= 1.0)
    return from + (to - from) * progress
}

func interpolate(from: CGPoint, to: CGPoint, progress: CGFloat) -> CGPoint {
    assert(progress >= 0.0 && progress <= 1.0)
    let x = interpolate(from: from.x, to: to.x, progress: progress)
    let y = interpolate(from: from.y, to: to.y, progress: progress)
    return CGPoint(x: x, y: y)
}

func interpolate(from: CGSize, to: CGSize, progress: CGFloat) -> CGSize {
    assert(progress >= 0.0 && progress <= 1.0)
    let width = interpolate(from: from.width, to: to.width, progress: progress)
    let height = interpolate(from: from.height, to: to.height, progress: progress)
    return CGSize(width: width, height: height)
}

func interpolate(from: CGRect, to: CGRect, progress: CGFloat) -> CGRect {
    assert(progress >= 0.0 && progress <= 1.0)
    let origin = interpolate(from: from.origin, to: to.origin, progress: progress)
    let size = interpolate(from: from.size, to: to.size, progress: progress)
    return CGRect(origin: origin, size: size)
}
