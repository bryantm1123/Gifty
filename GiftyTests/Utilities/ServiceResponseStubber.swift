//
//  ServiceResponseStubber.swift
//  GiftyTests
//
//  Created by Matt Bryant on 6/11/21.
//

import Foundation

protocol ServiceResponseStubber {
    func getStubData(fileName: String, fileType: FileType, in bundle: Bundle) -> Data
    func getStubResponse(with statusCode: Int) -> HTTPURLResponse
    var stubError: Error { get }
}

extension ServiceResponseStubber {
    func getStubData(fileName: String, fileType: FileType, in bundle: Bundle) -> Data {
        if let path = bundle.path(forResource: fileName, ofType: fileType.rawValue) {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                return data
            } catch let error {
                print(error)
            }
            
        }
        return Data()
    }
    
    func getStubResponse(with statusCode: Int) -> HTTPURLResponse {
        return HTTPURLResponse(url: URL(string: "my/api")!, statusCode: statusCode, httpVersion: "", headerFields: nil)!
    }
    
    var stubError: Error {
        NSError(domain: "stub", code: 0, userInfo: nil) as Error
    }
}

enum FileType: String {
    case json = "json"
}
