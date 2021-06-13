//
//  DetailViewController.swift
//  Gifty
//
//  Created by Matt Bryant on 6/13/21.
//

import UIKit
import FLAnimatedImage

class DetailViewController: UIViewController, RemoteImageLoader {

    @IBOutlet weak var imageView: FLAnimatedImageView!
    @IBOutlet weak var closeButton: UIButton!
    
    var gif: GifRawData?
    var imageLoader: ImageLoader = ImageLoader()
    private var token: UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        
        loadAnimatedImageFrom(urlString: gif?.images.downsizedLarge.url ?? "", on: imageView)
        
    }
    
    func loadAnimatedImageFrom(urlString: String, on view: UIView) {
        guard let url = URL(string: urlString),
              let view = imageView else {
            return
        }
        
        let token = imageLoader.loadImage(from: url, completion: { result in

            self.token = token
            
            do {
                let image = try result.get()
                DispatchQueue.main.async {
                    view.animatedImage = image
                }
            } catch {
                // TODO: Handle error case
                // Here we could show a placeholder image.
                debugPrint(error)
            }
        })
        
    }
    
    @objc func closeTapped() {
        if let token = token {
            imageLoader.cancelLoad(for: token)
        }
        self.dismiss(animated: true, completion: nil)
    }

}
