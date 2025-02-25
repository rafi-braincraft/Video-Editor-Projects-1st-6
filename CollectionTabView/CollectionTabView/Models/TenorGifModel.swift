import UIKit

struct TenorResponse: Decodable {
    let results: [GifItem]
}

struct GifItem: Decodable {
    let media: [GifMedia]
}

struct GifMedia: Decodable {
    let gif: GifURL?
}

struct GifURL: Decodable {
    let url: String
}
