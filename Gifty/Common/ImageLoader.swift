//
//  ImageLoader.swift
//  Gifty
//
//  Created by Matt Bryant on 6/12/21.
//

import Foundation
import UIKit
import FLAnimatedImage


/// A class to assist with asynchronously loading animated images from remote URLs
///
/// Implementation  adapted from Donny Wals: https://www.donnywals.com/efficiently-loading-images-in-table-views-and-collection-views/
class ImageLoader {
    
    private var cachedImages = NSCache<NSURL, FLAnimatedImage>()
    private var runningRequests = [UUID : URLSessionDataTask]()
    
    init() {
        cachedImages.countLimit = 300
    }
    
    
    /// Loads an FLAnimatedImage from a given url either from cache
    /// or from remote origin if the image does not exist in the cache
    /// - Parameters:
    ///   - url: the URL of the image asset
    ///   - completion: a result with either a successful FLAnimatedImage or failure error
    /// - Returns: An optional UUID of the current running data task that is fetching an image from the URL
    func loadImage(from url: URL, completion: @escaping ImageLoadCompletion) -> UUID? {
        
        if let image = cachedImages.object(forKey: url as NSURL) {
            completion(.success(image))
            return nil
        }
        
        // Create a UUID to identify the task about to be created below
        let uuid = UUID()
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            defer {
                if self.runningRequests.contains(where: {$0.key == uuid}) {
                    self.runningRequests.removeValue(forKey: uuid)
                }
            }
            
            if let dataReturned = data,
               let animatedData = FLAnimatedImage(animatedGIFData: dataReturned) {
                self.cachedImages.setObject(animatedData, forKey: url as NSURL)
                completion(.success(animatedData))
            }
            
            if let errorResponse = error,
               (errorResponse as NSError).code == NSURLErrorCancelled {
                completion(.failure(errorResponse))
            }
            
        }
        task.resume()
        
        runningRequests[uuid] = task
        return uuid
    }
    
    
    /// Cancels the data task for fetching an image
    /// - Parameter uuid: The UUID associated with the task to cancel
    func cancelLoad(for uuid: UUID) {
        runningRequests[uuid]?.cancel()
        runningRequests.removeValue(forKey: uuid)
    }
}

typealias ImageLoadCompletion = (Result<FLAnimatedImage, Error>) -> Void
