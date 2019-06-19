//
//  GridViewController+Transitioning.swift
//  ubmPhotoClone
//
//  Created by c.c on 2019/6/15.
//  Copyright © 2019 c.c. All rights reserved.
//

import UIKit

extension GridViewController: UIViewControllerTransitioningDelegate, IPhotoPresentingController
{
    
    func getFrameInWindow(for indexPath: IndexPath) -> CGRect {
        
        if !collectionView.indexPathsForVisibleItems.contains(indexPath) {
            collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
            collectionView.layoutIfNeeded()
        }
        
        let cell = collectionView.cellForItem(at: indexPath)!
        return cell.convert(cell.bounds, to: nil);
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if presented is PhotoGalleryController {
            let indexPath = collectionView.indexPathsForSelectedItems!.first!
            let cell = collectionView.cellForItem(at: indexPath)! as! GridCell
            let frameInWindow = cell.convert(cell.bounds, to: nil)
            
            let snapshotImageView = UIImageView(frame: frameInWindow)
            snapshotImageView.clipsToBounds = true
            snapshotImageView.contentMode = .scaleAspectFit
            snapshotImageView.image = cell.imageView.image
            
            return PhotoGalleryPresenting(image: snapshotImageView);
        }
        
        return nil;
    }
    
    
}
