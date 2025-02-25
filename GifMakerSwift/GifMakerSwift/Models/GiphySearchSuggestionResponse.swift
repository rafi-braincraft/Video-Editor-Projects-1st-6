//
//  GiphySearchSuggestionResponse.swift
//  GifMakerSwift
//
//  Created by Mohammad Noor on 18/2/25.
//


import UIKit

struct GiphySearchSuggestionResponse: Codable {
    let data: [GiphySearchTag]
}

struct GiphySearchTag: Codable {
    let name: String
    let analytics_response_payload: String?
}
