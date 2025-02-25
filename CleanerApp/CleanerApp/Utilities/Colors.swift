//
//  Colors.swift
//  QR Code Generator Release Edition
//
//  Created by Mohammad Noor on 11/11/24.
//

import UIKit

extension UIColor {
    static var reverseSystemBackground: UIColor {
        return UIColor {
            switch $0.userInterfaceStyle { //trait collection
            case .dark:
                return .white
            default:
                return .black
            }
            
        }
    }
    
    static var customBlue: UIColor {
            return UIColor(red: 38.0 / 255.0, green: 168.0 / 255.0, blue: 254.0 / 255.0, alpha: 1.0)
        }
    
    static var customGray: UIColor {
        return UIColor(red: 233.0 / 255.0, green: 246.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
    }

}
