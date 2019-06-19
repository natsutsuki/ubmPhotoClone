//
//  GridViewController.swift
//  Photo Transitioning
//
//  Created by c.c on 2019/6/14.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import UIKit
import Photos

private let reuseIdentifier = "Cell"

class GridViewController: UICollectionViewController, UICollectionViewDataSourcePrefetching
{
    var fetchResult: PHFetchResult<PHAsset>!
    var imageManager: PHCachingImageManager!
    var queue: DispatchQueue!
    
    var assetSize: CGSize = CGSize.zero
    
    // MARK:
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "All Photos"
        view.backgroundColor = UIColor.white
        view.clipsToBounds = true
        
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        self.fetchResult = PHAsset.fetchAssets(with: options)
        
        self.imageManager = PHCachingImageManager()
        
        queue = DispatchQueue(label: "com.photo.prewarm", qos: .default, attributes: [.concurrent], autoreleaseFrequency: .inherit, target: nil)
        
        collectionView.register(GridCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.isPrefetchingEnabled = true
        collectionView.prefetchDataSource = self
        collectionView.backgroundColor = UIColor.clear
        
        setItemSize()
    }
    
    private func setItemSize() {
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        layout.sectionInset = UIEdgeInsets.zero
        
        let itemInfo = self.getGridItemSize(inBoundingSize: view.bounds.size)
        layout.minimumLineSpacing = CGFloat(itemInfo.lineSpacing)
        layout.itemSize = itemInfo.itemSize
        
        let scale = UIScreen.main.scale
        assetSize = CGSize(width: itemInfo.itemSize.width * scale, height: itemInfo.itemSize.height * scale)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        setItemSize()
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! GridCell
        
        let asset = fetchResult.object(at: indexPath.item)
        cell.assetIdentifier = asset.localIdentifier
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.isNetworkAccessAllowed = true
        
        self.imageManager.requestImage(for: asset, targetSize: self.assetSize, contentMode: .aspectFit, options: options) { (result, info) in
            if (cell.assetIdentifier == asset.localIdentifier) {
                cell.imageView.image = result
            }
        }
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let transitioningAsset = fetchResult.object(at: indexPath.item)
        let tgvc = PhotoGalleryController(transitioningAsset: transitioningAsset, fetchResult: fetchResult, imageManager: imageManager)
        tgvc.transitioningDelegate = self
        tgvc.modalPresentationStyle = .custom
        definesPresentationContext = true
        
        present(tgvc, animated: true, completion: nil)
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
    
}
