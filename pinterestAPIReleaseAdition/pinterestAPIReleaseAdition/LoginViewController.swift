//
//  LoginViewController.swift
//  pinterestAPIReleaseAdition
//
//  Created by BCL Device 5 on 8/5/25.
//


import UIKit
import SafariServices

class LoginViewController: UIViewController {
    // Pinterest app credentials - in a real app, these should be stored securely
    private let clientID = "1519492" // Replace with your actual client ID
    private let clientSecret = "0c6bec5cb2620dd9466d7fbdf13261253c4a441d" // Not recommended to hardcode
    private let redirectURI = "pinterestapp://callback" // Your registered redirect URI
    
    private var safariVC: SFSafariViewController?
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login with Pinterest", for: .normal)
        button.backgroundColor = .red
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Pinterest Login"
        setupViews()
        setupNotification()
    }
    
    private func setupViews() {
        view.addSubview(loginButton)
        
        NSLayoutConstraint.activate([
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loginButton.widthAnchor.constraint(equalToConstant: 250),
            loginButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
    }
    
    private func setupNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleAuthCallback(_:)), name: NSNotification.Name("PinterestAuthCallback"), object: nil)
    }
    
    @objc private func loginButtonTapped() {
        let authURL = "https://www.pinterest.com/oauth/?client_id=\(clientID)&redirect_uri=\(redirectURI)&response_type=code&scope=boards:read,pins:read,user_accounts:read"
        
        if let url = URL(string: authURL) {
            let safariVC = SFSafariViewController(url: url)
            self.safariVC = safariVC // Store reference
            present(safariVC, animated: true)
        }
    }
    
    @objc private func handleAuthCallback(_ notification: Notification) {
        // Dismiss the safari view controller
        safariVC?.dismiss(animated: true) {
            if let url = notification.object as? URL, let components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                // Extract code from URL
                if let code = components.queryItems?.first(where: { $0.name == "code" })?.value {
                    self.exchangeCodeForToken(code)
                }
            }
        }
    }
    
    private func exchangeCodeForToken(_ code: String) {
        let tokenURL = URL(string: "https://api.pinterest.com/v5/oauth/token")!
        var request = URLRequest(url: tokenURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Create parameters as a JSON object
        let params: [String: String] = [
            "grant_type": "authorization_code",
            "client_id": clientID,
            "client_secret": clientSecret,
            "code": code,
            "redirect_uri": redirectURI
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: params)
            request.httpBody = jsonData
            
            // Print the JSON request body for debugging
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("JSON request body: \(jsonString)")
            }
        } catch {
            print("Error creating JSON body: \(error)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            // Print HTTP status code for debugging
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status: \(httpResponse.statusCode)")
                for (key, value) in httpResponse.allHeaderFields {
                    print("Response Header: \(key): \(value)")
                }
            }
            
            guard let data = data, error == nil else {
                print("Error exchanging code for token: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            // Print raw response for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("Token response: \(responseString)")
            }
            
            // Check if it's an error response
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let errorCode = json["code"] as? Int,
               let message = json["message"] as? String {
                print("API Error: Code \(errorCode), Message: \(message)")
                return
            }
            
            do {
                let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
                print("Successfully retrieved access token!")
                
                DispatchQueue.main.async {
                    self?.navigateToHomeScreen(with: tokenResponse.access_token)
                }
            } catch {
                print("Error decoding token response: \(error)")
                
                // Try to decode different error response formats if needed
                do {
                    struct GenericErrorResponse: Decodable {
                        let error: String?
                        let error_description: String?
                    }
                    
                    let errorResponse = try JSONDecoder().decode(GenericErrorResponse.self, from: data)
                    if let errorMsg = errorResponse.error {
                        print("OAuth Error: \(errorMsg)")
                        print("Error Description: \(errorResponse.error_description ?? "No description")")
                    }
                } catch {
                    print("Could not decode as generic error response either: \(error)")
                }
            }
        }.resume()
    }
    
    private func navigateToHomeScreen(with token: String) {
        let homeVC = HomeViewController(accessToken: token)
        navigationController?.pushViewController(homeVC, animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}



// HomeViewController.swift









// Info.plist additions needed:
/*
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>pinterestapp</string>
        </array>
    </dict>
</array>
*/
