//
//  FeedPresenterTests.swift
//  GiftyTests
//
//  Created by Matt Bryant on 6/13/21.
//

import XCTest
@testable import Gifty

class FeedPresenterTests: XCTestCase, ServiceResponseStubber {
    
    var sut: FeedPresenter?
    var service: TrendingService?
    var didReceiveGifsWasCalled: Bool = false
    var didReceiveErrorWasCalled: Bool = false
    let sampleResponseFile = "SampleTrendingResponse"
    var expectation: XCTestExpectation?
    

    override func setUpWithError() throws {
        service = TrendingService(with: MockURLProtocol.session)
        sut = FeedPresenter(with: service!, delegate: self)
        expectation = XCTestExpectation(description: "Wait for mock service completion.")
    }

    override func tearDownWithError() throws {
        service = nil
        sut = nil
        expectation = nil
    }

    func testDidReceiveGifsWasCalledOnSuccessfulResponse() throws {
        // Arrange
        MockURLProtocol.requestHandler = { [self] mockRequest in
            let response = getMockResponse(with: 200)
            let data = getMockData(fileName: sampleResponseFile, fileType: .json, in: Bundle(for: type(of: self)))
            return (response, data)
        }
        let timeToWait = 2.0
        
        // Act
        sut?.getTrendingGifs()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + timeToWait, execute: {
            self.expectation?.fulfill()
        })
        
        wait(for: [expectation!], timeout: timeToWait + 2.0)
        
        // Then
        XCTAssertTrue(didReceiveGifsWasCalled)
        XCTAssertFalse(didReceiveErrorWasCalled)
    }
    
    func testDidReceiveErrorWasCalledOnFailedResponse() throws {
        // Arrange
        MockURLProtocol.requestHandler = { [self] mockRequest in
            let response = getMockResponse(with: 400)
            let data = "".data(using: .utf8)!
            return (response, data)
        }
        let timeToWait = 2.0
        
        // Act
        sut?.getTrendingGifs()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + timeToWait, execute: {
            self.expectation?.fulfill()
        })
        
        wait(for: [expectation!], timeout: timeToWait + 2.0)
        
        // Then
        XCTAssertTrue(didReceiveErrorWasCalled)
        XCTAssertFalse(didReceiveGifsWasCalled)
    }

}

extension FeedPresenterTests: GifDeliveryDelegate {
    
    func didReceiveGifs(with newIndexPathsToReload: [IndexPath]?) {
        didReceiveGifsWasCalled = true
    }
    
    func didReceiveError() {
        didReceiveErrorWasCalled = true
    }
}
