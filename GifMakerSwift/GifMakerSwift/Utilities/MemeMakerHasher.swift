//
//  UrlHasher.swift
//  GifMakerSwift
//
//  Created by Mohammad Noor on 11/2/25.
//

import UIKit
import CryptoKit

extension String {
    var sha256HashValue: String? {
        guard let data = self.data(using: .utf8) else {
            return nil
        }
        
        let hashData = SHA256.hash(data: data)
        return hashData.map { String(format: "%02x", $0) }.joined()
    }
}
