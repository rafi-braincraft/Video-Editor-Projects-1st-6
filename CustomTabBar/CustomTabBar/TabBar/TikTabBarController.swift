//
//  TikTabBar.swift
//  CustomTabBar
//
//  Created by Mohammad Noor on 9/12/24.
//

import UIKit

class TikTabBarController: UITabBarController {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.selectedIndex = 2 //def 1
    }
    
    

}

extension TikTabBarController: UITabBarControllerDelegate {
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        print("item tapped")
    }
}
