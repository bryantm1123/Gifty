//
//  DetailViewController.swift
//  Gifty
//
//  Created by Matt Bryant on 6/13/21.
//

import UIKit
import FLAnimatedImage

class DetailViewController: UIViewController {

    @IBOutlet weak var imageView: FLAnimatedImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var gif: GifRawData?
    private var token: UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.startAnimating()
        
        loadAnimatedImageFrom(urlString: gif?.images.downsizedLarge.url ?? "", on: imageView)
        
    }
    
    func showError() {
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { action in
            self.navigationController?.popViewController(animated: true)
        })
        showAlert(with: ErrorText.title, message: ErrorText.message, style: .alert, actions: [okAction])
    }
}

extension DetailViewController: ImageLoading {
    
    var imageLoader: ImageLoader {
        ImageLoader()
    }
    
    func loadAnimatedImageFrom(urlString: String, on view: UIView) {
        guard let url = URL(string: urlString),
              let view = imageView else {
            showError()
            return
        }
        
        token = imageLoader.loadImage(from: url, completion: { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
                case .success(let image):
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        view.animatedImage = image
                    }
                case .failure(_):
                    DispatchQueue.main.async {
                        self.showError()
                    }
                }
        })
        
    }
}
