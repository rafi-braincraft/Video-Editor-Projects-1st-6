//
//  TokenResponse.swift
//  PinterestAPITestFinal
//
//  Created by BCL Device 5 on 12/5/25.
//


import Foundation

// MARK: - Authentication Models

struct TokenResponse: Decodable {
    let accessToken: String
    let tokenType: String
    let expiresIn: Int?
    let refreshToken: String?
    let scope: String?
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
        case scope
    }
}

// MARK: - User Models

struct User: Decodable {
    let username: String
    let accountType: String?
    let profileImage: String?
    let websiteUrl: String?
    let id: String?
    
    enum CodingKeys: String, CodingKey {
        case username
        case accountType = "account_type"
        case profileImage = "profile_image"
        case websiteUrl = "website_url"
        case id
    }
}

// MARK: - Pin Models

struct PinsResponse: Decodable {
    let items: [Pin]
    let bookmark: String?
}

struct Pin: Decodable {
    let id: String
    let createdAt: String?
    let link: String?
    let title: String?
    let description: String?
    let dominantColor: String?
    let altText: String?
    let boardId: String?
    let boardSectionId: String?
    let media: Media?
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case link
        case title
        case description
        case dominantColor = "dominant_color"
        case altText = "alt_text"
        case boardId = "board_id"
        case boardSectionId = "board_section_id"
        case media
    }
}

struct Media: Decodable {
    let mediaType: String?
    let images: PinImages?
    
    enum CodingKeys: String, CodingKey {
        case mediaType = "media_type"
        case images
    }
}

struct PinImages: Decodable {
    let originals: ImageDetails?
    let x236x: ImageDetails?
    let x474x: ImageDetails?
    
    enum CodingKeys: String, CodingKey {
        case originals = "originals"
        case x236x = "236x"
        case x474x = "474x"
    }
}

struct ImageDetails: Decodable {
    let url: String
    let width: Int?
    let height: Int?
}

// MARK: - Board Models

struct BoardsResponse: Decodable {
    let items: [Board]
    let bookmark: String?
}

struct Board: Decodable {
    let id: String
    let name: String
    let description: String?
    let privacy: String?
    let imagesThumbnailUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case privacy
        case imagesThumbnailUrl = "images_thumbnail_url"
    }
}