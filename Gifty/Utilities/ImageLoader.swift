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
    private var loadedImages = [URL : FLAnimatedImage]()
    private var runningRequests = [UUID : URLSessionDataTask]()
    
    
    /// Loads an FLAnimatedImage from a given url either from cache
    /// or from remote origin if the image does not exist in the cache
    /// - Parameters:
    ///   - url: the URL of the image asset
    ///   - completion: a result with either a successful FLAnimatedImage or failure error
    /// - Returns: An optional UUID of the current running data task that is fetching an image from the URL
    func loadImage(from url: URL, completion: @escaping ImageLoadCompletion) -> UUID? {
        
        // Check if image is already loaded using the url as a key
        // If so, call the completion handler and return nil
        // for the UUID since there is no active task to cancel
        if let image = loadedImages[url] {
            completion(.success(image))
            return nil
        }
        
        // Create a UUID to identify the task about to be created below
        let uuid = UUID()
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            // When the data task completes, it should be removed from the
            // running requests dictionary.
            // A `defer` statement is used here to remove the running task
            // before leaving the scope of the data task's completion handler.
            defer { self.runningRequests.removeValue(forKey: uuid) }
            
            // When the data task completes, we're able to extract an image
            // it is then stored in the in-memory cache
            // and completion is called with the loaded image
            if let dataReturned = data,
               let animatedData = FLAnimatedImage(animatedGIFData: dataReturned) {
                self.loadedImages[url] = animatedData
                completion(.success(animatedData))
                return
            }
            
            // If we get an error response,
            // check if it's due to the task being cancelled
            // if it is, do nothing
            // if the error is due to any other reason,
            // forward to the caller of loadImage()
            guard let errorResponse = error else {
                return
            }
            
            guard (errorResponse as NSError).code == NSURLErrorCancelled else {
                completion(.failure(errorResponse))
                return
            }
        }
        task.resume()
        
        // The data task is stored in the runningRequests dictionary
        // keyed by the UUID created above
        // and the UUID is returned to the caller of loadImage()
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
