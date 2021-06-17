//
//  TrendingGifService.swift
//  Gifty
//
//  Created by Matt Bryant on 6/11/21.
//

import Foundation

/// Calls the Giphy /trending endpoint
class TrendingGifService {
    
    private var requestHandler: NetworkRequestHandling?
    private var apiKey: String?
    private var baseURL: String?
    
    init(with requestHandler: NetworkRequestHandling = URLSession.shared, apiKey: String?, baseUrl: String?) {
        self.requestHandler = requestHandler
        self.apiKey = apiKey
        self.baseURL = baseUrl
    }

    private func decodeResponse(from data: Data) -> TrendingGifResponse? {
        do {
            let decoded = try JSONDecoder().decode(TrendingGifResponse.self, from: data)
            return decoded
        } catch _ as NSError {
            return nil
        }
    }
}

extension TrendingGifService: TrendingGifServicable {
    
    func getTrending(with pageCount: Int, page: Int, rating: String?, completion: @escaping TrendingServiceCompletion) {
        guard let url = buildURL(with: pageCount, page: page, rating: rating) else {
            completion(.failure(TrendingServiceError.malformedURL))
            return
        }
        
        requestHandler?.performRequest(for: url, completionHandler: { (data, response, error) in
            guard let validResponse = response,
                  let code = (validResponse as? HTTPURLResponse)?.statusCode,
                  code == 200,
                  let dataReturned = data else {
                completion(.failure(TrendingServiceError.networkError))
                return
            }
            
            guard let decoded = self.decodeResponse(from: dataReturned) else {
                completion(.failure(TrendingServiceError.decodingError))
                return
            }
            
            completion(.success(decoded))
        })
    }
    
    
    func buildURL(with pageCount: Int, page: Int, rating: String?) -> URL? {
    
        var components = URLComponents()
            components.scheme = "https"
            components.host = baseURL
            components.path = "/v1/gifs/trending"
            components.queryItems = [
                URLQueryItem(name: "api_key", value: apiKey),
                URLQueryItem(name: "limit", value: "\(pageCount)"),
                URLQueryItem(name: "rating", value: rating),
                URLQueryItem(name: "offset", value: "\(page)")
            ]
        
        return components.url
    }
}

enum TrendingServiceError: Error {
    case malformedURL
    case networkError
    case decodingError
}
