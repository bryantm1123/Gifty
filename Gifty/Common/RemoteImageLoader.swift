//
//  RemoteImageLoader.swift
//  Gifty
//
//  Created by Matt Bryant on 6/13/21.
//

import Foundation
import UIKit

protocol RemoteImageLoader {
    var imageLoader: ImageLoader { get }
    
    func loadAnimatedImageFrom(urlString: String, on view: UIView)
}
