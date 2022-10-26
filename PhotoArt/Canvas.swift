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

    private var vertexBuffer: MTLBuffer!
    private var k: Float = 0
    var penScale: Float = 1
    var penColor: UIColor = .white

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
        self.clearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)

        //self.framebufferOnly = true
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
            pipelineDescriptor.colorAttachments[0].pixelFormat = self.colorPixelFormat

            // Run with 4x MSAA:
            pipelineDescriptor.sampleCount = 4

            do {
                try pipelineState = device?.makeRenderPipelineState(descriptor: pipelineDescriptor)
            } catch {}
        }
    }

    private var length: Float = 0
    private var points: [CGPoint] = []

    lazy private var gesture: UILongPressGestureRecognizer = {
        let gest = UILongPressGestureRecognizer(target: self, action: #selector(onGesture))
        gest.minimumPressDuration = 0

        return gest
    }()

    private func convert(point: CGPoint) -> CGPoint {
        var result = point// - self.convert(frame.origin, to: nil)
        print(point)
        print(frame.width)
        result.x /= frame.width / 2
        result.x -= 1

        result.y /= frame.width / 2
        result.y -= 1 * CGFloat(k)
        result.y *= -1

        print(result)
        return result
    }

    @objc private func onGesture() {
        switch gesture.state {
        case .began:
            let startPoint = convert(point: gesture.location(in: self))

            points.removeAll()
            points.append(startPoint)

            lines.append(
                BeizerSpline(
                    startPoint: points[0].toSIMD(),
                    endPoint: points[0].toSIMD(),
                    p1: points[0].toSIMD(),
                    p2: points[0].toSIMD(),
                    startSize: 0.05 * penScale,
                    endSize: 0.05 * penScale,
                    color: .init(Float(penColor.r),Float(penColor.g), Float(penColor.b), 1)
                )
            )

            length = 0

        case .changed:
            let newPoint = convert(point: gesture.location(in: self))

            points.append(newPoint)

            if points.count == 2 && lines.count > 0 {
                let midPoint = CGPoint(
                    x: Double((lines.last!.p2.x + Float(points.last!.x))) / 2.0,
                    y: Double((lines.last!.p2.y + Float(points.last!.y))) / 2.0
                )

                lines[lines.count - 1].endPoint = SIMD2<Float>(Float(midPoint.x), Float(midPoint.y))
                points[0] = midPoint

                lines.append(
                    BeizerSpline(
                        startPoint: points[0].toSIMD(),
                        endPoint: points[1].toSIMD(),
                        p1: points[1].toSIMD(),
                        p2: points[0].toSIMD(),
                        startSize: lines[lines.count - 1].endSize,
                        endSize: lines[lines.count - 1].endSize,
                        color: lines[lines.count - 1].color
                    )
                )
            } else if points.count == 3 {
                lines[lines.count - 1].endPoint = points[2].toSIMD()
                lines[lines.count - 1].p1 = points[1].toSIMD()
                lines[lines.count - 1].p2 = points[1].toSIMD()

                length = 0
                length += simd.length((points[0] - points[1]).toSIMD())
                length += simd.length((points[1] - points[2]).toSIMD())

                lines[lines.count - 1].endSize = max(0.05, length / 5) * penScale

            } else if points.count == 4 {
                length = 0
                length += simd.length((points[0] - points[1]).toSIMD())
                length += simd.length((points[1] - points[2]).toSIMD())
                length += simd.length((points[2] - points[3]).toSIMD())

                lines[lines.count - 1].endPoint = points[3].toSIMD()
                lines[lines.count - 1].p1 = points[1].toSIMD()
                lines[lines.count - 1].p2 = points[2].toSIMD()
                lines[lines.count - 1].endSize = max(0.05, length / 5) * penScale

                points.removeAll()
                length = 0
            }

        case .ended:
            
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

        k = Float(frame.height) / Float(frame.width)

        if lines.count > 0 {
            renderEncoder.setVertexBuffer(device.makeBuffer(bytes: lines, length: MemoryLayout<BeizerSpline>.stride * lines.count), offset: 0, index: 0)
            renderEncoder.setVertexBuffer(device.makeBuffer(bytes: &k, length: MemoryLayout<Float>.stride), offset: 0, index: 1)

            renderEncoder.setRenderPipelineState(pipelineState)
            renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 400, instanceCount: lines.count)
        }

        renderEncoder.endEncoding()

        commandBuffer.present(self.currentDrawable!)
        commandBuffer.commit()
    }
}
