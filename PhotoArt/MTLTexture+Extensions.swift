//
//  MTLTexture+Extensions.swift
//  PhotoArt
//
//  Created by Rustam Khakhuk on 11.10.2022.
//

import UIKit
import Metal
import Accelerate

extension MTLTexture {
    func toCGImage() -> CGImage? {
        let bytesPerPixel = 4
        let bytesPerRow = self.width * bytesPerPixel

        let data = UnsafeMutableRawPointer.allocate(byteCount: bytesPerRow * height, alignment: bytesPerPixel)
        defer {
            data.deallocate()
        }

        let region = MTLRegionMake2D(0, 0, self.width, self.height)
        getBytes(data, bytesPerRow: bytesPerRow, from: region, mipmapLevel: 0)
        let bitmapInfo = CGBitmapInfo.byteOrder32Big.union(CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue))

        var buffer = vImage_Buffer(data: data, height: UInt(height), width: UInt(width), rowBytes: bytesPerRow)
        var map: [UInt8] = [0, 1, 2, 3]

        if pixelFormat == .bgra8Unorm {
            map = [2, 1, 0, 3]
        }

        vImagePermuteChannels_ARGB8888(&buffer, &buffer, map, vImage_Flags(kvImageDoNotTile))

        let bitsPerComponent = 8
        let colorSpace = CGColorSpaceCreateDeviceRGB()

        let context = CGContext(data: data, width: self.width, height: self.height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        guard let dstImage = context!.makeImage() else { return nil }
        return dstImage
    }

    func toUIImage() -> UIImage? {
        guard let cgImage = self.toCGImage() else {
            return nil
        }

        let image = UIImage(cgImage: cgImage, scale: .zero, orientation: .up)
        return image
    }
}
