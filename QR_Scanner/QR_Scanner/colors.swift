//
//  colors.swift
//  RujiRuti
//
//  Created by Mohammad Noor on 6/11/24.
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
}
 
