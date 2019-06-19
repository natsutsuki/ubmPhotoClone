//
//  PhotoGalleryController.swift
//  Photo Transitioning
//
//  Created by c.c on 2019/6/14.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import UIKit
import Photos

private let reuseIdentifier = "Cell"

class PhotoGalleryController: UICollectionViewController, UICollectionViewDataSourcePrefetching
{
    
    let fetchResult: PHFetchResult<PHAsset>
    let imageManager: PHCachingImageManager
    let queue: DispatchQueue
    
    /// 哪个用以转场
    let transitioningAsset: PHAsset
    
    var assetSize: CGSize = CGSize.zero
    var dismissAnime:PhotoGalleryDismising?
    
    init(transitioningAsset: PHAsset, fetchResult: PHFetchResult<PHAsset>, imageManager: PHCachingImageManager) {
        
        self.transitioningAsset = transitioningAsset
        self.fetchResult = fetchResult
        self.imageManager = imageManager
        
        queue = DispatchQueue(label: "com.photo.prewarm", qos: .default, attributes: [.concurrent], autoreleaseFrequency: .inherit, target: nil)
        
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var flowLayout: UICollectionViewFlowLayout {
        return collectionViewLayout as! UICollectionViewFlowLayout
    }

    // MARK:
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        view.clipsToBounds = true
        
        collectionView.register(UINib.init(nibName: "PhotoGalleryCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.isPrefetchingEnabled = true
        collectionView.prefetchDataSource = self
        collectionView.backgroundColor = UIColor.clear
        
        self.collectionView.contentInsetAdjustmentBehavior = .never
        self.collectionView?.isPagingEnabled = true
        self.collectionView?.frame = view.frame.insetBy(dx: -20.0, dy: 0.0)
        
        recalculateItemSize(inBoundingSize: self.view.bounds.size)
        
        let index = fetchResult.index(of: transitioningAsset)
        let indexPath = IndexPath.init(item: index, section: 0)
        
        collectionView.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.centeredHorizontally, animated: false)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.panRecognized))
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        recalculateItemSize(inBoundingSize: size)
        if view.window == nil {
            view.frame = CGRect(origin: view.frame.origin, size: size)
            view.layoutIfNeeded()
        } else {
            let indexPath = self.collectionView?.indexPathsForVisibleItems.last
            coordinator.animate(alongsideTransition: { ctx in
                self.collectionView?.layoutIfNeeded()
            }, completion: { _ in
                if let indexPath = indexPath {
                    self.collectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
                }
            })
        }
        
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    private func recalculateItemSize(inBoundingSize size: CGSize) {
        flowLayout.minimumLineSpacing = 40
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = size
        
        let itemSize = flowLayout.itemSize
        let scale = UIScreen.main.scale
        assetSize = CGSize(width: itemSize.width * scale, height: itemSize.height * scale);
    }
    
    @objc func panRecognized(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            //  Pan Gesture Recognizer continue from another Pan Gesture Recognizer
            handleDismiss(sender: sender)
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoGalleryCell
        
        let asset = fetchResult.object(at: indexPath.item)
        cell.assetIdentifier = asset.localIdentifier
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.isNetworkAccessAllowed = true
        
        self.imageManager.requestImage(for: asset, targetSize: self.assetSize, contentMode: .aspectFit, options: options) { (result, info) in
            if (cell.assetIdentifier == asset.localIdentifier) {
                cell.config(image: result!)
            }
        }
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        guard
            let indexPath = collectionView.indexPathsForVisibleItems.last,
            let layoutAttributes = flowLayout.layoutAttributesForItem(at: indexPath)
        else {
            return proposedContentOffset
        }
        
        return CGPoint(x: layoutAttributes.center.x - (layoutAttributes.size.width / 2.0) - (flowLayout.minimumLineSpacing / 2.0), y: 0)
    }
    
    // MARK: UICollectionViewDataSourcePrefetching
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        queue.async {
            self.imageManager.startCachingImages(for: indexPaths.map{self.fetchResult.object(at: $0.item)}, targetSize: self.assetSize, contentMode: .aspectFill, options: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        queue.async {
            self.imageManager.stopCachingImages(for: indexPaths.map{self.fetchResult.object(at: $0.item)}, targetSize: self.assetSize, contentMode: .aspectFill, options: nil)
        }
    }
    
    /// 出场
    private func handleDismiss(sender: Any?) {
        guard let cell = collectionView.visibleCells.first as? PhotoGalleryCell else { return }
        guard let indexPath = collectionView.indexPathsForVisibleItems.first else { return }
        
        let currentFrame = cell.convert(cell.imageView.contentClippingRect, to: nil)
        
        let snapshotView = UIImageView(frame: currentFrame)
        snapshotView.image = cell.imageView.image
        snapshotView.contentMode = .scaleAspectFill
        snapshotView.clipsToBounds = true
        
        dismissAnime = PhotoGalleryDismising(indexPath: indexPath, snapshotView: snapshotView)
        
        if let panGesutre = sender as? UIPanGestureRecognizer {
            dismissAnime?.panGesutre = panGesutre
        }
        
        self.transitioningDelegate = dismissAnime
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
}

extension PhotoGalleryController: UIGestureRecognizerDelegate
{
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            
            let translation = panGestureRecognizer.translation(in: panGestureRecognizer.view)
            let translationIsVertical = (translation.y > 0) && (abs(translation.y) > abs(translation.x))
            
            return translationIsVertical
        }
        
        return true
    }
    
}
