/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    GridCell is a basic UICollectionViewCell sublass to display a photo.
*/

import UIKit

class GridCell: UICollectionViewCell {
    
    var assetIdentifier: String = ""
    var imageView: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView = UIImageView(frame: CGRect(origin: CGPoint.zero, size: frame.size))
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        backgroundView = imageView
        backgroundColor = UIColor.black
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil;
        assetIdentifier = ""
    }
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                imageView.alpha = 0.6
            }
            else {
                imageView.alpha = 1
            }
        }
    }
    
}
