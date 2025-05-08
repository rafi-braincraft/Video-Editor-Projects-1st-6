//
//  SceneDelegate.swift
//  pinterestAPIReleaseAdition
//
//  Created by BCL Device 5 on 8/5/25.
//

// SceneDelegate.swift
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = UINavigationController(rootViewController: LoginViewController())
        window?.makeKeyAndVisible()
    }
    
    // Handle Pinterest OAuth callback
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        print("SceneDelegate received URL: \(URLContexts.first?.url.absoluteString ?? "none")")
        if let url = URLContexts.first?.url, url.scheme?.contains("pinterestapp") == true {
            print("Posting notification with URL: \(url)")
            NotificationCenter.default.post(name: NSNotification.Name("PinterestAuthCallback"), object: url)
        }
    }
}

