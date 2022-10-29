//
//  UIImage+Extensions.swift
//  PhotoArt
//
//  Created by Rustam Khakhuk on 10.10.2022.
//

import UIKit
import MetalPerformanceShaders

extension UIImage {
    static let undo = UIImage(named: "undo")!
    static let zoomOut = UIImage(named: "zoomOut")!
    static let cancel = UIImage(named: "cancel")!
    static let download = UIImage(named: "download")!
    static let back = UIImage(named: "back")!

    static let penBase = UIImage(named: "pen")!
    static let brushBase = UIImage(named: "brush")!
    static let pencilBase = UIImage(named: "pencil")!
    static let lassoBase = UIImage(named: "lasso")!

    static let penTip = UIImage(named: "penTip")!
    static let brushTip = UIImage(named: "brushTip")!
    static let pencilTip = UIImage(named: "pencilTip")!

    static let eraser = UIImage(named: "eraser")!

    static var background: UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 24, height: 36), true, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()!

        UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1).setFill()
        context.fill([CGRect(x: 0, y: 0, width: 36, height: 36)])

        UIColor.white.withAlphaComponent(0.25).setFill()
        context.fill([
            CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 12, height: 12)),
            CGRect(origin: CGPoint(x: 12, y: 12), size: CGSize(width: 12, height: 12)),
            CGRect(origin: CGPoint(x: 0, y: 24), size: CGSize(width: 12, height: 12)),
        ])

        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return image
    }

    static func merge(images: [UIImage]) -> UIImage {
        return UIGraphicsImageRenderer(size: images[0].size).image(actions: { ctx in
            ctx.cgContext.translateBy(x: images[0].size.width / 2, y: images[0].size.height / 2)
            ctx.cgContext.scaleBy(x: 1, y: -1)
            ctx.cgContext.translateBy(x: -images[0].size.width / 2, y: -images[0].size.height / 2)

            for i in images {
                ctx.cgContext.draw(i.cgImage!, in: CGRect(origin: .zero, size: images[0].size))
            }
        })
    }
    
}
