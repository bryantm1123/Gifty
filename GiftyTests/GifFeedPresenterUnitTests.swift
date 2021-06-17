//
//  GifFeedPresenterUnitTests.swift
//  GiftyTests
//
//  Created by Matt Bryant on 6/16/21.
//

import XCTest
@testable import Gifty

class GifFeedPresenterUnitTests: XCTestCase {
    
    var sut: GifFeedPresenter?
    var serviceMock: TrendingServiceMock?
    var didReceiveGifsWasCalled = false
    var didReceiveErrorWasCalled = false
    

    override func setUpWithError() throws {
        serviceMock = TrendingServiceMock()
        sut = GifFeedPresenter(with: serviceMock!, delegate: self)
    }

    override func tearDownWithError() throws {
        serviceMock = nil
        sut = nil
    }

    func testDidReceiveGifsWasCalledOnSuccessfulResponse() throws {
        // Arrange
        serviceMock?.shouldReturnSuccess = true
        
        // Act
        sut?.getTrendingGifs()
        
        // Assert
        XCTAssertTrue(didReceiveGifsWasCalled)
        XCTAssertFalse(didReceiveErrorWasCalled)
    }
    
    func testDidReceiveErrorWasCalledOnErrorResponse() throws {
        // Arrange
        serviceMock?.shouldReturnSuccess = false
        
        // Act
        sut?.getTrendingGifs()
        
        // Assert
        XCTAssertTrue(didReceiveErrorWasCalled)
        XCTAssertFalse(didReceiveGifsWasCalled)
    }

}

extension GifFeedPresenterUnitTests: GifPresentationDelegate {
    
    func didReceiveGifs(with newIndexPathsToReload: [IndexPath]?) {
        didReceiveGifsWasCalled = true
    }
    
    func didReceiveError() {
        didReceiveErrorWasCalled = true
    }
}

class TrendingServiceMock: TrendingGifServicable {
    
    let sampleResponseFile = "SampleTrendingResponse"
    var shouldReturnSuccess: Bool = false
    
    func getTrending(with pageCount: Int, page: Int, rating: String?, completion: @escaping TrendingServiceCompletion) {
        if shouldReturnSuccess {
            completion(.success(getSuccessData()!))
        } else {
            completion(.failure(stubError))
        }
    }
    
    func buildURL(with pageCount: Int, page: Int, rating: String?) -> URL? {
        return URL(string: "\(pageCount)")
    }
    
    func getSuccessData() -> TrendingGifResponse? {
        let data = getStubData(fileName: sampleResponseFile, fileType: .json, in: Bundle(for: type(of: self)))
        do {
            let decoded = try JSONDecoder().decode(TrendingGifResponse.self, from: data)
            return decoded
        } catch _ as NSError {
            return nil
        }
    }
}

extension TrendingServiceMock: ServiceResponseStubber {}
