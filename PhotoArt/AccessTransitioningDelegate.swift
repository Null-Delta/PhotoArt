//
//  AccessTransitioningDelegate.swift
//  PhotoArt
//
//  Created by Rustam Khakhuk on 14.10.2022.
//

import UIKit

class AccessTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AccessDisappearAnimation()
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
}
