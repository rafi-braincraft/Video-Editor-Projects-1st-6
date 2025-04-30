//
//  Extentions.swift
//  Running MetalPetal
//
//  Created by BCL Device 5 on 18/3/25.
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
