//
//  MockRequestHandler.swift
//  GiftyTests
//
//  Created by Matt Bryant on 6/16/21.
//

import Foundation
@testable import Gifty

class MockRequestHandler: NetworkRequestHandling {
    
    var data: Data?
    var response: URLResponse?
    var error: Error?
    
    func performRequest(for url: URL, completionHandler: @escaping Handler) {
        completionHandler(data, response, error)
    }
    
    func performRequest(with request: URLRequest, completionHandler: @escaping Handler) {
        completionHandler(data, response, error)
    }
    
    
}
