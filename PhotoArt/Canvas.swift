//
//  Canvas.swift
//  PhotoArt
//
//  Created by Rustam Khakhuk on 20.10.2022.
//

import Metal
import MetalKit
import UIKit

class Canvas: MTKView {
    private var commandQueue: MTLCommandQueue!
    private var library: MTLLibrary!
    private var pipelineDescriptor = MTLRenderPipelineDescriptor()
    private var pipelineState: MTLRenderPipelineState!

    private var pipelineDebugDescriptor = MTLRenderPipelineDescriptor()
    private var pipelineDebugState: MTLRenderPipelineState!
    private var vertexBuffer: MTLBuffer!
    private var k: Float = 0

    var lines: [BeizerSpline] = [

    ]

    var splineQuality: Int = 200

    override init(frame frameRect: CGRect, device: MTLDevice?) {
        super.init(frame: frameRect, device: device)
        configureWithDevice(device!)

        addGestureRecognizer(gesture)
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        configureWithDevice(MTLCreateSystemDefaultDevice()!)
    }

    private func configureWithDevice(_ device: MTLDevice) {
        self.clearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        //self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.framebufferOnly = true
        self.colorPixelFormat = .bgra8Unorm


        // Run with 4x MSAA:
        self.sampleCount = 4

        self.device = device
    }

    override var device: MTLDevice! {
        didSet {
            super.device = device
            commandQueue = (self.device?.makeCommandQueue())!

            library = device?.makeDefaultLibrary()
            pipelineDescriptor.vertexFunction = library?.makeFunction(name: "bezierVertex")
            pipelineDescriptor.fragmentFunction = library?.makeFunction(name: "bezierFragment")
            pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

            pipelineDebugDescriptor.vertexFunction = library?.makeFunction(name: "bezierDebugVertex")
            pipelineDebugDescriptor.fragmentFunction = library?.makeFunction(name: "bezierDebugFragment")
            pipelineDebugDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

            // Run with 4x MSAA:
            pipelineDescriptor.sampleCount = 4
            pipelineDebugDescriptor.sampleCount = 4

            do {
                try pipelineState = device?.makeRenderPipelineState(descriptor: pipelineDescriptor)
                try pipelineDebugState = device?.makeRenderPipelineState(descriptor: pipelineDebugDescriptor)
            } catch {}
        }
    }

    private var firstPoint: CGPoint = .zero
    private var lastPoint: CGPoint = .zero

    private var length: Float = 0
    private var wasStart: Bool = true

    private var points: [CGPoint] = []

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        var startPoint = touches.first!.location(in: self)
        startPoint.x /= frame.width / 2
        startPoint.x -= 1

        startPoint.y = (startPoint.y - frame.height / 2) / (frame.height / CGFloat(k))
        startPoint.y *= -CGFloat(k)

        points.removeAll()
        points.append(startPoint)
        length = 0
        wasStart = true
    }

    lazy private var gesture: UILongPressGestureRecognizer = {
        let gest = UILongPressGestureRecognizer(target: self, action: #selector(onGesture))
        gest.minimumPressDuration = 0

        return gest
    }()

    @objc private func onGesture() {
        switch gesture.state {
        case .began:
            var startPoint = gesture.location(in: self)
            startPoint.x /= frame.width / 2
            startPoint.x -= 1

            startPoint.y = (startPoint.y - frame.height / 2) / (frame.height / CGFloat(k))
            startPoint.y *= -CGFloat(k)

            points.removeAll()
            points.append(startPoint)

            lines.append(
                BeizerSpline(
                    startPoint: .init(Float(points[0].x), Float(points[0].y)),
                    endPoint: .init(Float(points[0].x), Float(points[0].y)),
                    p1: .init(Float(points[0].x), Float(points[0].y)),
                    p2: .init(Float(points[0].x), Float(points[0].y)),
                    startSize: 0.05,
                    endSize: 0.05,
                    color: .init(Float.random(in: 0...1), Float.random(in: 0...1), Float.random(in: 0...1), 0)
                )
            )

            length = 0
            wasStart = true
            break

        case .changed:
            var newPoint = gesture.location(in: self)
            newPoint.x /= frame.width / 2
            newPoint.x -= 1
            newPoint.y = (newPoint.y - frame.height / 2) / (frame.height / CGFloat(k))
            newPoint.y *= -CGFloat(2)

            points.append(newPoint)

            if points.count == 2 && lines.count > 1 {
                let midPoint = CGPoint(
                    x: Double((lines.last!.p2.x + Float(points.last!.x))) / 2.0,
                    y: Double((lines.last!.p2.y + Float(points.last!.y))) / 2.0
                )

                lines[lines.count - 1].endPoint = SIMD2<Float>(Float(midPoint.x), Float(midPoint.y))
                points[0] = midPoint

            } else if points.count == 4 {
                length += simd.length(.init(Float(points[0].x - points[1].x), Float(points[0].y - points[1].y)))
                length += simd.length(.init(Float(points[1].x - points[2].x), Float(points[1].y - points[2].y)))
                length += simd.length(.init(Float(points[2].x - points[3].x), Float(points[2].y - points[3].y)))

                lines.append(
                    BeizerSpline(
                        startPoint: .init(Float(points[0].x), Float(points[0].y)),
                        endPoint: .init(Float(points[3].x), Float(points[3].y)),
                        p1: .init(Float(points[1].x), Float(points[1].y)),
                        p2: .init(Float(points[2].x), Float(points[2].y)),
                        startSize: lines.last!.endSize,
                        endSize: max(0.05, length / 5),
                        color: lines.last!.color
                    )
                )

                points.removeAll()
                length = 0
            }
            break

        default:
            break
        }
    }

    override func draw(_ rect: CGRect) {
        guard
            let commandBuffer = commandQueue!.makeCommandBuffer(),
            let renderPassDescriptor = self.currentRenderPassDescriptor,
            let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        else { return }


        k = Float(rect.height) / Float(rect.width)

        if lines.count > 0 {
            renderEncoder.setRenderPipelineState(pipelineState)
            renderEncoder.setVertexBuffer(device.makeBuffer(bytes: lines, length: MemoryLayout<BeizerSpline>.stride * lines.count), offset: 0, index: 0)
            renderEncoder.setVertexBuffer(device.makeBuffer(bytes: &k, length: MemoryLayout<Float>.stride), offset: 0, index: 1)

            renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 202, instanceCount: lines.count)
        }

        renderEncoder.endEncoding()

        commandBuffer.present(self.currentDrawable!)
        commandBuffer.commit()
    }
}
