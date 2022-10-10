//
//  Canvas.swift
//  PhotoArt
//
//  Created by Rustam Khakhuk on 09.10.2022.
//

import UIKit
import Metal
import MetalKit
import Combine

struct CanvasState {
    var offset: SIMD4<Float>
    var scale: Float
}

struct Vertex {
    var position: SIMD2<Float>
}

struct TransformState {
    var center: CGPoint
    var scale: CGFloat
    var position: CGPoint
}

class Canvas: MTKView {
    private var queue: MTLCommandQueue!
    private var imagePipeline: MTLRenderPipelineState!

    private var texture: MTLTexture

    private var state: CanvasState
    private var transformState: TransformState = TransformState(center: .zero, scale: 1, position: .zero)

    var scaleK: Float = 0
    var k: Float = 0
    var projectK: Float = 0

    lazy private var transformGesture: UIPinchGestureRecognizer = {
        let gest = UIPinchGestureRecognizer(target: self, action: #selector(onScale))
        gest.delegate = self
        return gest
    }()

    init(image: UIImage) {
        state = CanvasState(offset: [0,0,0,0], scale: 1)
        texture = try! MetalContext.textureLoader.newTexture(cgImage: image.cgImage!)

        super.init(frame: .zero, device: Metal.MTLCreateSystemDefaultDevice()!)

        initPipelines()

        autoResizeDrawable = false
        translatesAutoresizingMaskIntoConstraints = false
        enableSetNeedsDisplay = true
        delegate = self

        queue = device!.makeCommandQueue()!

        addGestureRecognizer(transformGesture)
    }

    private func initPipelines() {
        let lib = device!.makeDefaultLibrary()!

        let layerDescriptor = MTLRenderPipelineDescriptor()
        layerDescriptor.vertexFunction = lib.makeFunction(name: "canvasVertex")!
        layerDescriptor.fragmentFunction = lib.makeFunction(name: "canvasFragment")!
        setDefaultSettings(descriptor: layerDescriptor)

        imagePipeline = try! device!.makeRenderPipelineState(descriptor: layerDescriptor)
    }

    private func setDefaultSettings(descriptor: MTLRenderPipelineDescriptor) {
        descriptor.colorAttachments[ 0 ].pixelFormat = .bgra8Unorm
        descriptor.colorAttachments[ 0 ].isBlendingEnabled = true
        descriptor.colorAttachments[ 0 ].rgbBlendOperation = .add
        descriptor.colorAttachments[ 0 ].alphaBlendOperation = .add
        descriptor.colorAttachments[ 0 ].sourceRGBBlendFactor = .sourceAlpha
        descriptor.colorAttachments[ 0 ].sourceAlphaBlendFactor = .sourceAlpha
        descriptor.colorAttachments[ 0 ].destinationRGBBlendFactor = .oneMinusSourceAlpha
        descriptor.colorAttachments[ 0 ].destinationAlphaBlendFactor = .oneMinusSourceAlpha
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func onScale() {
        if(transformGesture.numberOfTouches == 2) {
            switch transformGesture.state {
            case .began:
                transformState.position = transformGesture.location(in: self) - CGPoint(x: CGFloat(state.offset.x), y: CGFloat(state.offset.y))
                transformState.center.x = transformState.position.x / (CGFloat(texture.width) * CGFloat(state.scale))
                transformState.center.y = transformState.position.y / (CGFloat(texture.height) * CGFloat(state.scale))

                transformGesture.scale = 1

                transformState.scale = CGFloat(state.scale)

            case .changed:
                let normaliseScale = (transformGesture.scale * transformState.scale > 200) ? 200 / transformState.scale : (transformGesture.scale * transformState.scale < 0.01) ? 0.01 / transformState.scale : transformGesture.scale

                let xk = (normaliseScale - 1) * CGFloat(texture.width) * transformState.scale
                let yk = (normaliseScale - 1) * CGFloat(texture.height) * transformState.scale

                state.offset = SIMD4<Float>([
                    Float((transformGesture.location(in: self) - transformState.position - CGPoint(x: transformState.center.x * xk, y: transformState.center.y * yk)).x),
                    Float((transformGesture.location(in: self) - transformState.position - CGPoint(x: transformState.center.x * xk, y: transformState.center.y * yk)).y),
                    0.0,0.0
                ])

                state.scale = Float(transformState.scale * transformGesture.scale)

            default:
                break
            }
        }

        setNeedsDisplay()
    }

}

extension Canvas: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {

    }

    func draw(in view: MTKView) {
        let buffer = queue.makeCommandBuffer()!

        let passDescriptor = view.currentRenderPassDescriptor!

        let components = UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor.components!
        passDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: components[0], green: components[1], blue: components[2], alpha: components[3])

        let encoder = buffer.makeRenderCommandEncoder(descriptor: passDescriptor)!

        let screenWidth = frame.width * UIScreen.main.scale
        let screenHeight = frame.height * UIScreen.main.scale

        scaleK = Float(texture.width) / Float(screenWidth)
        k = Float(screenWidth / screenHeight)
        projectK = Float(texture.height) / Float(texture.width)

        let vertices = [
            Vertex(position: [0,0] * scaleK),
            Vertex(position: [1,0] * scaleK),
            Vertex(position: [0,1 * k * projectK] * scaleK),
            Vertex(position: [1,1 * k * projectK] * scaleK)
        ]

        let vertexBuffer = device!.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<Vertex>.stride, options: [])

        var newState = CanvasState(
            offset: state.offset * Float(UIScreen.main.scale),
            scale: state.scale * Float(UIScreen.main.scale)
        )

        var newState2 = CanvasState(
            offset: [
                state.offset.x * Float(UIScreen.main.scale) / Float(screenWidth),
                state.offset.y * Float(UIScreen.main.scale) / Float(screenHeight),
                0,0
            ],
            scale: state.scale * Float(UIScreen.main.scale)
        )

        var height = Float(CGFloat(texture.height) * CGFloat(newState.scale) / screenHeight)

        encoder.setRenderPipelineState(imagePipeline)

        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)

        encoder.setVertexBuffer(device!.makeBuffer(bytes: &newState2, length: MemoryLayout<CanvasState>.stride, options: []), offset: 0, index: 1)

        encoder.setVertexBuffer(device!.makeBuffer(bytes: &height, length: MemoryLayout<Float>.stride, options: []), offset: 0, index: 2)

        encoder.setFragmentBuffer(device!.makeBuffer(bytes: &newState, length: MemoryLayout<CanvasState>.stride, options: []), offset: 0, index: 0)

        drawLayer(encoder: encoder)

        encoder.endEncoding()

        buffer.present(view.currentDrawable!)
        buffer.commit()
    }

    func drawLayer(encoder: MTLRenderCommandEncoder) {
        let layerVertices = [
            Vertex(position: SIMD2<Float>(0, 0)),
            Vertex(position: SIMD2<Float>(1, 0) * scaleK),
            Vertex(position: SIMD2<Float>(0, 1 * k * projectK) * scaleK),
            Vertex(position: SIMD2<Float>(1, 1 * k * projectK) * scaleK)
        ]

        encoder.setRenderPipelineState(imagePipeline)
        encoder.setVertexBuffer(device!.makeBuffer(bytes: layerVertices, length: MemoryLayout<Vertex>.stride * 4, options: []), offset: 0, index: 0)

        encoder.setFragmentTexture(texture, index: 0)
        encoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
    }

    func centerize() {
        
        state.scale = Float(bounds.size.width / CGFloat(texture.width))
        state.offset.x = (Float(bounds.size.width) - Float(texture.width) * state.scale) / 2.0

        if(texture.width >= texture.height) {
            state.offset.y = (Float(bounds.size.height) - Float(texture.height) * state.scale) / 2.0
        } else {
            state.offset.y = (Float(bounds.size.height) - Float(texture.height) * state.scale) / 2.0
        }
    }
}


extension Canvas: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
