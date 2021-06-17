//
//  NetworkRequestHandling.swift
//  Gifty
//
//  Created by Matt Bryant on 6/16/21.
//

import Foundation

protocol NetworkRequestHandling {
    typealias Handler = (Data?, URLResponse?, Error?) -> Void
    
    func performRequest(for url: URL, completionHandler: @escaping Handler)
    
    func performRequest(with request: URLRequest, completionHandler: @escaping Handler)
}

extension URLSession: NetworkRequestHandling {
    
    func performRequest(for url: URL, completionHandler: @escaping Handler) {
        let task = dataTask(with: url, completionHandler: completionHandler)
        task.resume()
    }
    
    func performRequest(with request: URLRequest, completionHandler: @escaping Handler) {
        let task = dataTask(with: request, completionHandler: completionHandler)
        task.resume()
    }
}
