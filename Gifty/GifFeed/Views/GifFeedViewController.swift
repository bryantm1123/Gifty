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

    private let sectionInsets: UIEdgeInsets = UIEdgeInsets(
      top: 5.0,
      left: 20.0,
      bottom: 5.0,
      right: 20.0)
    
    
    var presenter: GifFeedPresenter?
    var service: TrendingGifService = TrendingGifService(apiKey: APIConfigModel.apiKey, baseUrl: APIConfigModel.baseUrl)
    var dataSource: GifFeedDataSource?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Gifty"
        
        activityIndicator.startAnimating()
        presenter = GifFeedPresenter(with: service, delegate: self)
        dataSource = GifFeedDataSource(with: presenter!)
        collectionView.dataSource = dataSource
        collectionView.prefetchDataSource = dataSource
        presenter?.getTrendingGifs()
    }

}

// MARK: Flow Layout
extension GifFeedViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfSpacingColumns: CGFloat = 4.0
        return CGSize(width: self.view.frame.width / numberOfSpacingColumns, height: self.view.frame.width / numberOfSpacingColumns)
    }
    
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

// MARK: GifPresentationDelegate
extension GifFeedViewController: GifPresentationDelegate {
    
    func didReceiveGifs(with newIndexPathsToReload: [IndexPath]?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            self.activityIndicator.stopAnimating()
            
            if let pathsToReload = newIndexPathsToReload {
                let visiblePaths = self.visibleIndexPathsToReload(intersecting: pathsToReload)
                self.collectionView.reloadItems(at: visiblePaths)
            } else {
                self.collectionView.reloadData()
            }
        }
    }
    
    func didReceiveError() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            self.activityIndicator.stopAnimating()
            let tryAgain = UIAlertAction(title: "Try Again", style: .default, handler: { action in
                self.presenter?.getTrendingGifs()
            })
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            self.showAlert(with: ErrorText.title, message: ErrorText.message, style: .alert, actions: [okAction, tryAgain])
        }
    }
}

// MARK: Reload Visible Paths
private extension GifFeedViewController {
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

// MARK: Gif item selection/Navigation to Detail View Controller
extension GifFeedViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // WIP: Occasionally, tapping a gif leads to a different gif shown
        // in the detail view. It seems to be an indexing problem, but I'm
        // not entirely sure of the root cause just yet.
        let gif = presenter?.gifs[indexPath.row]
    
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let detailVC = storyboard.instantiateViewController(identifier: "DetailViewController") as? DetailViewController else { return }
        detailVC.gif = gif
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
