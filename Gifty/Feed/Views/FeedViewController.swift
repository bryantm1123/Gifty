//
//  FeedViewController.swift
//  Gifty
//
//  Created by Matt Bryant on 6/11/21.
//

import UIKit
import FLAnimatedImage

class FeedViewController: UICollectionViewController {
    
    private let reuseIdentifier: String  = "GifCell"
    private let imageLoader: ImageLoader = ImageLoader()
    private let sectionInsets: UIEdgeInsets = UIEdgeInsets(
      top: 5.0,
      left: 10.0,
      bottom: 5.0,
      right: 10.0)
    
    
    var presenter: FeedPresenter?
    var service: TrendingService = TrendingService()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = FeedPresenter(with: service, delegate: self)
        presenter?.getTrendingGifs(true)
    }

}

// MARK: DataSource
extension FeedViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
      }
      
      override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter?.gifs.count ?? 0
      }
      
      override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier:reuseIdentifier, for:indexPath) as? GifCell else {
            return UICollectionViewCell()
        }
        
        
        let gif = presenter?.gifs[indexPath.row]
        
        if let urlString = gif?.images.fixedWidth.url {
            loadAnimatedGifFrom(urlString: urlString, cell)
        }
        
        return cell

      }
}

// MARK: Flow Layout
extension FeedViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
      return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
      return sectionInsets.left
    }
}

extension FeedViewController: GifDeliveryDelegate {
    
    func didReceiveGifs(with newIndexPathsToReload: [IndexPath]?) {
        DispatchQueue.main.async { [weak self] in
            // Reload the whole collection view the first time
            guard let pathsToReload = newIndexPathsToReload else {
                self?.collectionView.reloadData()
                return
            }
            // On subsequent fetches, reload only the index paths
            // for the new photos
            self?.collectionView.reloadItems(at: pathsToReload)
        }
    }
    
    func didReceiveError() {
        // TODO: Implement
    }
    
}

// MARK: Remote Image Loader
extension FeedViewController {
    
    /// Loads an FLAnimatedImage from a remote url using the `ImageLoader` helper class
    /// Updates the cell's image view with the animated image retrieved
    /// - Parameters:
    ///   - urlString: The url string for the remote gif resource
    ///   - cell: The cell for the current index path which displays the gif
    fileprivate func loadAnimatedGifFrom(urlString: String, _ cell: GifCell) {
        // load image from URL
        if let url = URL(string: urlString) {
            let token = imageLoader.loadImage(from: url, completion: { result in
                
                do {
                    // Extract the result from the
                    // completion handler
                    let image = try result.get()
                    
                    // If image extracted, dispatch
                    // to main queue for updating cell
                    DispatchQueue.main.async {
                        cell.gifImageView.animatedImage = image
                    }
                } catch {
                    // TODO: Handle error case
                    // Here we could show a placeholder image.
                    debugPrint(error)
                }
            })
            
            // Cancel the data task when the cell is reused
            // if the image is in cache
            cell.onReuse = {
                if let token = token {
                    self.imageLoader.cancelLoad(for: token)
                }
            }
        }
    }
}
