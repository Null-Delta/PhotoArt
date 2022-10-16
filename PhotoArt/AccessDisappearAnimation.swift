//
//  AccessDisappearAnimation.swift
//  PhotoArt
//
//  Created by Rustam Khakhuk on 14.10.2022.
//

import UIKit

class AccessDisappearAnimation: NSObject, UIViewControllerAnimatedTransitioning {

    lazy private var maskGradient: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.black.withAlphaComponent(0.0).cgColor,
            UIColor.black.withAlphaComponent(1.0).cgColor,
            UIColor.black.withAlphaComponent(1.0).cgColor
        ]
        gradient.locations = [-0.2, 0, 1]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)

        return gradient
    }()
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 5
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromView = transitionContext.view(forKey: .from)
        else { return }

        transitionContext.containerView.addSubview(fromView)
        maskGradient.frame = fromView.bounds

        fromView.layer.mask = maskGradient
        maskGradient.locations = [1, 1.2, 1.4]

        let anim = CABasicAnimation(keyPath: "locations")
        anim.fromValue = [-0.2, 0, 1]
        anim.toValue = [1, 1.2, 1.4]
        anim.duration = 0.25
        anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        self.maskGradient.add(anim, forKey: "locations")

        UIView.animate(withDuration: 0.25, delay: 0,options: .curveEaseInOut, animations: {
            fromView.alpha = 0.99
        }, completion: { _ in
            fromView.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
