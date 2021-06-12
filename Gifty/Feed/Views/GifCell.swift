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
    
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    public func configure(with imageUrl : URL) {
            if let data = try? Data(contentsOf: imageUrl) {
                let animatedData = FLAnimatedImage(animatedGIFData: data)
                gifImageView.animatedImage = animatedData
            }
        }
}
