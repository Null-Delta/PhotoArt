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

    lazy private var textView: TextView = {
        let view = TextView(text: "AAA\nAAAA\nsome body\nccc\ndddddddd")
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        // Do any additional setup after loading the view.

        view.addSubview(textView)
        textView.frame = view.bounds

//        NSLayoutConstraint.activate([
//            canvas.leftAnchor.constraint(equalTo: view.leftAnchor),
//            canvas.rightAnchor.constraint(equalTo: view.rightAnchor),
//            canvas.topAnchor.constraint(equalTo: view.topAnchor),
//            canvas.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//        ])
    }
}

