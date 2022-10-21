//
//  ViewController.swift
//  PhotoArt
//
//  Created by Rustam Khakhuk on 09.10.2022.
//

import UIKit
import Metal
import MetalKit

class ViewController: UIViewController {

    lazy private var canvas: Canvas = {
        let canvas = Canvas(frame: .zero, device: MetalContext.device)

        canvas.translatesAutoresizingMaskIntoConstraints = false
        return canvas
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        view.addSubview(canvas)

        NSLayoutConstraint.activate([
            canvas.leftAnchor.constraint(equalTo: view.leftAnchor),
            canvas.rightAnchor.constraint(equalTo: view.rightAnchor),
            canvas.topAnchor.constraint(equalTo: view.topAnchor),
            canvas.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}

