//
//  GifFeedPresenterIntegrationTests.swift
//  GiftyTests
//
//  Created by Matt Bryant on 6/13/21.
//

import XCTest
@testable import Gifty

class GifFeedPresenterIntegrationTests: XCTestCase, ServiceResponseStubber {
    
    var sut: GifFeedPresenter?
    var service: TrendingGifService?
    var mockRequestHandler: MockRequestHandler?
    var didReceiveGifsWasCalled: Bool = false
    var didReceiveErrorWasCalled: Bool = false
    let sampleResponseFile = "SampleTrendingResponse"
    let apiKey = "xyz123"
    let baseURL = "api.giphy.com"
    

    override func setUpWithError() throws {
        mockRequestHandler = MockRequestHandler()
        service = TrendingGifService(with: mockRequestHandler!, apiKey: apiKey, baseUrl: baseURL)
        sut = GifFeedPresenter(with: service!, delegate: self)
    }

    override func tearDownWithError() throws {
        service = nil
        sut = nil
    }

    func testDidReceiveGifsWasCalledOnSuccessfulResponse() throws {
        // Arrange
        mockRequestHandler?.response = getStubResponse(with: 200)
        mockRequestHandler?.data = getStubData(fileName: sampleResponseFile, fileType: .json, in: Bundle(for: type(of: self)))
        
        // Act
        sut?.getTrendingGifs()
        
        // Assert
        XCTAssertTrue(didReceiveGifsWasCalled)
        XCTAssertFalse(didReceiveErrorWasCalled)
    }
    
    func testDidReceiveErrorWasCalledOnFailedResponse() throws {
        // Arrange
        mockRequestHandler?.response = getStubResponse(with: 400)
        mockRequestHandler?.data = "".data(using: .utf8)!
        
        // Act
        sut?.getTrendingGifs()
        
        // Assert
        XCTAssertTrue(didReceiveErrorWasCalled)
        XCTAssertFalse(didReceiveGifsWasCalled)
    }

}

extension GifFeedPresenterIntegrationTests: GifPresentationDelegate {
    
    func didReceiveGifs(with newIndexPathsToReload: [IndexPath]?) {
        didReceiveGifsWasCalled = true
    }
    
    func didReceiveError() {
        didReceiveErrorWasCalled = true
    }
}
