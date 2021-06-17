//
//  FeedPresenterLogic.swift
//  Gifty
//
//  Created by Matt Bryant on 6/13/21.
//

import Foundation

protocol GifFeedPresentable {
    var gifs: [GifRawData] { get }
    var totalCount: Int { get }
    var currentCount: Int { get }
    
    func getTrendingGifs()
}
