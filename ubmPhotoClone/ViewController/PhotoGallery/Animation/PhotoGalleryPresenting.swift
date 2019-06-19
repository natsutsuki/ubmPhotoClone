//
//  PhotoGalleryPresenting.swift
//  ubmPhotoClone
//
//  Created by c.c on 2019/6/14.
//  Copyright © 2019 c.c. All rights reserved.
//

import UIKit

/// 画廊入场动画
class PhotoGalleryPresenting: NSObject, UIViewControllerAnimatedTransitioning {
    
    var snapshotView: UIImageView!
    var visualView_white: UIView!
    var blockView: UIView!
    
    init(image snapshot: UIImageView) {
        self.snapshotView = snapshot
        self.visualView_white = UIView()
        self.blockView = UIView(frame: snapshotView.frame.insetBy(dx: -1, dy: -1))
        self.blockView.backgroundColor = UIColor.white
        
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let toVC = transitionContext.viewController(forKey: .to)!
        let toView = transitionContext.view(forKey: .to)!
        let finalFrame = transitionContext.finalFrame(for: toVC)
        let container = transitionContext.containerView
        
        container.subviews.forEach{ $0.removeFromSuperview() }
        
        /* 加入白色遮罩层 */
        container.addSubview(blockView)
        
        visualView_white.frame = container.bounds
        visualView_white.backgroundColor = UIColor.white
        visualView_white.alpha = 0
        container.addSubview(visualView_white)
        
        /* 加入动画用snapshotView */
        container.addSubview(snapshotView)
        
        /* 加入toView */
        toView.alpha = 0
        container.addSubview(toView)
        
        let duration = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 1, options: UIView.AnimationOptions.curveLinear, animations: {
            
            self.visualView_white.alpha = 1
            self.snapshotView.frame = finalFrame
            
        }) { (_) in
            toView.alpha = 1
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
    
    func animationEnded(_ transitionCompleted: Bool) {
        if transitionCompleted {
            self.blockView.removeFromSuperview()
            self.snapshotView.removeFromSuperview()
            self.visualView_white.removeFromSuperview()
        }
    }
    
}
