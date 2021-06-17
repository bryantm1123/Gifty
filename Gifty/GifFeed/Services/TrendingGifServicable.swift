//
//  TrendingGifServicable.swift
//  Gifty
//
//  Created by Matt Bryant on 6/16/21.
//

import Foundation

protocol TrendingGifServicable {
    typealias TrendingServiceCompletion = (Result<TrendingGifResponse, Error>) -> Void
    
    func getTrending(with pageCount: Int, page: Int, rating: String?, completion: @escaping TrendingServiceCompletion)
    
    func buildURL(with pageCount: Int, page: Int, rating: String?) -> URL?
}
