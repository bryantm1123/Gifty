//
//  FeedPresenter.swift
//  Gifty
//
//  Created by Matt Bryant on 6/12/21.
//

import Foundation

protocol FeedPresenterLogic {
    var gifs: [GifRawData] { get }
}

class FeedPresenter: FeedPresenterLogic {
    
    var gifs: [GifRawData] = []
    
    private weak var gifDeliveryDelegate: GifDeliveryDelegate?
    private var trendingService: TrendingService?
    private var pageLimit: Int = 25
    private var currentPage: Int = 0
    private var initialLoadPageCount: Int = 25
    private var total: Int = 25
    private var isRequestInProgress: Bool = false
    private var rating = "g" // this could be updated via a function powered by a filter option on the feed view controller. but for now, just hard-coding to family friendly content
    
    var totalCount: Int { total }
    var currentCount: Int { gifs.count }
    
    
    init(with service: TrendingService, delegate: GifDeliveryDelegate) {
        self.trendingService = service
        self.gifDeliveryDelegate = delegate
    }
    
    func getTrendingGifs(_ onInitialLoad: Bool = false) {
        
        guard !isRequestInProgress else { return }
        
        
        // TODO: increment initial load batch
        trendingService?.getTrending(with: pageLimit, page: currentPage, rating: rating, completion: { result in
            switch result {
            case .success(let response):
                self.currentPage += 1
            
                self.total = response.pagination.totalCount
                self.isRequestInProgress = false
                
                // https://github.com/Giphy/GiphyAPI/issues/235
                // The /trending API returns a lot of duplicates
                // This temp fix below will resolve duplicates within the same
                // paginated response, but doesn't resolve duplicates
                // in the array as a whole.
                guard let uniqueNewGifs = Array(NSOrderedSet(array: response.data)) as? [GifRawData] else { return }
                self.gifs.append(contentsOf: uniqueNewGifs)

                if response.pagination.offset > 0 {
                    let pathsToReload = self.calculateIndexPathsToReload(from: uniqueNewGifs)
                    self.gifDeliveryDelegate?.didReceiveGifs(with: pathsToReload)
                } else {
                    self.gifDeliveryDelegate?.didReceiveGifs(with: .none)
                }
            case .failure(_ ):
                self.gifDeliveryDelegate?.didReceiveError()
            }
        })
    }
    
    /// Calculates the index paths for the last page of photos received from the API.
    /// - Parameter newPhotos: The last page of photos received
    /// - Returns: The indexPaths to reload on the collection view
    private func calculateIndexPathsToReload(from newGifs: [GifRawData]) -> [IndexPath] {
        let startIndex = gifs.count - newGifs.count
        let endIndex = startIndex + newGifs.count
        return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
    }
    
}

protocol GifDeliveryDelegate: AnyObject {
    func didReceiveGifs(with newIndexPathsToReload: [IndexPath]?)
    func didReceiveError()
}
