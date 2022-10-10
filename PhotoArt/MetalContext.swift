//
//  MetalContext.swift
//  PhotoArt
//
//  Created by Rustam Khakhuk on 09.10.2022.
//

import Foundation
import Metal
import MetalKit

open class MetalContext {
    public static let device: MTLDevice = Metal.MTLCreateSystemDefaultDevice()!
    public static let libriary: MTLLibrary = device.makeDefaultLibrary()!
    public static let queue: MTLCommandQueue = device.makeCommandQueue()!
    public static let textureLoader: MTKTextureLoader = MTKTextureLoader(device: device)

    public static func createTexture(size: CGSize, usage: MTLTextureUsage = [.shaderRead, .shaderWrite]) -> MTLTexture {
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm, width: Int(size.width), height: Int(size.height), mipmapped: false)
        textureDescriptor.usage = usage

        return device.makeTexture(descriptor: textureDescriptor)!
    }
}
