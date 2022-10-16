//
//  UIColor+Extensions.swift
//  PhotoArt
//
//  Created by Rustam Khakhuk on 12.10.2022.
//

import UIKit

public extension UIColor {
    var r: CGFloat {
        return CIColor(color: self).red
    }
    var g: CGFloat {
        return CIColor(color: self).green
    }
    var b: CGFloat {
        return CIColor(color: self).blue
    }
    var a: CGFloat {
        return CIColor(color: self).alpha
    }

    var hex: String {
        return String(format: "#%06x", (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0)
    }

    static func between(from: UIColor, to: UIColor, value: CGFloat) -> UIColor {
        let redDifference = to.r - from.r
        let greenDifference = to.g - from.g
        let blueDifference = to.b - from.b
        let alphaDifference = to.a - from.a

        return UIColor(
            red: from.r + redDifference * value,
            green: from.g + greenDifference * value,
            blue: from.b + blueDifference * value,
            alpha: from.a + alphaDifference * value
        )
    }

    static func between(gradient: [UIColor], value: CGFloat) -> UIColor {
        let stepWidth = 1.0 / CGFloat(gradient.count - 1)
        let colorIndex = Int(floor(value / stepWidth))

        if value >= 1 { return gradient[gradient.count - 1] }

        return UIColor.between(from: gradient[colorIndex], to: gradient[colorIndex + 1], value: (value - stepWidth * CGFloat(colorIndex)) / stepWidth)
    }

    convenience init?(hex: String) {
        let r, g, b: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    b = CGFloat((hexNumber & 0x000000ff) >> 0) / 255

                    self.init(red: r, green: g, blue: b, alpha: 1)
                    return
                }
            }
        }

        return nil
    }
}

public extension UIColor {
    static var accent = UIColor(named: "accent")
}
