//
//  HeroDisappearAnimation.swift
//  PhotoArt
//
//  Created by Rustam Khakhuk on 14.10.2022.
//

import UIKit
import PencilKit

class HeroDisappearAnimation: NSObject, UIViewControllerAnimatedTransitioning {

    var fromImage: UIImageView
    var fromImageFrame: CGRect

    init(fromView: UIImageView, fromViewFrame: CGRect) {
        self.fromImage = fromView
        self.fromImageFrame = fromViewFrame
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.8
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let resultView = transitionContext.view(forKey: .from),
            let controller = transitionContext.viewController(forKey: .from) as? EditorViewController
        else { return }

        let canvas = controller.view.subviews[0] as! UIScrollView
        let offset = canvas.contentOffset
        print(offset)

        let resultWidth = canvas.zoomScale * controller.view.bounds.width
        let resultHeight = resultWidth * (fromImage.image!.size.height / fromImage.image!.size.width)


        fromImage.alpha = 0
        let animationImage = UIImageView()
        animationImage.clipsToBounds = true
        animationImage.contentMode = .scaleAspectFill
        animationImage.frame = CGRect(
            x: -offset.x,
            y: -offset.y,
            width: resultWidth,
            height: resultHeight
        )
        animationImage.image = fromImage.image

        

        transitionContext.containerView.addSubview(resultView)
        transitionContext.containerView.addSubview(animationImage)

        resultView.backgroundColor = .clear
        resultView.subviews[0].alpha = 0

        (resultView.subviews[2] as! ToolBar).setupTools()

        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.9, animations: {
            animationImage.frame = self.fromImageFrame
        }, completion: { _ in

            self.fromImage.alpha = 1
            animationImage.removeFromSuperview()

            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })

        UIView.animate(withDuration: 0.3) {
            resultView.alpha = 0
        }
    }
}
