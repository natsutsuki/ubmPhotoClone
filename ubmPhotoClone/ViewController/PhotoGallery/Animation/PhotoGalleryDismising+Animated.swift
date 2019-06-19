//
//  PhotoGalleryDismising+Animated.swift
//  ubmPhotoClone
//
//  Created by c.c on 2019/6/19.
//  Copyright © 2019 c.c. All rights reserved.
//

import UIKit

extension PhotoGalleryDismising: UIViewControllerAnimatedTransitioning
{
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toVC = transitionContext.viewController(forKey: .to)! as! IPhotoPresentingController
        let containerView = transitionContext.containerView
        
        containerView.subviews.forEach{ $0.removeFromSuperview() }
        
        /* 添加目标地遮挡物 */
        let targetFrame = toVC.getFrameInWindow(for: indexPath)
        toView_front_view = UIView(frame: targetFrame.insetBy(dx: -1, dy: -1))
        toView_front_view.backgroundColor = UIColor.white
        
        containerView.addSubview(toView_front_view)
        
        /* 添加whiteView */
        fromView_background_view = UIView(frame: containerView.bounds)
        fromView_background_view.backgroundColor = UIColor.white
        fromView_background_view.alpha = 1
        
        containerView.addSubview(fromView_background_view)
        
        /* 添加主要动画用 snapshotView */
        containerView.addSubview(snapshotView)
        
        /* 开始动画 */
        let duration = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIView.AnimationOptions.curveEaseOut, animations: {
            
            self.snapshotView.frame = targetFrame
            self.fromView_background_view.alpha = 0
            
        }) { (_) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
    
    func animationEnded(_ transitionCompleted: Bool) {
        snapshotView.removeFromSuperview()
        toView_front_view.removeFromSuperview()
        fromView_background_view.removeFromSuperview()
    }
    
}
