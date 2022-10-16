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
            }
        )

        bar.translatesAutoresizingMaskIntoConstraints = false
        return bar
    }()

    lazy private var toolBar: ToolBar = {
        let bar = ToolBar()
        bar.translatesAutoresizingMaskIntoConstraints = false

        bar.onEditorExit = { [weak self] in
            //print(self!.canvas.drawing)
            self?.dismiss(animated: true)
        }
        return bar
    }()

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

        canvas.showsHorizontalScrollIndicator = false
        canvas.showsVerticalScrollIndicator = false

        canvas.insertSubview(imageView, at: 0)

        return canvas
    }()

    lazy private var imageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)

        imageView.image = image
        return imageView
    }()


    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        canvas.setZoomScale(1, animated: false)
        canvas.scrollRectToVisible(CGRect(origin: CGPoint(x: -view.bounds.width / 2, y: -view.bounds.height / 2), size: view.bounds.size), animated: false)

        imageView.frame.size.width = view.bounds.width
        imageView.frame.size.height = imageView.frame.size.width * (image.size.height / image.size.width)
        imageView.frame.origin.y = (canvas.contentSize.height - imageView.frame.size.height) / 2

        canvas.contentSize = CGSize(width: imageView.frame.size.width, height: imageView.frame.size.height)
        canvas.contentInset.top = (view.bounds.height - canvas.contentSize.height) / 2
        canvas.contentOffset.y = -(view.bounds.height - canvas.contentSize.height) / 2
    }

    override func viewDidLoad() {
        view.backgroundColor = .black
        
        view.addSubview(canvas)
        view.addSubview(navigationBar)
        view.addSubview(toolBar)

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
