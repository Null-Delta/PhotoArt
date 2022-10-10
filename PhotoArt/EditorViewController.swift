//
//  EditorViewController.swift
//  PhotoArt
//
//  Created by Rustam Khakhuk on 09.10.2022.
//

import UIKit
import Combine

class EditorViewController: UIViewController {
    lazy private var navigationBar: EditorNavigationBar = {
        let bar = EditorNavigationBar()
        bar.translatesAutoresizingMaskIntoConstraints = false
        return bar
    }()

    lazy private var canvas: Canvas = {
        let canvas = Canvas(image: UIImage(named: "testImage")!)

        return canvas
    }()

    override func viewDidLoad() {
        view.addSubview(canvas)
        view.addSubview(navigationBar)

        NSLayoutConstraint.activate([
            canvas.topAnchor.constraint(equalTo: view.topAnchor),
            canvas.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            canvas.leftAnchor.constraint(equalTo: view.leftAnchor),
            canvas.rightAnchor.constraint(equalTo: view.rightAnchor),

            navigationBar.topAnchor.constraint(equalTo: view.topAnchor),
            navigationBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            navigationBar.rightAnchor.constraint(equalTo: view.rightAnchor),
            navigationBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 48),
        ])
    }

    override func viewDidLayoutSubviews() {
        canvas.centerize()
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
