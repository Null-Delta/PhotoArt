//
//  ToolBar.swift
//  PhotoArt
//
//  Created by Rustam Khakhuk on 10.10.2022.
//

import UIKit
import PencilKit

enum ToolBarState {
    case draw
    case text
    case editing
}

class ToolBar: UIView {

    var onToolUpdate: (PKTool) -> Void = { _ in }
    var onEditorExit: () -> Void = { }
    var onTextStyleChange: (TextStyle, NSTextAlignment, UIColor) -> Void = { _, _, _ in }
    var onTextInputStart: () -> Void = { }

    func setText(text: Text) {
        textStyleButton.style = text.style
        textAlignmentButton.alignment = text.alignment
        colorBtn.color = text.color
        state = .text
        switcher.selection = 1

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8) { [unowned self] in
            layoutIfNeeded()
        }
    }

    var state: ToolBarState = .draw {
        didSet {
            if oldValue == .text && state != .text {
                NSLayoutConstraint.deactivate([textParamsConstraint])
                NSLayoutConstraint.deactivate([drawParamsConstraint])
                NSLayoutConstraint.activate([drawParamsConstraint])
                paramsBar.layoutIfNeeded()

                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8) { [unowned self] in
                    textStyleButton.alpha = 0
                    textAlignmentButton.alpha = 0
                    tools.forEach { tool in tool.showTool() }
                    toolsContainer.isUserInteractionEnabled = true
                }
            }

            if oldValue == .text && state == .draw {
                guard let tool = tools[selectedTool] as? DefaultDrawTool else { return }
                colorBtn.color = tool.color
                switcher.selection = 0
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8) { [unowned self] in
                    layoutIfNeeded()
                }
            }

            if state == .editing {
                switcher.state = .slider
                tools[selectedTool].state = .centerized

                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8) { [unowned self] in
                    for toolIndex in 0..<tools.count where toolIndex != selectedTool {
                        tools[toolIndex].hideTool()
                    }

                    colorBtn.alpha = 0
                    layoutIfNeeded()
                    tools[selectedTool].transform = transform.translatedBy(x: 0, y: -16).scaledBy(x: 1.5, y: 1.5)
                }
            } else if oldValue == .editing && state != oldValue {
                switcher.state = .switcher
                tools[selectedTool].state = .selected

                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8) { [unowned self] in
                    for toolIndex in 0..<tools.count where toolIndex != selectedTool {
                        tools[toolIndex].showTool()
                    }

                    colorBtn.alpha = 1
                    layoutIfNeeded()
                    tools[selectedTool].transform = CGAffineTransform(translationX: 0, y: -16)
                }
            } else if state == .text && oldValue != state {
                NSLayoutConstraint.deactivate([drawParamsConstraint])
                NSLayoutConstraint.deactivate([textParamsConstraint])
                NSLayoutConstraint.activate([textParamsConstraint])
                paramsBar.layoutIfNeeded()

                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8) { [unowned self] in
                    tools.forEach{ tool in tool.hideTool() }
                    textStyleButton.alpha = 1
                    textAlignmentButton.alpha = 1
                    toolsContainer.isUserInteractionEnabled = false
                }
            }
        }
    }

    private var selectedTool: Int = 0 {
        didSet {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.6) {
                self.tools[oldValue].state = .normal
                self.tools[self.selectedTool].state = .selected
                self.tools[self.selectedTool].transform = .identity.translatedBy(x: 0, y: -16)
            }

            if let drawTool = tools[selectedTool] as? (any DrawTool) {
                colorBtn.color = drawTool.color
            }

            onToolUpdate(tools[selectedTool].tool)
        }
    }


    private var tools: [DefaultTool] = [
        PenTool(),
        BrushTool(),
        PencilTool(),
        LassoTool(),
        EraseTool(),
    ]

    lazy private var blurView: UIView = {
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterial))
        blur.translatesAutoresizingMaskIntoConstraints = false
        blur.clearBlur()

        return blur
    }()

    lazy private var textStyleButton: TextStyleButton = {
        let btn = TextStyleButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.onStyleChange = { [unowned self] style in
            onTextStyleChange(style, textAlignmentButton.alignment, colorBtn.color)
        }

        return btn
    }()

    lazy private var textAlignmentButton: TextAlignmentButton = {
        let btn = TextAlignmentButton()
        btn.translatesAutoresizingMaskIntoConstraints = false

        btn.onAlignmentChange = { [unowned self] alignment in
            onTextStyleChange(textStyleButton.style, alignment, colorBtn.color)
        }

        return btn
    }()

    lazy private var exitBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false

        btn.setImage(.cancel, for: .normal)
        btn.tintColor = .white

        btn.addTarget(self, action: #selector(onExitClick), for: .touchUpInside)
        return btn
    }()

    lazy private var backBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false

        btn.setImage(.download, for: .normal)
        btn.tintColor = .white
        return btn
    }()

    lazy private var paramsBar: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        
        view.addSubview(textStyleButton)
        view.addSubview(textAlignmentButton)
        view.addSubview(colorBtn)

        NSLayoutConstraint.activate([
            colorBtn.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0),
            colorBtn.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8),
            colorBtn.widthAnchor.constraint(equalToConstant: 32),
            colorBtn.heightAnchor.constraint(equalToConstant: 32),

            textStyleButton.heightAnchor.constraint(equalToConstant: 32),
            textStyleButton.widthAnchor.constraint(equalToConstant: 32),
            textStyleButton.leftAnchor.constraint(equalTo: colorBtn.rightAnchor, constant: 16),
            textStyleButton.centerYAnchor.constraint(equalTo: colorBtn.centerYAnchor),

            textAlignmentButton.heightAnchor.constraint(equalToConstant: 32),
            textAlignmentButton.widthAnchor.constraint(equalToConstant: 32),
            textAlignmentButton.leftAnchor.constraint(equalTo: textStyleButton.rightAnchor, constant: 16),
            textAlignmentButton.centerYAnchor.constraint(equalTo: colorBtn.centerYAnchor),

            view.heightAnchor.constraint(equalToConstant: 48)
        ])

        return view
    }()

    lazy private var colorBtn: ColorButton = {
        let btn = ColorButton(
            onColorCanged: {[unowned self] newColor in
                if state == .draw {
                    if tools[selectedTool] is (any DrawTool) {
                        var drawTool = tools[selectedTool] as! (any DrawTool)

                        drawTool.color = newColor
                    }
                    onToolUpdate((self.tools[self.selectedTool] as! DefaultDrawTool).currentTool)
                } else {
                    onTextStyleChange(textStyleButton.style, textAlignmentButton.alignment, newColor)
                }
            }
        )
        btn.translatesAutoresizingMaskIntoConstraints = false

        return btn
    }()

    lazy private var switcher: Switcher = {
        let switcher = Switcher(onSelectionChanged: { [unowned self] selection, isUserInteraction in
            state = selection == 0 ? .draw : .text

            if selection == 1 && isUserInteraction {
                onTextInputStart()
            }

        }, onSliderChanged: { newSize in
            (self.tools[self.selectedTool] as! DefaultDrawTool).width = 4 + newSize * 30
            self.onToolUpdate((self.tools[self.selectedTool] as! DefaultDrawTool).currentTool)
        })

        switcher.firstText = "Draw"
        switcher.secondText = "Text"

        switcher.translatesAutoresizingMaskIntoConstraints = false

        return switcher
    }()

    lazy private var toolsContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    lazy private var toolsMask: CAGradientLayer = {
        let gradient = CAGradientLayer()

        gradient.colors = [
            UIColor.black.cgColor,
            UIColor.black.cgColor,
            UIColor.black.withAlphaComponent(0).cgColor,
        ]

        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        gradient.locations = [0, 0.9, 1]
        gradient.type = .axial

        return gradient
    }()

    lazy private var gradient: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        gradient.colors = [
            UIColor.black.withAlphaComponent(0.0).cgColor,
            UIColor.black.withAlphaComponent(0.5).cgColor,
            UIColor.black.withAlphaComponent(0.5).cgColor,
        ]
        gradient.type = .axial

        return gradient
    }()

    lazy private var backgroundMask: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        gradient.colors = [
            UIColor.black.withAlphaComponent(0.0).cgColor,
            UIColor.black.withAlphaComponent(1).cgColor,
            UIColor.black.withAlphaComponent(1).cgColor,
        ]
        gradient.type = .axial

        return gradient
    }()

    func setupTools() {
        switcher.layoutIfNeeded()

        let containerWidth = switcher.frame.width - 24
        let partWidth = containerWidth / CGFloat(tools.count)

        for toolIndex in 0..<tools.count {
            toolsContainer.insertSubview(tools[toolIndex], at: 1)

            tools[toolIndex].defaultXConstraint = tools[toolIndex].centerXAnchor.constraint(equalTo: switcher.leftAnchor, constant: partWidth * CGFloat(toolIndex) + partWidth / 2 + 12)

            NSLayoutConstraint.activate([
                tools[toolIndex].defaultXConstraint!,
                tools[toolIndex].bottomAnchor.constraint(equalTo: switcher.topAnchor, constant: 16)
            ])

            tools[toolIndex].centerXConstraint = tools[toolIndex].centerXAnchor.constraint(equalTo: switcher.centerXAnchor)
            tools[toolIndex].hideTool()
            tools[toolIndex].state = toolIndex == selectedTool ? .selected : .normal

            tools[toolIndex].onTap = { [unowned self] in
                switch tools[toolIndex].state {
                case .normal:
                    selectedTool = toolIndex

                case .selected:
                    if tools[toolIndex] is DefaultDrawTool {
                        switcher.sliderPosition = ((tools[toolIndex] as! DefaultDrawTool).width - 4) / 30
                        state = .editing
                    }

                case .centerized:
                    break
                }
            }
        }

        for toolIndex in 0..<tools.count {
            UIView.animate(withDuration: 0.7, delay: Double(toolIndex) * 0.02 + 0.1, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.6) {
                self.tools[toolIndex].showTool()
            }
        }

        selectedTool = 0

    }

    @objc private func onExitClick() {
        if state == .editing {
            state = .draw
        } else {
            onEditorExit()
        }
    }

    private var drawParamsConstraint: NSLayoutConstraint!
    private var textParamsConstraint: NSLayoutConstraint!

    override func layoutSubviews() {
        super.layoutSubviews()

        toolsContainer.layoutIfNeeded()
        toolsMask.frame = CGRect(x: 0, y: -64, width: toolsContainer.bounds.width, height: 56 + 64)
        backgroundMask.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        gradient.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)

        toolsContainer.layer.mask = toolsMask
        blurView.layer.mask = backgroundMask
        blurView.layer.insertSublayer(gradient, at: 0)

    }

    init() {
        super.init(frame: .zero)

        addSubview(blurView)
        addSubview(exitBtn)
        addSubview(backBtn)
        addSubview(toolsContainer)
        addSubview(paramsBar)

        textStyleButton.alpha = 0
        textAlignmentButton.alpha = 0

        addSubview(switcher)

        drawParamsConstraint = paramsBar.rightAnchor.constraint(equalTo: switcher.leftAnchor)
        textParamsConstraint = paramsBar.rightAnchor.constraint(equalTo: rightAnchor)

        NSLayoutConstraint.activate([
            exitBtn.topAnchor.constraint(equalTo: topAnchor, constant: 56),
            exitBtn.leftAnchor.constraint(equalTo: leftAnchor, constant: 8),
            exitBtn.widthAnchor.constraint(equalToConstant: 32),
            exitBtn.heightAnchor.constraint(equalToConstant: 32),

            backBtn.topAnchor.constraint(equalTo: topAnchor, constant: 56),
            backBtn.rightAnchor.constraint(equalTo: rightAnchor, constant: -8),
            backBtn.widthAnchor.constraint(equalToConstant: 32),
            backBtn.heightAnchor.constraint(equalToConstant: 32),

            blurView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            blurView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0),
            blurView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0),

            switcher.leftAnchor.constraint(equalTo: exitBtn.rightAnchor, constant: 16),
            switcher.rightAnchor.constraint(equalTo: backBtn.leftAnchor, constant: -16),
            switcher.topAnchor.constraint(equalTo: exitBtn.topAnchor),
            switcher.heightAnchor.constraint(equalToConstant: 32),

            toolsContainer.leftAnchor.constraint(equalTo: switcher.leftAnchor),
            toolsContainer.rightAnchor.constraint(equalTo: switcher.rightAnchor),
            toolsContainer.bottomAnchor.constraint(equalTo: switcher.topAnchor),
            toolsContainer.heightAnchor.constraint(equalToConstant: 56),

            paramsBar.leftAnchor.constraint(equalTo: leftAnchor),
            paramsBar.rightAnchor.constraint(equalTo: rightAnchor),
            drawParamsConstraint,
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
