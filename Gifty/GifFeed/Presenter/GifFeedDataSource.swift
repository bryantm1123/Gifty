//
//  GifFeedDataSource.swift
//  Gifty
//
//  Created by Matt Bryant on 6/17/21.
//

import Foundation
import UIKit

class GifFeedDataSource: NSObject {
    
    private var presenter: GifFeedPresentable?
    private let reuseIdentifier: String  = "GifCell"
    
    init(with presenter: GifFeedPresentable) {
        self.presenter = presenter
    }
    
    /// Determines if the current indexPath is beyond the current count of photos, ie the last cell
    /// - Parameter indexPath: The current index path to check
    /// - Returns: Boolean to indicate if index path is the loading cell
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.row >= presenter?.currentCount ?? 0
    }
    
}

// MARK: CollectionView DataSource 
extension GifFeedDataSource: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        presenter?.totalCount ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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

// MARK: Prefetching DataSource
extension GifFeedDataSource: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
    
        if indexPaths.contains(where: isLoadingCell) {
            presenter?.getTrendingGifs()
        }
    }
}

// MARK: Remote Image Loading
extension GifFeedDataSource: ImageLoading {
    
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
              let cell = view as? GifCell else {
            return
        }
        
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
