//
//  HeroAppearAnimation.swift
//  PhotoArt
//
//  Created by Rustam Khakhuk on 13.10.2022.
//

import UIKit

class HeroAppearAnimation: NSObject, UIViewControllerAnimatedTransitioning {

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
            let resultView = transitionContext.view(forKey: .to),
            let controller = transitionContext.viewController(forKey: .to)
        else { return }

        let background = UIView(frame: resultView.frame)
        background.backgroundColor = .black
        background.alpha = 0

        let animationImage = UIImageView()
        animationImage.clipsToBounds = true
        animationImage.frame = fromImageFrame
        animationImage.contentMode = .scaleAspectFill
        animationImage.image = fromImage.image
        fromImage.alpha = 0

        let resultHeight = controller.view.bounds.width * (animationImage.image!.size.height / animationImage.image!.size.width)

        transitionContext.containerView.addSubview(background)
        transitionContext.containerView.addSubview(resultView)

        resultView.backgroundColor = .clear
        resultView.subviews[0].alpha = 0
        resultView.subviews[1].alpha = 0
        resultView.subviews[2].alpha = 0

        (resultView.subviews[2] as! ToolBar).setupTools()
        resultView.insertSubview(animationImage, at: 0)

        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, animations: {
            animationImage.frame = CGRect(x: 0, y: (controller.view.bounds.height - resultHeight) / 2, width: controller.view.bounds.width, height: resultHeight)
        }, completion: { _ in
            animationImage.removeFromSuperview()
            background.removeFromSuperview()
            resultView.subviews[0].alpha = 1
            resultView.backgroundColor = .black

            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })

        UIView.animate(withDuration: 0.3) {
            background.alpha = 1

            resultView.subviews[2].alpha = 1
            resultView.subviews[3].alpha = 1
        }
    }
}
