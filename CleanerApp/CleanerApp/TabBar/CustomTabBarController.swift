import UIKit

//class CustomTabBarController: UITabBarController, UITabBarControllerDelegate {
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        self.delegate = self
//
////        if let customTabBar = self.tabBar as? CustomTabBar {
////            customTabBar.tintColor = .label
////        }
//    }
//
//    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
//        guard let customTabBar = tabBar as? CustomTabBar else { return }
//        let selectedIndex = tabBarController.selectedIndex
//        customTabBar.playAnimation(for: selectedIndex)
//        //print("Clicked")
//    }
//}

class CustomTabBarController: UITabBarController {
    
    /// Active for iPads running iOS 18+ where the traditional tab bar has been removed by Apple
    lazy var alternateTabBarActive: Bool = {
#if compiler(>=6.0) // Compiler flag for Xcode >= 16
        if #available(iOS 18.0, *), UIDevice.current.userInterfaceIdiom == .pad {
            self.isTabBarHidden = true
            return true
        }
#endif
        return false
    }()
    
    var tabBarHeightConstraint: NSLayoutConstraint?
    
    lazy var alternateTabBar: CustomTabBar = {
        CustomTabBar()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        if self.alternateTabBarActive {
            self.tabBar.isHidden = true
            
            self.alternateTabBar.items = self.tabBar.items
            self.alternateTabBar.selectedItem = self.tabBar.selectedItem
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                // Add Custom Tabbar
                let tabbar = self.alternateTabBar
                self.view.addSubview(tabbar)
                
                // Add layout constraints
                tabbar.translatesAutoresizingMaskIntoConstraints = false
                let bottom = tabbar.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
                let leading = tabbar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor)
                let trailing = tabbar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
                let height = NSLayoutConstraint(item: self.alternateTabBar, attribute: .height, relatedBy: .equal,
                                                toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 1)
                self.tabBarHeightConstraint = height
                self.view.addConstraints([bottom, leading, trailing, height])
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if self.alternateTabBarActive {
            self.alternateTabBar.items = self.tabBar.items
            self.alternateTabBar.selectedItem = self.tabBar.selectedItem
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if self.alternateTabBarActive {
            // Adjust height constraint
            let height = self.alternateTabBar.intrinsicContentSize.height
            self.tabBarHeightConstraint?.constant = height
            
            // Set insets for child view controllers
            let bottomInset = self.alternateTabBar.frame.size.height-self.view.safeAreaInsets.bottom
            self.viewControllers?.forEach { $0.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0) }
        }
    }
    
}

extension CustomTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let selectedIndex = tabBarController.selectedIndex
        if alternateTabBarActive {
            alternateTabBar.playAnimation(for: selectedIndex) // Trigger custom tab bar animation
        }
    }
    
    // MARK: - Override Tab Bar Tap Handling
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        super.tabBar(tabBar, didSelect: item)
        if let index = tabBar.items?.firstIndex(of: item), let customTabBar = tabBar as? CustomTabBar {
            customTabBar.playAnimation(for: index)
        }
    }
}
