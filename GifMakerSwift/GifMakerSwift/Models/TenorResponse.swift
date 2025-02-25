//
//  TenorGifModel.swift
//  GifMakerSwift
//
//  Created by Mohammad Noor on 5/2/25.
//
import UIKit

struct TenorResponse: Codable {
    let results: [TenorItem]
    let next: String?
}

struct TenorItem: Codable {
    let id: String?
    let title: String?
    let contentDescription: String?
    let contentRating: String?
    let h1Title: String?
    let media: [TenorMedia]
    let bgColor: String?
    let created: Double?
    let itemurl: String?
    let url: String?
    let tags: [String]?
    let flags: [String]?
    let shares: Int?
    let hasaudio: Bool?
    let hascaption: Bool?
    let sourceId: String?
    let composite: String?
}

struct TenorMedia: Codable {
    let gif: TenorModel?
}

struct TenorModel: Codable {
    let url: String
    let dims: [Int] // Tenor API returns dimensions as [width, height]
    let preview: String?
    let duration: Double?

    var size: CGSize {
        return CGSize(width: dims[0], height: dims[1])
    }
}

struct TenorInfo {
    let url: String
    let size: CGSize
}
