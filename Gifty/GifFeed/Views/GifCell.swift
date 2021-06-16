//
//  GifCell.swift
//  Gifty
//
//  Created by Matt Bryant on 6/11/21.
//

import UIKit
import FLAnimatedImage

class GifCell: UICollectionViewCell {
    @IBOutlet weak var gifImageView: FLAnimatedImageView!
    
    var onReuse: () -> Void = {}
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        onReuse()
        gifImageView.animatedImage = nil
    }
    
}
