//
//  AppDelegate.swift
//  PinterestPinsApiTest
//
//  Created by BCL Device 5 on 13/5/25.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
    
    // Handle callback URL from Pinterest OAuth
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        // Check if this is a callback URL from Pinterest OAuth
        if url.scheme == "com.PinterestPinsApiTest" {
            PinterestAuthManager.shared.handleCallback(url: url) { success, error in
                if success {
                    // Authentication successful, navigate to pins screen
                    if let rootVC = self.window?.rootViewController as? UINavigationController,
                       let loginVC = rootVC.topViewController as? LoginViewController {
                        let pinsVC = PinsViewController()
                        loginVC.navigationController?.pushViewController(pinsVC, animated: true)
                    }
                } else {
                    // Show error
                    if let rootVC = self.window?.rootViewController {
                        let errorMessage = error?.localizedDescription ?? "Authentication failed"
                        let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        rootVC.present(alert, animated: true)
                    }
                }
            }
            return true
        }
        return false
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}


