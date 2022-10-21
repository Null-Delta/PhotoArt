//
//  BeizerLine.swift
//  PhotoArt
//
//  Created by Rustam Khakhuk on 20.10.2022.
//

import Foundation
import MetalKit

struct BeizerSpline {
    var startPoint: SIMD2<Float>
    var endPoint: SIMD2<Float>

    var p1: SIMD2<Float>
    var p2: SIMD2<Float>

    var startSize: Float
    var endSize: Float

    var color: SIMD4<Float>
}
