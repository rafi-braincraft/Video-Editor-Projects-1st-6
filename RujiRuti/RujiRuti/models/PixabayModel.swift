//
//  pixabayModel.swift
//  RujiRuti
//
//  Created by Mohammad Noor on 5/11/24.
//
import UIKit

struct PixabayResponse: Decodable {
    let hits: [ImageData]
}

struct ImageData: Decodable {
    let webformatURL: String
}
