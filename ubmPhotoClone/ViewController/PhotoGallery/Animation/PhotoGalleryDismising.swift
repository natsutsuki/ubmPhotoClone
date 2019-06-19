//
//  PhotoGalleryDismising.swift
//  ubmPhotoClone
//
//  Created by c.c on 2019/6/18.
//  Copyright © 2019 c.c. All rights reserved.
//

import UIKit

/// 出场 动画分配器
class PhotoGalleryDismising: NSObject, UIViewControllerTransitioningDelegate
{
    /* 动画用临时view */
    let snapshotView:UIImageView
    var toView_front_view = UIView()
    var fromView_background_view = UIView()
    
    let indexPath:IndexPath
    
    init(indexPath:IndexPath, snapshotView:UIImageView) {
        self.indexPath = indexPath
        self.snapshotView = snapshotView
        
        super.init()
    }
    
    deinit {
        self.panGesutre?.removeTarget(self, action: #selector(self.handlePan))
    }
    
    /* 交互式转场 */
    var panGesutre:UIPanGestureRecognizer? {
        didSet {
            panGesutre?.addTarget(self, action: #selector(self.handlePan))
        }
    }
    
    var interactContext: UIViewControllerContextTransitioning?
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self;
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        
        if panGesutre != nil {
            return self;
        }
        
        return nil;
    }
    
}
