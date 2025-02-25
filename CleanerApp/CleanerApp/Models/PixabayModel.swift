//
//  PixabayModel.swift
//  QR Code Generator Release Edition
//
//  Created by Mohammad Noor on 12/11/24.
//

import UIKit

struct PixabayResponse: Decodable {
    let hits: [ImageData]
}

struct ImageData: Decodable {
    let webformatURL: String
}
