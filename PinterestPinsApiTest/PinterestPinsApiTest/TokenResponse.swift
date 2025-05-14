//
//  TokenResponse.swift
//  PinterestPinsApiTest
//
//  Created by BCL Device 5 on 13/5/25.
//


//struct TokenResponse: Codable {
//    let access_token: String
//    let refresh_token: String
//    let expires_in: Int
//    let scope: String
//    let token_type: String
//}
struct TokenResponse: Codable {
    let access_token: String
    let refresh_token: String?
    let token_type: String
    let expires_in: Int
    let refresh_token_expires_in: Int?
    let scope: String
    let response_type: String?
}
