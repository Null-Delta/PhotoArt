//
//  TextView.swift
//  PhotoArt
//
//  Created by Rustam Khakhuk on 23.10.2022.
//

import UIKit

private enum drawDirection {
    case left, right, top, down
}

enum TextStyle {
    case normal, outlined, background, transparent

    static var random: TextStyle {
        let rnd = Int.random(in: 0..<4)
        switch rnd {
        case 0:
            return .normal
        case 1:
            return .outlined
        case 2:
            return .background
        default:
            return .transparent
        }
    }
}

extension NSTextAlignment {
    static var random: NSTextAlignment {
        switch Int.random(in: 0..<3) {
        case 0:
            return .left
        case 1:
            return .center
        default:
            return .right
        }
    }
}

enum TransformState {
    case moving, scaling, nothing
}

struct Text {
    var id: String = UUID().uuidString
    var text: String
    var style: TextStyle = .normal
    var alignment: NSTextAlignment = .left
    var color: UIColor = .white
    var font: UIFont = UIFont(name: "Arial", size: 48)!
    var scale: CGFloat = 1
    var rotation: CGFloat = 0
    var center: CGPoint
}

class TextView: UIView {
    var texts: [Text] = [ ]

    var text: Text!
    private var lineWidths: [CGFloat] = []
    private var lines: [String] = []
    private var lineHeight: CGFloat = 0
    private var textWidth: CGFloat = 0
    private var textHeight: CGFloat = 0
    private var paragraphStyle: NSMutableParagraphStyle!
    private var attributes: [NSAttributedString.Key: Any]!
    private var sizePoint: CGFloat = 8.0

    var selectedText: Int? = 0

    private(set) var firstTransformPoint: CGPoint?
    private(set) var secondTransformPoint: CGPoint?

    var state: TransformState = .nothing

    func isInCurrentRect(point: CGPoint) -> Bool {
        guard
            let selectedText = selectedText
        else { return false }

        setup(with: texts[selectedText])

        let length = sqrt(pow(point.x - text.center.x, 2) + pow(point.y - text.center.y, 2))

        let newPoint = text.center + CGPoint(
            x: length * (cos(-text.rotation) - sin(-text.rotation)),
            y: length * (cos(-text.rotation) + sin(-text.rotation))
        )

        let rect = CGRect(
            x: -(textWidth * text.scale / 2) - 12 + text.center.x,
            y: -(textHeight * text.scale / 2) - 12 + text.center.y,
            width: textWidth * text.scale + 24,
            height: textHeight * text.scale + 24
        )

        return rect.contains(newPoint)
    }

    func findSelectedText(in point: CGPoint) -> Int? {
        for textIndex in 0..<texts.count {
            setup(with: texts[textIndex])

            let rect = CGRect(
                x: -(textWidth * text.scale / 2) - 12 + text.center.x,
                y: -(textHeight * text.scale / 2) - 12 + text.center.y,
                width: textWidth * text.scale + 24,
                height: textHeight * text.scale + 24
            )

            let length = sqrt(pow(point.x - text.center.x, 2) + pow(point.y - text.center.y, 2))

            let newPoint = text.center + CGPoint(
                x: length * (cos(-text.rotation) + sin(-text.rotation)),
                y: length * (cos(-text.rotation) - sin(-text.rotation))
            )

            print(point - text.center, newPoint - text.center)

            if rect.contains(newPoint) {
                firstTransformPoint = text.center + CGPoint(x: cos(text.rotation), y: sin(text.rotation)) * (textWidth * text.scale / 2 + 12)
                secondTransformPoint = text.center - CGPoint(x: cos(text.rotation), y: sin(text.rotation)) * (textWidth * text.scale / 2 + 12)

                return textIndex
            }
        }

        return nil
    }

    private func lineRect(line: Int) -> CGRect {
        switch text.alignment {
        case .left:
            return CGRect(x: 0 - textWidth / 2, y: lineHeight * CGFloat(line) - textHeight / 2, width: lineWidths[line] * sizePoint, height: lineHeight)
        case .center:
            return CGRect(x: (textWidth - lineWidths[line] * sizePoint - textWidth) / 2, y: lineHeight * CGFloat(line) - textHeight / 2, width: lineWidths[line] * sizePoint, height: lineHeight)
        default:
            return CGRect(x: textWidth - lineWidths[line] * sizePoint - textWidth / 2, y: lineHeight * CGFloat(line) - textHeight / 2, width: lineWidths[line] * sizePoint, height: lineHeight)
        }
    }

    private func drawArc(
        in ctx: CGContext,
        lineIndex: Int,
        corner: (drawDirection, drawDirection),
        isIn: Bool,
        isReverse: Bool,
        radius: CGFloat = 8.0
    ) {
        var arcCenter: CGPoint = .zero
        var startAngle: CGFloat = 0
        var endAngle: CGFloat = 0
        var isClockwise: Bool = false

        // calculate center
        switch corner {
        case (.left, .top):
            if isIn {
                arcCenter = CGPoint(
                    x: lineRect(line: lineIndex).minX + radius / 2,
                    y: lineRect(line: lineIndex).minY + radius / 2
                )
            } else {
                arcCenter = CGPoint(
                    x: lineRect(line: lineIndex).minX - radius / 2,
                    y: lineRect(line: lineIndex).minY + radius / 2
                )
            }

        case (.right, .top):
            if isIn {
                arcCenter = CGPoint(
                    x: lineRect(line: lineIndex).maxX - radius / 2,
                    y: lineRect(line: lineIndex).minY + radius / 2
                )
            } else {
                arcCenter = CGPoint(
                    x: lineRect(line: lineIndex).maxX + radius / 2,
                    y: lineRect(line: lineIndex).minY + radius / 2
                )
            }

        case (.right, .down):
            if isIn {
                arcCenter = CGPoint(
                    x: lineRect(line: lineIndex).maxX - radius / 2,
                    y: lineRect(line: lineIndex).maxY - radius / 2
                )
            } else {
                arcCenter = CGPoint(
                    x: lineRect(line: lineIndex).maxX + radius / 2,
                    y: lineRect(line: lineIndex).maxY - radius / 2
                )
            }

        case (.left, .down):
            if isIn {
                arcCenter = CGPoint(
                    x: lineRect(line: lineIndex).minX + radius / 2,
                    y: lineRect(line: lineIndex).maxY - radius / 2
                )
            } else {
                arcCenter = CGPoint(
                    x: lineRect(line: lineIndex).minX - radius / 2,
                    y: lineRect(line: lineIndex).maxY - radius / 2
                )
            }

        default:
            break
        }

        //calculate start angle
        switch corner {
        case (.left, .top):
            if isIn {
                startAngle = CGFloat.pi * 3 / 2
                endAngle = CGFloat.pi
                isClockwise = true
            } else {
                startAngle = -CGFloat.pi / 2
                endAngle = 0
                //isClockwise = true
            }

        case (.right, .top):
            if isIn {
                startAngle = -CGFloat.pi / 2
                endAngle = 0
            } else {
                startAngle = CGFloat.pi * 3 / 2
                endAngle = CGFloat.pi
                isClockwise = true
            }

        case (.right, .down):
            if isIn {
                startAngle = 0
                endAngle = CGFloat.pi / 2
            } else {
                startAngle = CGFloat.pi
                endAngle = CGFloat.pi / 2
                isClockwise = true
            }

        case (.left, .down):
            if isIn {
                startAngle = CGFloat.pi
                endAngle = CGFloat.pi / 2
                isClockwise = true
            } else {
                startAngle = 0
                endAngle = CGFloat.pi / 2
            }

        default:
            break
        }

        ctx.addArc(
            center: arcCenter,
            radius: radius / 2,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: isClockwise
        )
    }

    private func drawBackground(in ctx: CGContext) {
        ctx.beginPath()

        for lineIndex in 0..<lines.count {
            let lineFrame = lineRect(line: lineIndex)

            ctx.addRect(CGRect(x: lineFrame.minX + sizePoint / 2, y: lineFrame.minY, width: lineFrame.width - sizePoint, height: lineFrame.height))

            if lineIndex != -1 && lineIndex != lines.count {
                // right side
                ctx.move(to: CGPoint(x: lineRect(line: lineIndex).maxX - sizePoint / 2, y: lineRect(line: lineIndex).minY))

                if lineIndex != 0 && lineRect(line: lineIndex).maxX == lineRect(line: lineIndex - 1).maxX {
                    ctx.addLine(to: CGPoint(x: lineFrame.maxX, y: lineFrame.minY))
                } else if lineIndex == 0 || lineRect(line: lineIndex).maxX > lineRect(line: lineIndex - 1).maxX {
                    let radius = min(lineIndex == 0 ? 8.0 : abs(lineRect(line: lineIndex).maxX - lineRect(line: lineIndex - 1).maxX), 8.0)

                    drawArc(in: ctx, lineIndex: lineIndex, corner: (.right, .top), isIn: true, isReverse: false, radius: radius)
                } else {
                    let radius = min(lineIndex == 0 ? 8.0 : abs(lineRect(line: lineIndex).maxX - lineRect(line: lineIndex - 1).maxX), 8.0)
                    drawArc(in: ctx, lineIndex: lineIndex, corner: (.right, .top), isIn: false, isReverse: false, radius: radius)
                }

                if lineIndex != lines.count - 1 && lineRect(line: lineIndex).maxX == lineRect(line: lineIndex + 1).maxX {
                    ctx.addLine(to: CGPoint(x: lineFrame.maxX, y: lineFrame.maxY))
                } else if lineIndex == lines.count - 1 || lineRect(line: lineIndex).maxX > lineRect(line: lineIndex + 1).maxX {
                    let radius = min(lineIndex == lines.count - 1 ? 8.0 : abs(lineRect(line: lineIndex).maxX - lineRect(line: lineIndex + 1).maxX), 8.0)

                    drawArc(in: ctx, lineIndex: lineIndex, corner: (.right, .down), isIn: true, isReverse: false, radius: radius)
                } else {
                    let radius = min(lineIndex == lines.count - 1 ? 8.0 : abs(lineRect(line: lineIndex).maxX - lineRect(line: lineIndex + 1).maxX), 8.0)
                    drawArc(in: ctx, lineIndex: lineIndex, corner: (.right, .down), isIn: false, isReverse: false, radius: radius)
                }

                ctx.addLine(to: CGPoint(x: lineFrame.maxX - sizePoint / 2, y: lineFrame.maxY))

                // left side
                ctx.move(to: CGPoint(x: lineRect(line: lineIndex).minX + sizePoint / 2, y: lineRect(line: lineIndex).minY))

                if lineIndex != 0 && lineRect(line: lineIndex).minX == lineRect(line: lineIndex - 1).minX {
                    ctx.addLine(to: CGPoint(x: lineFrame.minX, y: lineFrame.minY))
                } else if lineIndex == 0 || lineRect(line: lineIndex).minX < lineRect(line: lineIndex - 1).minX {
                    let radius = min(lineIndex == 0 ? 8.0 : abs(lineRect(line: lineIndex).minX - lineRect(line: lineIndex - 1).minX), 8.0)

                    drawArc(in: ctx, lineIndex: lineIndex, corner: (.left, .top), isIn: true, isReverse: false, radius: radius)
                } else {
                    let radius = min(lineIndex == 0 ? 8.0 : abs(lineRect(line: lineIndex).minX - lineRect(line: lineIndex - 1).minX), 8.0)

                    drawArc(in: ctx, lineIndex: lineIndex, corner: (.left, .top), isIn: false, isReverse: false, radius: radius)
                }

                if lineIndex != lines.count - 1 && lineRect(line: lineIndex).minX == lineRect(line: lineIndex + 1).minX {
                    ctx.addLine(to: CGPoint(x: lineFrame.minX, y: lineFrame.maxY))
                } else if lineIndex == lines.count - 1 || lineRect(line: lineIndex).minX < lineRect(line: lineIndex + 1).minX {
                    let radius = min(lineIndex == lines.count - 1 ? 8.0 : abs(lineRect(line: lineIndex).minX - lineRect(line: lineIndex + 1).minX), 8.0)

                    drawArc(in: ctx, lineIndex: lineIndex, corner: (.left, .down), isIn: true, isReverse: false, radius: radius)
                } else {
                    let radius = min(lineIndex == lines.count - 1 ? 8.0 : abs(lineRect(line: lineIndex).minX - lineRect(line: lineIndex + 1).minX), 8.0)

                    drawArc(in: ctx, lineIndex: lineIndex, corner: (.left, .down), isIn: false, isReverse: false, radius: radius)
                }

                ctx.addLine(to: CGPoint(x: lineFrame.minX + sizePoint / 2, y: lineFrame.maxY))
            }
        }

        ctx.closePath()

        if text.style == .background {
            text.color.setFill()
        } else if text.style == .transparent {
            text.color.withAlphaComponent(0.25).setFill()
        } else {
            UIColor.clear.setFill()
        }

        ctx.fillPath()
    }

    private func drawOutline() {
        let string = NSAttributedString(string: text.text, attributes: [
            .paragraphStyle: paragraphStyle,
            .font: text.font,
            .strokeColor: text.color,
            .strokeWidth: -4 * 2
        ])

        string.draw(
            in: CGRect(
                x: sizePoint - textWidth / 2,
                y: -textHeight / 2,
                width: textWidth - sizePoint * 2,
                height: textHeight
            )
        )
    }

    var result: UIImage {
        return image.image!
    }

    private func drawText() {
        var string: NSAttributedString

        if text.style == .outlined {
            drawOutline()
        }

        string = NSAttributedString(string: text.text, attributes: attributes)
        string.draw(
            in: CGRect(
                x: sizePoint - textWidth / 2,
                y: -textHeight / 2,
                width: textWidth - sizePoint * 2,
                height: textHeight
            )
        )
    }

    private func drawSelection(in ctx: CGContext) {
        guard
            let selectedText = selectedText
        else { return }

        setup(with: texts[selectedText])

        let rect = CGRect(
            x: -(textWidth * text.scale / 2) - 12,
            y: -(textHeight * text.scale / 2) - 12,
            width: textWidth * text.scale + 24,
            height: textHeight * text.scale + 24
        )

        firstTransformPoint = text.center + CGPoint(x: cos(text.rotation), y: sin(text.rotation)) * (textWidth * text.scale / 2 + 12)
        secondTransformPoint = text.center - CGPoint(x: cos(text.rotation), y: sin(text.rotation)) * (textWidth * text.scale / 2 + 12)

        ctx.translateBy(
            x: text.center.x,
            y: text.center.y
        )

        ctx.rotate(by: text.rotation)

        ctx.addPath(UIBezierPath(roundedRect: rect, cornerRadius: 6).cgPath)

        UIColor.white.setStroke()
        ctx.setLineDash(phase: 8, lengths: [8, 8])
        ctx.setLineCap(.round)

        ctx.setLineWidth(2)
        ctx.strokePath()

        UIColor.white.setFill()
        ctx.setLineDash(phase: 0, lengths: [1, 0])
        ctx.addEllipse(
            in: CGRect(
                x: -(textWidth * text.scale / 2) - 12 - 6,
                y: -6,
                width: 12,
                height: 12
            )
        )

        ctx.addEllipse(
            in: CGRect(
                x: (textWidth * text.scale / 2) + 12 - 6,
                y: -6,
                width: 12,
                height: 12
            )
        )

        ctx.fillPath()

        ctx.rotate(by: -text.rotation)
        ctx.translateBy(
            x: -text.center.x,
            y: -text.center.y
        )
    }

    private func setup(with: Text) {
        self.text = with

        paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = text.alignment
        paragraphStyle.lineSpacing = 0

        attributes = [
            NSAttributedString.Key.font: text.font,
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.foregroundColor: text.style == .background ? text.color == UIColor.white ? UIColor.black : UIColor.white : text.style == .outlined ? text.color == UIColor.white ? UIColor.black : UIColor.white : text.color
        ]

        lines = text.text.split(separator: "\n").map { String($0) }
        lineWidths = []

        for index in 0..<lines.count {
            lineWidths.append(
                ceil((lines[index] as NSString).size(withAttributes: attributes).width / sizePoint) + 2
            )
        }

        lineHeight = NSAttributedString(string: "a", attributes: [.font: text.font]).size().height

        textWidth = (lineWidths.max() ?? 0) * sizePoint
        textHeight = CGFloat(lines.count) * lineHeight
    }

    init(text: String) {
        super.init(frame: .zero)

        isOpaque = false
        addSubview(image)

        selectedText = nil
    }

    lazy private var image: UIImageView = {
        let img = UIImageView(frame: .zero)

        img.contentMode = .scaleAspectFill
        return img
    }()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func drawTexts(size: CGSize) {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return }

        for text in texts {
            setup(with: text)

            context.interpolationQuality = .low

            context.translateBy(x: text.center.x, y: text.center.y)
            context.scaleBy(x: text.scale, y: text.scale)
            context.rotate(by: text.rotation)

            drawBackground(in: context)
            drawText()

            context.rotate(by: -text.rotation)
            context.scaleBy(x: 1 / text.scale, y: 1 / text.scale)
            context.translateBy(x: -text.center.x, y: -text.center.y)
        }

        drawSelection(in: context)

        image.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
}

extension TextView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {

    }
}

extension TextView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
