//
//  GiphyResponse.swift
//  GifMakerSwift
//
//  Created by Mohammad Noor on 18/2/25.
//


//
//  GiphyModel.swift
//  GifMakerSwift
//
//  Created by Mohammad Noor on 5/2/25.
//

import UIKit

struct GiphyResponse: Codable {
    let data: [GiphyItem]
}

struct GiphyItem: Codable {
    let id: String?
    let title: String?
    let images: GiphyImages
}

struct GiphyImages: Codable {
    let original: GiphyImage
}
struct GiphyImage: Codable {
    let url: String
    let width: String
    let height: String
    
    var widthValue: Int {
        return Int(width) ?? 0
    }
    
    var heightValue: Int {
        return Int(height) ?? 0
    }
}

struct GiphyInfo {
    let url: String
    let size: CGSize
}
