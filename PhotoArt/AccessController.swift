//
//  AccessController.swift
//  PhotoArt
//
//  Created by Rustam Khakhuk on 14.10.2022.
//

import UIKit
import Lottie
import Photos

class AccessController: UIViewController {

    private var transitionDelegate = AccessTransitioningDelegate()

    lazy private var accessButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false

        btn.setTitle("Allow Access", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        btn.backgroundColor = .accent
        btn.layer.cornerRadius = 10
        btn.clipsToBounds = true

        btn.addTarget(self, action: #selector(onAccessAllowed), for: .touchUpInside)
        return btn
    }()

    lazy private var accessBorder: UIView = {
        let btn = UIView()
        btn.translatesAutoresizingMaskIntoConstraints = false

        btn.backgroundColor = .clear
        btn.layer.cornerRadius = 10
        btn.clipsToBounds = true
        btn.layer.borderWidth = 2
        btn.layer.borderColor = UIColor.white.cgColor
        btn.isUserInteractionEnabled = false

        return btn
    }()

    lazy private var galleryDuck: AnimationView = {
        let view = AnimationView(name: "duck")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.loopMode = .loop
        view.animationSpeed = 1
        view.play()

        return view
    }()

    lazy private var accessLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Access Your Photos and Videos"
        lbl.textColor = .white
        lbl.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        lbl.translatesAutoresizingMaskIntoConstraints = false

        return lbl
    }()

    lazy private var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(accessButton)
        view.addSubview(accessBorder)
        view.addSubview(galleryDuck)
        view.addSubview(accessLabel)

        NSLayoutConstraint.activate([
            accessButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            accessButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0),
            accessButton.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            accessButton.heightAnchor.constraint(equalToConstant: 50),

            accessBorder.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            accessBorder.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0),
            accessBorder.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            accessBorder.heightAnchor.constraint(equalToConstant: 50),

            accessLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            accessLabel.bottomAnchor.constraint(equalTo: accessButton.topAnchor, constant: -28),

            galleryDuck.widthAnchor.constraint(equalToConstant: 144),
            galleryDuck.heightAnchor.constraint(equalToConstant: 144),
            galleryDuck.bottomAnchor.constraint(equalTo: accessLabel.topAnchor, constant: -20),
            galleryDuck.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            view.topAnchor.constraint(equalTo: galleryDuck.topAnchor)
        ])


        return view
    }()

    lazy private var gradient: CAGradientLayer = {
        let gradient = CAGradientLayer()

        gradient.colors = [
            UIColor.white.withAlphaComponent(0).cgColor,
            UIColor.white.withAlphaComponent(0.15).cgColor,
            UIColor.white.withAlphaComponent(0.30).cgColor,
            UIColor.white.withAlphaComponent(0.15).cgColor,
            UIColor.white.withAlphaComponent(0).cgColor,
        ]

        gradient.locations = [-1, -0.85, -0.75, -0.65, -0.5]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)

        return gradient
    }()

    lazy private var borderGradient: CAGradientLayer = {
        let gradient = CAGradientLayer()

        gradient.colors = [
            UIColor.white.withAlphaComponent(0).cgColor,
            UIColor.white.withAlphaComponent(0.35).cgColor,
            UIColor.white.withAlphaComponent(0.5).cgColor,
            UIColor.white.withAlphaComponent(0.35).cgColor,
            UIColor.white.withAlphaComponent(0).cgColor,
        ]

        gradient.locations = [-1, -0.85, -0.75, -0.65, -0.5]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)

        return gradient
    }()

    private func presentGallery() {
        DispatchQueue.main.async { [unowned self] in
            let gallery = GalleryController()
            gallery.transitioningDelegate = transitionDelegate
            gallery.modalPresentationStyle = .custom

            present(gallery, animated: true)
        }
    }

    @objc private func onAccessAllowed() {

        let status = PHPhotoLibrary.authorizationStatus()

        if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization { [unowned self] status in
                if status == .authorized {
                    presentGallery()
                } else {
                    DispatchQueue.main.async { [unowned self] in
                        let alert = UIAlertController(title: nil, message: "The app needs access to photos", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Open settings", style: .default, handler: { _ in
                            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
                            }
                        }))

                        present(alert, animated: true)
                    }
                }
            }
        } else if status == .authorized {
            presentGallery()
        } else {
            DispatchQueue.main.async { [unowned self] in
                let alert = UIAlertController(title: nil, message: "The app needs access to photos", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Open settings", style: .default, handler: { _ in
                    if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
                    }
                }))

                present(alert, animated: true)
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        borderGradient.frame = view.bounds
        gradient.frame = view.bounds

        accessButton.layer.insertSublayer(gradient, at: 0)
        accessBorder.layer.mask = borderGradient
        accessButton.layer.insertSublayer(gradient, at: 0)

        let anim = CABasicAnimation(keyPath: "locations")
        anim.fromValue = [-1, -0.85, -0.75, -0.65, -0.5]
        anim.toValue = [2, 2.15, 2.25, 2.35, 2.5]
        anim.duration = 2
        anim.repeatCount = .infinity

        borderGradient.add(anim, forKey: "locations")
        gradient.add(anim, forKey: "locations")
    }

    override func viewDidLoad() {
        view.backgroundColor = .black

        view.addSubview(containerView)

        NSLayoutConstraint.activate([
            containerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            containerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

        ])

    }
}
