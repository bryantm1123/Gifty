//
//  TrendingGifResponse.swift
//  Gifty
//
//  Created by Matt Bryant on 6/11/21.
//

import Foundation

// MARK: - TrendingResponse
struct TrendingGifResponse: Codable {
    let data: [GifRawData]
    let pagination: Pagination
}

// MARK: - GifRawData
struct GifRawData: Codable {
    let type: String
    let id: String
    let url: String
    let username: String
    let source: String
    let title: String
    let rating: String
    let contentURL:String
    let images: Images

    enum CodingKeys: String, CodingKey {
        case type
        case id
        case url
        case username
        case source
        case title
        case rating
        case contentURL = "content_url"
        case images
    }
}

// MARK: - Images
struct Images: Codable {
    let original: FixedHeight
    let downsized: The480_WStill
    let downsizedLarge: The480_WStill
    let downsizedMedium: The480_WStill
    let downsizedSmall: DownsizedSmall
    let fixedHeight: FixedHeight
    let fixedHeightDownsampled: FixedHeight
    let fixedHeightSmall: FixedHeight
    let fixedWidth: FixedHeight
    let fixedWidthDownsampled: FixedHeight
    let fixedWidthSmall: FixedHeight
    let originalMp4: DownsizedSmall
    let preview: DownsizedSmall

    enum CodingKeys: String, CodingKey {
        case original
        case downsized
        case downsizedLarge = "downsized_large"
        case downsizedMedium = "downsized_medium"
        case downsizedSmall = "downsized_small"
        case fixedHeight = "fixed_height"
        case fixedHeightDownsampled = "fixed_height_downsampled"
        case fixedHeightSmall = "fixed_height_small"
        case fixedWidth = "fixed_width"
        case fixedWidthDownsampled = "fixed_width_downsampled"
        case fixedWidthSmall = "fixed_width_small"
        case originalMp4 = "original_mp4"
        case preview
    }
}

// MARK: - The480_WStill
struct The480_WStill: Codable {
    let height, width, size: String
    let url: String
}

// MARK: - DownsizedSmall
struct DownsizedSmall: Codable {
    let height, width, mp4Size: String
    let mp4: String

    enum CodingKeys: String, CodingKey {
        case height, width
        case mp4Size = "mp4_size"
        case mp4
    }
}

// MARK: - FixedHeight
struct FixedHeight: Codable {
    let height, width, size: String
    let url: String
    let mp4Size: String?
    let mp4: String?
    let webpSize: String
    let webp: String
    let frames, hash: String?

    enum CodingKeys: String, CodingKey {
        case height, width, size, url
        case mp4Size = "mp4_size"
        case mp4
        case webpSize = "webp_size"
        case webp, frames, hash
    }
}

// MARK: - Pagination
struct Pagination: Codable {
    let totalCount: Int
    let count: Int
    let offset: Int

    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case count, offset
    }
}
