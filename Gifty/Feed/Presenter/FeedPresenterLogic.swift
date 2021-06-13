//
//  FeedPresenterLogic.swift
//  Gifty
//
//  Created by Matt Bryant on 6/13/21.
//

import Foundation

protocol FeedPresenterLogic {
    var gifs: [GifRawData] { get }
    func getTrendingGifs()
}
