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
    private var pageLimit = 25
    private var currentPage = 1
    private var initialLoadPageCount = 25
    private var total = 10
    private var rating = "g" // this could be updated via a function powered by a filter option on the feed view controller. but for now, just hard-coding to family friendly content
    
    
    init(with service: TrendingService, delegate: GifDeliveryDelegate) {
        self.trendingService = service
        self.gifDeliveryDelegate = delegate
    }
    
    func getTrendingGifs(_ onInitialLoad: Bool = false) {
        // TODO: increment initial load batch
        trendingService?.getTrending(with: pageLimit, page: currentPage, rating: rating, completion: { result in
            switch result {
            case .success(let response):
                self.gifs.append(contentsOf: response.data)
                self.gifDeliveryDelegate?.didReceiveGifs(with: nil)
            case .failure(_ ):
                self.gifDeliveryDelegate?.didReceiveError()
            }
        })
    }
    
}

protocol GifDeliveryDelegate: AnyObject {
    func didReceiveGifs(with newIndexPathsToReload: [IndexPath]?)
    func didReceiveError()
}
