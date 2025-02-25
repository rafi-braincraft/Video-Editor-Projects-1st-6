//
//  MemePickerError.swift
//  GifMakerSwift
//
//  Created by Mohammad Noor on 16/2/25.
//

import UIKit

enum MemePickerError: LocalizedError {
    case assetDownloadFailed
    
    var errorDescription: String? {
        switch self {
        case .assetDownloadFailed: return "Asset Download Failed"
        }
    }
}
