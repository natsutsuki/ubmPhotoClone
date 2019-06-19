//
//  PhotoGalleryCell.swift
//  ubmPhotoClone
//
//  Created by c.c on 2019/6/19.
//  Copyright © 2019 c.c. All rights reserved.
//

import UIKit

class PhotoGalleryCell: UICollectionViewCell, UIScrollViewDelegate
{

    @IBOutlet weak var scrollView: UIScrollView!
    var imageView: UIImageView!
    
    var assetIdentifier: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        scrollView.contentSize = bounds.size
        
        imageView = UIImageView(frame: CGRect(origin: CGPoint.zero, size: frame.size))
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        
        scrollView.addSubview(imageView)
        contentView.addSubview(scrollView)
        
        /* setup GestureRecognizer */
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapAction))
        doubleTap.numberOfTapsRequired = 2
        self.addGestureRecognizer(doubleTap)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        scrollView.contentSize = bounds.size
    }
    
    @objc func doubleTapAction(_ recognizer: UITapGestureRecognizer) {
        if (scrollView.zoomScale > scrollView.minimumZoomScale) {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
        }
    }
    
    func config(image:UIImage) {
        imageView.image = image
        
        // 根据scaleAspectFit的特性，算出image被缩放的倍数
        let scale: CGFloat
        if image.size.width > image.size.height {
            scale = image.size.width / bounds.width
        } else {
            scale = image.size.height / bounds.height
        }
        
        scrollView.maximumZoomScale = scale
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil;
        assetIdentifier = ""
        scrollView.maximumZoomScale = 1
    }

}
