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

    func createNewSpline() {
        lines.append(
            BeizerSpline(
                startPoint: .init(Float(points.first!.x), Float(points.first!.y)),
                endPoint: .init(Float(points.first!.x), Float(points.first!.y)),
                p1: .init(Float(points.first!.x), Float(points.first!.y)),
                p2: .init(Float(points.first!.x), Float(points.first!.y)),
                startSize: lines.last!.endSize,
                endSize: lines.last!.endSize,
                color: lines.last!.color
            )
        )

        length = 0
    }

    func updateLastSpline() {
        if wasStart && points.count >= 3 {
            lines.append(
                BeizerSpline(
                    startPoint: .init(Float(points.first!.x), Float(points.first!.y)),
                    endPoint: .init(Float(points.last!.x), Float(points.last!.y)),
                    p1: .init(Float(points.last!.x), Float(points.last!.y)),
                    p2: .init(Float(points.first!.x), Float(points.first!.y)),
                    startSize: 0.1,
                    endSize: 0.1,
                    color: .init(Float.random(in: 0...1), Float.random(in: 0...1), Float.random(in: 0...1), 1)
                )
            )
            _ = points.dropFirst(points.count - 1)
            length = 0

            createNewSpline()

            wasStart = false

            return
        }

        guard !wasStart, points.count > 3, lines.count > 1 else { return }

        let p1 = normalize(
            SIMD2<Float>(
                Float(lines[lines.count - 2].p2.x - lines[lines.count - 2].endPoint.x),
                Float(lines[lines.count - 2].p2.y - lines[lines.count - 2].endPoint.y)
            )
        ) * (length * 0.33)

        let p2 = normalize(
            SIMD2<Float>(
                Float(points[points.count - 1].x - points[points.count - 2].x),
                Float(points[points.count - 1].y - points[points.count - 2].y)
            )
        ) * (length * 0.33)

        lines[lines.count - 1].endPoint = SIMD2<Float>(Float(points.last!.x), Float(points.last!.y))
        lines[lines.count - 1].p1 = lines[lines.count - 1].startPoint - p1
        lines[lines.count - 1].p2 = lines[lines.count - 1].endPoint - p2
        lines[lines.count - 1].endSize = max(0.05, length / 10)
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
                    startPoint: .init(Float(points.first!.x), Float(points.first!.y)),
                    endPoint: .init(Float(points.first!.x), Float(points.first!.y)),
                    p1: .init(Float(points.first!.x), Float(points.first!.y)),
                    p2: .init(Float(points.first!.x), Float(points.first!.y)),
                    startSize: 0.1,
                    endSize: 0.1,
                    color: .init(Float.random(in: 0...1),Float.random(in: 0...1),Float.random(in: 0...1),1)
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

            var deltaLength = simd.length(
                SIMD2<Float>(
                    Float(points.last!.x - newPoint.x),
                    Float(points.last!.y - newPoint.y)
                )
            )

            length += deltaLength

            while(deltaLength > 0.5) {
                let midPoint = CGPoint(x: (points.last!.x + newPoint.x) / 2, y: (points.last!.y + newPoint.y) / 2)
                points.append(midPoint)
                deltaLength /= 2
            }

            points.append(newPoint)

            if points.count >= 8 {
                updateLastSpline()

                points.removeAll()
                points.append(newPoint)

                createNewSpline()
            } else {
                updateLastSpline()
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
