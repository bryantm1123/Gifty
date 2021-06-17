//
//  FeedPresenter.swift
//  Gifty
//
//  Created by Matt Bryant on 6/12/21.
//

import Foundation

class GifFeedPresenter {
    
    var gifs: [GifRawData] = []
    
    private weak var gifPresentationDelegate: GifPresentationDelegate?
    private var trendingService: TrendingGifServicable?
    private var pageLimit: Int = 25
    private var currentPage: Int = 0
    private var total: Int = 25
    private var requestIsInProgress: Bool = false
    private var rating: ContentRating = .g // this could be updated via a function powered by a filter option on the feed view controller. but for now, just hard-coding to family friendly content
    
    
    init(with service: TrendingGifServicable, delegate: GifPresentationDelegate) {
        self.trendingService = service
        self.gifPresentationDelegate = delegate
    }
    
    /// Calculates the index paths for the last page of gifs received from the API.
    /// - Parameter newGifs: The last page of gifs received
    /// - Returns: The indexPaths to reload on the collection view
    private func calculateIndexPathsToReload(from newGifs: [GifRawData]) -> [IndexPath] {
        let startIndex = gifs.count - newGifs.count
        let endIndex = startIndex + newGifs.count
        return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
    }
}

extension GifFeedPresenter: GifFeedPresentable {
    var totalCount: Int { total }
    var currentCount: Int { gifs.count }
    
    func getTrendingGifs() {
        
        if requestIsInProgress {
            return
        } else {
            requestIsInProgress = true
        }
        
        trendingService?.getTrending(with: pageLimit, page: currentPage, rating: rating.rawValue, completion: { result in
            switch result {
            case .success(let response):
                
                // https://github.com/Giphy/GiphyAPI/issues/22
                // https://github.com/Giphy/GiphyAPI/issues/31
                // I'm not sure exactly what to take from the replies on
                // these two issues, but what I observed was an inconsistency
                // of the value returned for the pagination total count.
                // This led to a collection view internal inconsistency error,
                // as my pagination method depends on the total count, setting it as
                // the collection view number of items. When different values are returned,
                // it breaks the collection view's ability to reload at visible paths and just does a
                // full reload which makes the UI jumpy.
                // The following line is a hack to just get the total count from the first pagination
                // response and use it rather than updating the local total variable from each response
                // payload to keep the total count constant for the collection view's sake.
                if response.pagination.offset == 0 && response.pagination.totalCount > 0 {
                    self.total = response.pagination.totalCount
                }
                
                self.currentPage += 1
        
                self.requestIsInProgress = false
                
                // https://github.com/Giphy/GiphyAPI/issues/235
                // I noticed that the /trending API returns some duplicates
                // This temp fix below attempts to resolve duplicates within the same
                // paginated response, but doesn't resolve duplicates
                // in the master gif array.
                guard let uniqueNewGifs = Array(NSOrderedSet(array: response.data)) as? [GifRawData] else {
                    return
                }
                
                self.gifs.append(contentsOf: uniqueNewGifs)

                if response.pagination.offset > 0 {
                    let pathsToReload = self.calculateIndexPathsToReload(from: uniqueNewGifs)
                    self.gifPresentationDelegate?.didReceiveGifs(with: pathsToReload)
                } else {
                    self.gifPresentationDelegate?.didReceiveGifs(with: .none)
                }
            case .failure(_ ):
                self.requestIsInProgress = false
                self.gifPresentationDelegate?.didReceiveError()
            }
        })
    }
}
