//
//  TrendingServiceTests.swift
//  GiftyTests
//
//  Created by Matt Bryant on 6/11/21.
//

import XCTest
@testable import Gifty

class TrendingServiceTests: XCTestCase, ServiceResponseStubber {
    
    var sut: TrendingGifService?
    var mockRequestHandler: MockRequestHandler?
    let sampleResponseFile = "SampleTrendingResponse"
    

    override func setUpWithError() throws {
        mockRequestHandler = MockRequestHandler()
        sut = TrendingGifService(with: mockRequestHandler!)
    }

    override func tearDownWithError() throws {
        sut = nil
        mockRequestHandler = nil
    }

    func testDecodingOfSuccessfulResponse() throws {
        // Arrange
        let idExpected = "blSTtZehjAZ8I"
        mockRequestHandler?.response = getStubResponse(with: 200)
        mockRequestHandler?.data = getStubData(fileName: sampleResponseFile, fileType: .json, in: Bundle(for: type(of: self)))
        
        // Act
        sut?.getTrending(with: 25, page: 1, rating: "g", completion: { result in
            switch result {
                // Assert
                case .success(let response):
                    XCTAssertEqual(response.data.first?.id, idExpected)
                case .failure(let error):
                    XCTAssertNil(error)
            }
        })
    }
    
    func testNetworkErrorOnNon200Response() throws {
        // Arrange
        let errorExpected = TrendingServiceError.networkError
        mockRequestHandler?.response = getStubResponse(with: 400)
        mockRequestHandler?.data = "".data(using: .utf8)!
        
        // Act
        sut?.getTrending(with: 25, page: 1, rating: "g", completion: { result in
            switch result {
                // Assert
                case .success(let response):
                    XCTAssertNil(response)
                case .failure(let error):
                    XCTAssertEqual(error as! TrendingServiceError, errorExpected)
            }
        })
        
    }
    
    func testDecodingErrorWithMalformedPayload() throws {
        // Arrange
        let errorExpected = TrendingServiceError.decodingError
        mockRequestHandler?.response = getStubResponse(with: 200)
        mockRequestHandler?.data = "malformedPayload".data(using: .utf8)!
        
        // Act
        sut?.getTrending(with: 25, page: 1, rating: "g", completion: { result in
            switch result {
                // Assert
                case .success(let response):
                    XCTAssertNil(response)
                case .failure(let error):
                    XCTAssertEqual(error as! TrendingServiceError, errorExpected)
            }
        })
    }
    
    func testBuildsValidURL() throws {
        // Arrange
        let expectedURL = URL(string: "https://api.giphy.com/v1/gifs/trending?api_key=hUcbhS733eX7Z7b0fAIqD3in28886B7H&limit=25&rating=g&offset=1")
        
        // Act
        guard let url = sut?.buildURL(with: 25, page: 1, rating: "g") else {
            XCTFail("Failed to build url")
            return
        }
        
        // Assert
        XCTAssertEqual(url, expectedURL)
    }

}
