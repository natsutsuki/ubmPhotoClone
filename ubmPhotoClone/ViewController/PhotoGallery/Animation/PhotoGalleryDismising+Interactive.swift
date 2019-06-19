//
//  PhotoGalleryDismising+Interactive.swift
//  ubmPhotoClone
//
//  Created by c.c on 2019/6/19.
//  Copyright © 2019 c.c. All rights reserved.
//

import UIKit

extension PhotoGalleryDismising: UIViewControllerInteractiveTransitioning
{
    
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning)
    {
        let fromView = transitionContext.view(forKey: .from)!
        let toVC = transitionContext.viewController(forKey: .to)! as! IPhotoPresentingController
        let containerView = transitionContext.containerView
        
        fromView.isHidden = true
        
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
        
        interactContext = transitionContext
    }
    
    @objc func handlePan(_ sender: UIPanGestureRecognizer) {
        guard let containerView = interactContext?.containerView else { return }
        let translation = sender.translation(in: containerView)
        
        var scaleFactor:CGFloat
        var completePercent:CGFloat
        
        if translation.y > 0 {
            let fullCourse = containerView.bounds.height / 2
            completePercent = min(translation.y / fullCourse, 1)
            
            scaleFactor = 1 - (completePercent * 0.4)
        } else {
            scaleFactor = 1
            completePercent = 0
        }
        
        switch sender.state
        {
        case .changed:
            
            fromView_background_view.alpha = 1 - completePercent
            snapshotView.transform = CGAffineTransform.identity
                .translatedBy(x: translation.x, y: translation.y)
                .scaledBy(x: scaleFactor, y: scaleFactor)
            
            break
            
        case .ended:
            // 判断机制:
            // 1.只要有向上的速度，都必须回滚
            // 2.只要有向下的速度，都必须完成
            // 3.速度为0时，判断进度，进度超过60%的，都完成，否则会滚
            let velocity = sender.velocity(in: containerView)
            
            if velocity.y < 0 {
                cancelInteractiveTransition(animated: true)
                return;
            }
            
            if velocity.y == 0.0 {
                if completePercent > 0.6 {
                    finishInteractiveTransition()
                } else {
                    cancelInteractiveTransition(animated: true)
                }
                return;
            }
            
            if velocity.y > 0 {
                finishInteractiveTransition()
                return;
            }
            
            break
            
        default:
            cancelInteractiveTransition(animated: false)
            break
        }
        
    }
    
    private func finishInteractiveTransition() {
        let toVC = interactContext!.viewController(forKey: .to)! as! IPhotoPresentingController
        let targetFrame = toVC.getFrameInWindow(for: indexPath)
        
        // 动画完成转场
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.1, options: UIView.AnimationOptions.curveLinear, animations: {
            
            self.snapshotView.transform = CGAffineTransform.identity
            self.snapshotView.frame = targetFrame
            self.fromView_background_view.alpha = 0
            
        }) { (_) in
            
            self.interactContext?.finishInteractiveTransition()
            self.interactContext?.completeTransition(true)
        }
        
    }
    
    private func cancelInteractiveTransition(animated:Bool) {
        guard let context = interactContext else { fatalError("error") }
        
        let fromView = context.view(forKey: .from)!
        
        if animated == false
        {
            fromView.isHidden = false
            context.cancelInteractiveTransition()
            context.completeTransition(false)
            return;
        }
        
        // 动画取消，回滚
        UIView.animate(withDuration: 0.2, animations: {
            
            self.snapshotView.transform = CGAffineTransform.identity
            self.fromView_background_view.alpha = 1
            
        }) { (_) in
            fromView.isHidden = false
            self.interactContext?.cancelInteractiveTransition()
            self.interactContext?.completeTransition(false)
        }
        
    }
    
}
