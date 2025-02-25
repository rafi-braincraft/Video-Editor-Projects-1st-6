import UIKit

struct ClipsResponse: Codable {
    let results: [ClipsGifItem]
}

struct ClipsGifItem: Codable {
    let media: [ClipsGifMedia]
}

struct ClipsGifMedia: Codable {
    let gif: ClipsGifURL?
}

struct ClipsGifURL: Codable {
    let url: String
}
