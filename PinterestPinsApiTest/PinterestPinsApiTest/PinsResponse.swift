//
//  User.swift
//  PinterestPinsApiTest
//
//  Created by BCL Device 5 on 13/5/25.
//

struct PinsResponse: Codable {
    let items: [Pin]
    let bookmark: String?
}

struct Pin: Codable {
    let id: String
    let createdAt: String
    let link: String?
    let title: String?
    let description: String?
    let dominantColor: String?
    let altText: String?
    let creativeType: String
    let boardId: String
    let boardSectionId: String?
    let boardOwner: BoardOwner
    let isOwner: Bool
    let media: Media
    let parentPinId: String?
    let isStandard: Bool
    let hasBeenPromoted: Bool
    let note: String?
    let pinMetrics: PinMetrics?
    let isRemovable: Bool
    let productTags: [String]? // Added this field
}

struct BoardOwner: Codable {
    let username: String
}

struct Media: Codable {
    let mediaType: String
    let images: Images
}

struct Images: Codable {
    // Use custom keys to match the API response format
    let image150x150: ImageDetail
    let image400x300: ImageDetail
    let image600x: ImageDetail
    let image1200x: ImageDetail
    
    enum CodingKeys: String, CodingKey {
        case image150x150 = "150x150"
        case image400x300 = "400x300"
        case image600x = "600x"
        case image1200x = "1200x"
    }
}

struct ImageDetail: Codable {
    let width: Int
    let height: Int
    let url: String
}

struct PinMetrics: Codable {
    // Add properties if needed based on actual response
}
