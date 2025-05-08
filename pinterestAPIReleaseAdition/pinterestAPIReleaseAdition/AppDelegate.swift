//
//  AppDelegate.swift
//  pinterestAPIReleaseAdition
//
//  Created by BCL Device 5 on 8/5/25.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Initialize the main window
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UINavigationController(rootViewController: LoginViewController())
        window?.makeKeyAndVisible()
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("AppDelegate received URL: \(url.absoluteString)")
        if url.scheme?.contains("pinterestapp") == true {
            print("Posting notification with URL: \(url)")
            NotificationCenter.default.post(name: NSNotification.Name("PinterestAuthCallback"), object: url)
            return true
        }
        return false
    }
}

