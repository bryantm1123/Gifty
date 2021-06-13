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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .black
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        gifImageView.animatedImage = nil
    }
    
    public func configure(with imageUrl : URL) {
        if let data = try? Data(contentsOf: imageUrl) {
            let animatedData = FLAnimatedImage(animatedGIFData: data)
            DispatchQueue.main.async { [weak self] in
                self?.gifImageView.animatedImage = animatedData
            }
        }
    }
    
}
