
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
    
    static var selectedBlue: UIColor {
            return UIColor(red: 0.0, green: 122.0 / 255.0, blue: 1.0, alpha: 1.0)
        }
}
