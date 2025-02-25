//
//  BingImageSearchResponse.swift
//  GifMakerSwift
//
//  Created by Mohammad Noor on 16/2/25.
//
import UIKit

import UIKit

struct BingImageSearchResponse: Codable {
    let value: [BingImage]
}

struct BingImage: Codable {
    let contentUrl: String
    let width: Int
    let height: Int
}

struct BingImageInfo {
    let url: String
    let size: CGSize
}
