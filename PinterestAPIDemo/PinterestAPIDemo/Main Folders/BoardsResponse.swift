//
//  BoardsResponse.swift
//  PinterestAPIDemo
//
//  Created by BCL Device 5 on 4/5/25.
//

import UIKit

struct PinsResponse: Codable {
    let items: [Pin]
    let bookmark: String?
}

struct Pin: Codable {
    let id: String
    let title: String?
    let description: String?
    let link: String?
    let media: Media?
    
    struct Media: Codable {
        let images: ImageMetadata?
        
        struct ImageMetadata: Codable {
            let original: ImageInfo?
            
            struct ImageInfo: Codable {
                let url: String
                let width: Int?
                let height: Int?
            }
        }
    }
}

