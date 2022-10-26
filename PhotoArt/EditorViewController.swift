//
//  EditorViewController.swift
//  PhotoArt
//
//  Created by Rustam Khakhuk on 09.10.2022.
//

import UIKit
import PencilKit

class EditorViewController: UIViewController {

    var image = UIImage(named: "testImage")!

    lazy private var navigationBar: EditorNavigationBar = {
        let bar = EditorNavigationBar(
            onZoomOut: { [unowned self] in
                UIView.animate(withDuration: 0.25) {
                    self.canvas.zoomScale = 1
                    self.canvas.contentOffset = CGPoint(
                        x: 0,
                        y: -(self.canvas.bounds.height - self.canvas.contentSize.height) / 2
                    )
                }
            },
            onUndo: { [unowned self] in
                canvas.undoManager?.undo()
                navigationBar.isUndoEnabled = canvas.undoManager!.canUndo
            },
            onClearAll: { [unowned self] in
                canvas.drawing = PKDrawing()
                objectsLayer.texts = []
                objectsLayer.selectedText = nil
                objectsLayer.state = .nothing

                navigationBar.isUndoEnabled = false
                objectsLayer.drawTexts(size: objectsLayer.bounds.size / canvas.zoomScale)
            }
        )

        bar.isUndoEnabled = true
        bar.translatesAutoresizingMaskIntoConstraints = false
        return bar
    }()

    lazy private var toolBar: ToolBar = {
        let bar = ToolBar()
        bar.translatesAutoresizingMaskIntoConstraints = false

        bar.onEditorExit = { [weak self] in
            self?.dismiss(animated: true)
        }

        bar.onTextStyleChange = { [unowned self] style, alignment, color in
            guard let selectedText = objectsLayer.selectedText else { return }

            let oldState = objectsLayer.texts[selectedText]
            let textIndex = selectedText

            objectsLayer.texts[selectedText].style = style
            objectsLayer.texts[selectedText].alignment = alignment
            objectsLayer.texts[selectedText].color = color

            objectsLayer.drawTexts(size: objectsLayer.bounds.size / canvas.zoomScale)

            canvas.undoManager!.registerUndo(withTarget: self, handler: { [unowned self] _ in
                objectsLayer.texts[textIndex] = oldState
                objectsLayer.selectedText = textIndex

                objectsLayer.drawTexts(size: objectsLayer.bounds.size / canvas.zoomScale)
            })

            navigationBar.isUndoEnabled = true
        }

        bar.onTextInputStart = { [unowned self] in
            let inputController = TextInputController()
            inputController.modalPresentationStyle = .overCurrentContext
            inputController.modalTransitionStyle = .crossDissolve

            inputController.onInputDone = { [unowned self] text in
                var text = text
                text.center = objectsLayer.center
                objectsLayer.texts.append(text)
                objectsLayer.selectedText = objectsLayer.texts.count - 1
                objectsLayer.drawTexts(size: objectsLayer.bounds.size / canvas.zoomScale)

                canvas.undoManager!.registerUndo(withTarget: self, handler: { [unowned self] _ in
                    objectsLayer.texts.removeAll(where: { $0.id == text.id })
                    objectsLayer.selectedText = nil
                    objectsLayer.drawTexts(size: objectsLayer.bounds.size / canvas.zoomScale)
                })

                navigationBar.isUndoEnabled = true
            }

            inputController.onInputCancel = { [unowned self] in
                toolBar.state = .draw
            }

            present(inputController, animated: true)
        }

        return bar
    }()

    private var undoObservation: NSKeyValueObservation!


    lazy private var canvas: PKCanvasView = {
        let canvas = PKCanvasView(frame: .zero)
        canvas.translatesAutoresizingMaskIntoConstraints = false
        canvas.tool = PKInkingTool(.pen, color: .green, width: 10)
        canvas.allowsFingerDrawing = true
        canvas.minimumZoomScale = 1
        canvas.maximumZoomScale = 10
        canvas.bouncesZoom = true
        canvas.delegate = self
        canvas.overrideUserInterfaceStyle = .light

        canvas.isOpaque = false

        canvas.drawingGestureRecognizer.delegate = self

        canvas.showsHorizontalScrollIndicator = false
        canvas.showsVerticalScrollIndicator = false

        canvas.insertSubview(imageView, at: 0)
        canvas.insertSubview(objectsLayer, at: 1)
        return canvas
    }()

    lazy private var imageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.isUserInteractionEnabled = false
        imageView.image = image
        return imageView
    }()

    lazy private var workspace: Canvas = {
        let canvas = Canvas(frame: .zero, device: MetalContext.device)
        canvas.isOpaque = true
        canvas.backgroundColor = .clear
        canvas.gestureRecognizers?.forEach {
            $0.delegate = self
        }

        return canvas
    }()

    lazy private var objectsLayer: TextView = {
        let canvas = TextView(text: "")
        canvas.backgroundColor = .clear
        
        return canvas
    }()

    private var touchStart: CGPoint = .zero
    private var startScale: CGFloat = .zero
    private var startAngle: CGFloat = .zero
    private var startCenter: CGPoint = .zero

    lazy var textGesture: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(onGesture))
        gesture.minimumPressDuration = 0

        return gesture
    }()

    lazy var textTapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(onTap))
        return gesture
    }()

    private func length(point: CGPoint) -> CGFloat {
        return sqrt(pow(point.x, 2) + pow(point.y, 2))
    }


    @objc private func onTap() {
        guard
            let tapText = objectsLayer.findSelectedText(in: textTapGesture.location(in: objectsLayer) / canvas.zoomScale)
        else { return }

        if objectsLayer.selectedText == tapText {
            let inputController = TextInputController(text: objectsLayer.texts[tapText])
            inputController.modalPresentationStyle = .overCurrentContext
            inputController.modalTransitionStyle = .crossDissolve

            inputController.onInputDone = { [unowned self] text in

                let oldState = objectsLayer.texts[tapText]

                objectsLayer.texts[tapText].text = text.text
                objectsLayer.texts[tapText].style = text.style
                objectsLayer.texts[tapText].alignment = text.alignment
                objectsLayer.texts[tapText].font = text.font
                objectsLayer.texts[tapText].color = text.color

                objectsLayer.drawTexts(size: objectsLayer.bounds.size / canvas.zoomScale)

                canvas.undoManager!.registerUndo(withTarget: self, handler: { [unowned self] _ in
                    objectsLayer.texts[tapText] = oldState
                    objectsLayer.selectedText = tapText

                    objectsLayer.drawTexts(size: objectsLayer.bounds.size / canvas.zoomScale)
                })
            }

            present(inputController, animated: true)
        } else {
            objectsLayer.selectedText = tapText
            objectsLayer.drawTexts(size: objectsLayer.bounds.size / canvas.zoomScale)
            toolBar.setText(text: objectsLayer.texts[tapText])
        }
    }

    @objc private func onGesture() {

        guard
            canvas.pinchGestureRecognizer?.state != .began,
            canvas.pinchGestureRecognizer?.state != .changed,
            canvas.pinchGestureRecognizer?.state != .recognized
        else {
            textGesture.isEnabled = false
            textGesture.isEnabled = true
            return
        }

        let position = textGesture.location(in: objectsLayer) / canvas.zoomScale
        switch textGesture.state {
        case .began:
            let tapText = objectsLayer.findSelectedText(in: textTapGesture.location(in: objectsLayer) / canvas.zoomScale)

            if (tapText != nil) {
                canvas.drawingGestureRecognizer.isEnabled = false
                canvas.drawingGestureRecognizer.isEnabled = true

                canvas.pinchGestureRecognizer?.isEnabled = false
                canvas.pinchGestureRecognizer?.isEnabled = true

                canvas.panGestureRecognizer.isEnabled = false
                canvas.panGestureRecognizer.isEnabled = true
            }

            guard objectsLayer.selectedText != nil else { return }

            touchStart = textGesture.location(in: objectsLayer) / canvas.zoomScale

            if (length(point: objectsLayer.firstTransformPoint! - touchStart) < 24 || length(point: objectsLayer.secondTransformPoint! - touchStart) < 24) {
                objectsLayer.state = .scaling
                startScale = objectsLayer.texts[objectsLayer.selectedText!].scale
                startAngle = objectsLayer.texts[objectsLayer.selectedText!].rotation

                canvas.drawingGestureRecognizer.isEnabled = false
                canvas.drawingGestureRecognizer.isEnabled = true

                canvas.pinchGestureRecognizer?.isEnabled = false
                canvas.pinchGestureRecognizer?.isEnabled = true

                canvas.panGestureRecognizer.isEnabled = false
                canvas.panGestureRecognizer.isEnabled = true
                
                objectsLayer.drawTexts(size: objectsLayer.bounds.size / canvas.zoomScale)

                toolBar.setText(text: objectsLayer.texts[objectsLayer.selectedText!])

            } else {
                objectsLayer.selectedText = objectsLayer.findSelectedText(in: touchStart)

                if objectsLayer.isInCurrentRect(point: touchStart) {
                    objectsLayer.state = .moving
                    startCenter = objectsLayer.texts[objectsLayer.selectedText!].center

                    objectsLayer.drawTexts(size: objectsLayer.bounds.size / canvas.zoomScale)
                    toolBar.setText(text: objectsLayer.texts[objectsLayer.selectedText!])
                } else {
                    objectsLayer.selectedText = nil
                    objectsLayer.state = .nothing
                    objectsLayer.drawTexts(size: objectsLayer.bounds.size / canvas.zoomScale)

                    toolBar.state = .draw
                }
            }


        case .changed:
            guard objectsLayer.state != .nothing else { return }

            if objectsLayer.state == .scaling {
                objectsLayer.texts[objectsLayer.selectedText!].scale = startScale * length(point: objectsLayer.texts[objectsLayer.selectedText!].center - position) / length(point: objectsLayer.texts[objectsLayer.selectedText!].center - touchStart)

                objectsLayer.texts[objectsLayer.selectedText!].rotation = startAngle + atan2(objectsLayer.texts[objectsLayer.selectedText!].center.x - touchStart.x, objectsLayer.texts[objectsLayer.selectedText!].center.y - touchStart.y) - atan2(objectsLayer.texts[objectsLayer.selectedText!].center.x - position.x, objectsLayer.texts[objectsLayer.selectedText!].center.y - position.y)

                objectsLayer.drawTexts(size: objectsLayer.bounds.size / canvas.zoomScale)
            } else {
                objectsLayer.texts[objectsLayer.selectedText!].center = startCenter + position - touchStart
                objectsLayer.drawTexts(size: objectsLayer.bounds.size / canvas.zoomScale)
            }

        case .ended:
            guard objectsLayer.state != .nothing else { return }

            let actionCenter = startCenter
            let actionAngle = startAngle
            let actionScale = startScale
            let textIndex = objectsLayer.selectedText!
            let currentText = objectsLayer.texts[objectsLayer.selectedText!]

            guard
                actionCenter != currentText.center,
                actionScale != currentText.scale,
                actionAngle != currentText.rotation
            else { return }

            canvas.undoManager!.registerUndo(withTarget: self, handler: { [unowned self] _ in
                objectsLayer.selectedText = textIndex
                objectsLayer.texts[textIndex].center = actionCenter
                objectsLayer.texts[textIndex].rotation = actionAngle
                objectsLayer.texts[textIndex].scale = actionScale

                objectsLayer.drawTexts(size: objectsLayer.bounds.size / canvas.zoomScale)
            })

            navigationBar.isUndoEnabled = true

        default:
            break
        }
    }



    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        canvas.setZoomScale(1, animated: false)
        canvas.scrollRectToVisible(CGRect(origin: CGPoint(x: -view.bounds.width / 2, y: -view.bounds.height / 2), size: view.bounds.size), animated: false)

        imageView.frame.size.width = view.bounds.width
        imageView.frame.size.height = imageView.frame.size.width * (image.size.height / image.size.width)
        imageView.frame.origin.y = (canvas.contentSize.height - imageView.frame.size.height) / 2

        objectsLayer.frame.size.width = imageView.bounds.width
        objectsLayer.frame.size.height = imageView.bounds.height
        objectsLayer.frame.origin.y = (canvas.contentSize.height - imageView.frame.size.height) / 2

        objectsLayer.subviews[0].frame.size = objectsLayer.frame.size
        objectsLayer.frame.origin = .zero
        objectsLayer.clipsToBounds = true

        canvas.contentSize = CGSize(width: imageView.frame.size.width, height: imageView.frame.size.height)
        canvas.contentInset.top = (view.bounds.height - canvas.contentSize.height) / 2
        canvas.contentOffset.y = -(view.bounds.height - canvas.contentSize.height) / 2

        objectsLayer.drawTexts(size: objectsLayer.bounds.size)
    }

    override func viewDidLoad() {
        view.backgroundColor = .black
        
        view.addSubview(canvas)
        view.addSubview(navigationBar)
        view.addSubview(toolBar)

        canvas.addGestureRecognizer(textGesture)
        canvas.addGestureRecognizer(textTapGesture)

        textGesture.delegate = self
        textTapGesture.delegate = self

        toolBar.onToolUpdate = { [weak self] newTool in
            self?.canvas.tool = newTool
        }

        NSLayoutConstraint.activate([
            canvas.topAnchor.constraint(equalTo: view.topAnchor),
            canvas.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            canvas.leftAnchor.constraint(equalTo: view.leftAnchor),
            canvas.rightAnchor.constraint(equalTo: view.rightAnchor),

            navigationBar.topAnchor.constraint(equalTo: view.topAnchor),
            navigationBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            navigationBar.rightAnchor.constraint(equalTo: view.rightAnchor),
            navigationBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 48),

            toolBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            toolBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            toolBar.rightAnchor.constraint(equalTo: view.rightAnchor),
            toolBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -96)
        ])
    }
}

extension EditorViewController: PKCanvasViewDelegate {
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        navigationBar.isZoomOutEnabled = scrollView.zoomScale > 1
        if !scrollView.isZooming {
            if (scrollView.zoomScale <= 1) {
                canvas.contentInset = UIEdgeInsets(
                    top: (canvas.bounds.height - canvas.contentSize.height) / 2,
                    left: 0,
                    bottom: (canvas.bounds.height - canvas.contentSize.height) / 2,
                    right: 0
                )
                canvas.contentOffset.y = -(canvas.bounds.height - canvas.contentSize.height) / 2
            }
        } else {
            if (scrollView.zoomScale < 1) {
                let widthInset = view.bounds.width * scrollView.zoomScale / 2
                let heightInset = view.bounds.height * scrollView.zoomScale / 2

                canvas.contentInset = UIEdgeInsets(top: heightInset, left: widthInset, bottom: heightInset, right: widthInset)
            }
        }

        imageView.frame.size.width = canvas.contentSize.width
        imageView.frame.size.height = imageView.frame.size.width * (image.size.height / image.size.width)
        imageView.frame.origin.y = (canvas.contentSize.height - imageView.frame.size.height) / 2

        objectsLayer.frame.size.width = imageView.bounds.width
        objectsLayer.frame.size.height = imageView.bounds.height
        objectsLayer.frame.origin.y = (canvas.contentSize.height - imageView.frame.size.height) / 2
        objectsLayer.subviews[0].frame.size = objectsLayer.frame.size
    }

    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        if scrollView.zoomScale > 1 {
            canvas.contentInset = UIEdgeInsets(
                top: (canvas.bounds.height) / 2,
                left: 0,
                bottom: (canvas.bounds.height) / 2,
                right: 0
            )
        }
    }

    func canvasViewDidEndUsingTool(_ canvasView: PKCanvasView) {
        navigationBar.isUndoEnabled = true
    }
}

extension EditorViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}

import SwiftUI
struct ViewControllerProvider: PreviewProvider {
    static var previews: some View {
        ContainerView().edgesIgnoringSafeArea(.all)
    }

    struct ContainerView: UIViewControllerRepresentable {

        func makeUIViewController(context: Context) -> some UIViewController {
            EditorViewController()
        }

        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
    }
}
