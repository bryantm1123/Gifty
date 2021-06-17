//
//  GifPresentationDelegate.swift
//  Gifty
//
//  Created by Matt Bryant on 6/16/21.
//

import Foundation

protocol GifPresentationDelegate: AnyObject {
    func didReceiveGifs(with newIndexPathsToReload: [IndexPath]?)
    func didReceiveError()
}
