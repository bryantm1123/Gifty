//
//  APIConfigModel.swift
//  Gifty
//
//  Created by Matt Bryant on 6/17/21.
//

import Foundation

struct APIConfigModel {
    static let apiKey: String? = Bundle.main.object(forInfoDictionaryKey: "API_Key") as? String
    static let baseUrl: String? = Bundle.main.object(forInfoDictionaryKey: "API_Base_URL") as? String
}
