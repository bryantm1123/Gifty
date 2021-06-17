//
//  GifFeedViewController.swift
//  Gifty
//
//  Created by Matt Bryant on 6/11/21.
//

import UIKit
import FLAnimatedImage

class GifFeedViewController: UICollectionViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    private let reuseIdentifier: String  = "GifCell"
    private let sectionInsets: UIEdgeInsets = UIEdgeInsets(
      top: 5.0,
      left: 20.0,
      bottom: 5.0,
      right: 20.0)
    
    
    var presenter: GifFeedPresenter?
    var service: TrendingGifService = TrendingGifService()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Gifty"
        collectionView.prefetchDataSource = self
        
        activityIndicator.startAnimating()
        presenter = GifFeedPresenter(with: service, delegate: self)
        presenter?.getTrendingGifs()
    }

}

// MARK: DataSource
extension GifFeedViewController {
      
      override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter?.totalCount ?? 0
      }
      
      override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier:reuseIdentifier, for:indexPath) as? GifCell else {
            return UICollectionViewCell()
        }
        
        if !isLoadingCell(for: indexPath) {
            
            let gif = presenter?.gifs[indexPath.row]
            
            if let urlString = gif?.images.fixedWidth.url {
                loadAnimatedImageFrom(urlString: urlString, on: cell)
            }
        }
        
        return cell
      }
}

// MARK: Prefetching delegate
extension GifFeedViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        // Go ahead and pre-fetch next page photos
        // when we get to the loading cell
        if indexPaths.contains(where: isLoadingCell) {
            presenter?.getTrendingGifs()
        }
    }
}

// MARK: Gif item selection
extension GifFeedViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let gif = presenter?.gifs[indexPath.row]
    
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let detailVC = storyboard.instantiateViewController(identifier: "DetailViewController") as? DetailViewController else { return }
        detailVC.gif = gif
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: Flow Layout
extension GifFeedViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
      return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
      return sectionInsets.left
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
       
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
}

// MARK: GifDeliveryDelegate
extension GifFeedViewController: GifPresentationDelegate {
    
    func didReceiveGifs(with newIndexPathsToReload: [IndexPath]?) {
        DispatchQueue.main.async { [weak self] in
            
            if self?.activityIndicator.isAnimating ?? false { self?.activityIndicator.stopAnimating() }
            
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
        if activityIndicator.isAnimating { activityIndicator.stopAnimating() }
        let tryAgain = UIAlertAction(title: "Try Again", style: .default, handler: { action in
            self.presenter?.getTrendingGifs()
        })
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        showAlert(with: ErrorText.title, message: ErrorText.message, style: .alert, actions: [okAction, tryAgain])
    }
    
}

// MARK: Remote Image Loader
extension GifFeedViewController: ImageLoading {
    
    var imageLoader: ImageLoader {
        ImageLoader()
    }
    
    /// Loads an FLAnimatedImage from a remote url using the `ImageLoader` helper class
    /// Updates the cell's image view with the animated image retrieved
    /// - Parameters:
    ///   - urlString: The url string for the remote gif resource
    ///   - cell: The cell for the current index path which displays the gif
    func loadAnimatedImageFrom(urlString: String, on view: UIView) {
        guard let url = URL(string: urlString),
              let cell = view as? GifCell else { return }
        
        let token = imageLoader.loadImage(from: url, completion: { result in
            
            switch result {
            case .success(let image):
                DispatchQueue.main.async {
                    cell.gifImageView.animatedImage = image
                }
            case .failure(_):
                break // just leave the black background as placeholder
            }
        })
        
        cell.onReuse = {
            if let token = token {
                self.imageLoader.cancelLoad(for: token)
            }
        }
    }
}

// MARK: Prefetching utility functions
private extension GifFeedViewController {
    
    /// Determines if the current indexPath is beyond the current count of photos, ie the last cell
    /// - Parameter indexPath: The current index path to check
    /// - Returns: Boolean to indicate if index path is the loading cell
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.row >= presenter?.currentCount ?? 0
    }

    
    /// Calculates the collection view cells that need to be reloaded when receiving a new page
    /// by calculating the intersection of indexPaths passed in (as calculated by the presenter)
    /// with the visible indexPaths
    /// - Parameter indexPaths: Index paths that may need to be reloaded
    /// - Returns: the visible index paths to reload
   func visibleIndexPathsToReload(intersecting indexPaths: [IndexPath]) -> [IndexPath] {
        let indexPathsForVisibleRows = collectionView.indexPathsForVisibleItems
        let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)
        return Array(indexPathsIntersection)
   }
}