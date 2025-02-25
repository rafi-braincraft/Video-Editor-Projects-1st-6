

import UIKit

struct PixabayResponse: Decodable {
    let hits: [ImageData]
}

struct ImageData: Decodable {
    let webformatURL: String
}
