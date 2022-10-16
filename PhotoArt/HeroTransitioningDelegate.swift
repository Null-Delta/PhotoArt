//
//  HeroTransitioningDelegate.swift
//  PhotoArt
//
//  Created by Rustam Khakhuk on 13.10.2022.
//

import UIKit

class HeroTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    private var fromImage: UIImageView
    private var fromImageFrame: CGRect

    init(fromView: UIImageView, fromViewFrame: CGRect) {
        self.fromImage = fromView
        self.fromImageFrame = fromViewFrame
    }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return HeroAppearAnimation(fromView: fromImage, fromViewFrame: fromImageFrame)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return HeroDisappearAnimation(fromView: fromImage, fromViewFrame: fromImageFrame)
    }
}
