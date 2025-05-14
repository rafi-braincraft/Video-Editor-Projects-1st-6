//
//  User 2.swift
//  PinterestPinsApiTest
//
//  Created by BCL Device 5 on 14/5/25.
//


import UIKit

struct User: Codable {
    let username: String
    let profileImage: String?
    let accountType: String
    let bio: String?
    let websiteUrl: String?
}

struct Board: Codable {
    let id: String
    let name: String
    let description: String?
    let owner: Owner
    let privacy: String
    let imageCoverUrl: String?
}

struct Owner: Codable {
    let username: String
}

struct BoardsResponse: Codable {
    let items: [Board]
    let bookmark: String?
}