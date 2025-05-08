//
//  TokenResponse.swift
//  pinterestAPIReleaseAdition
//
//  Created by BCL Device 5 on 8/5/25.
//
import UIKit

// TokenResponse.swift
struct TokenResponse: Decodable {
    let access_token: String
    let token_type: String
    let expires_in: Int
    let refresh_token: String?
    let scope: String
}


// Board and Pin Models
struct BoardsResponse: Decodable {
    let items: [Board]
}

struct Board: Decodable {
    let id: String
    let name: String
    let description: String?
    let media: Media?
    
    struct Media: Decodable {
        let image_cover_url: String?
    }
}

struct PinsResponse: Decodable {
    let items: [Pin]
}

struct Pin: Decodable {
    let id: String
    let title: String?
    let description: String?
    let media: Media?
    
    struct Media: Decodable {
        let images: Images?
        
        struct Images: Decodable {
            let orig: ImageDetails?
            
            struct ImageDetails: Decodable {
                let url: String
            }
        }
    }
}
