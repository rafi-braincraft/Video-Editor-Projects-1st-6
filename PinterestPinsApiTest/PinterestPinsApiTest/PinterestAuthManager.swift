//
//  PinterestAuthManager 2.swift
//  PinterestPinsApiTest
//
//  Created by BCL Device 5 on 13/5/25.
//

import Foundation
import UIKit
import SafariServices

class PinterestAuthManager {
    // MARK: - Properties
    static let shared = PinterestAuthManager()
    
    // Replace with your Pinterest app information
    private let clientID: String
    private let clientSecret: String
    private let redirectURI: String
    
    // Token storage
    private(set) var accessToken: String?
    private(set) var refreshToken: String?
    private(set) var tokenExpirationDate: Date?
    
    private var authCompletion: ((Bool, Error?) -> Void)?
    private weak var presentingViewController: UIViewController?
    
    
    // MARK: - Initialization
    private init() {
        // Load from your app settings or environment
        self.clientID = "1519492"
        self.clientSecret = "0c6bec5cb2620dd9466d7fbdf13261253c4a441d"
        self.redirectURI = "com.PinterestPinsApiTest://auth/callback" // e.g., com.yourapp://auth/callback
        
        // Load saved tokens if available
        loadTokens()
    }
    
    // MARK: - Authentication Methods
    
    /// Starts the Pinterest authentication flow
    func startAuthFlow(from viewController: UIViewController, completion: @escaping (Bool, Error?) -> Void) {
        self.authCompletion = completion
        
        // Create the OAuth URL
        let scopes = "user_accounts:read,pins:read,boards:read"
        let state = generateRandomState()
        
        var urlComponents = URLComponents(string: "https://www.pinterest.com/oauth/")!
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: scopes),
            URLQueryItem(name: "state", value: state)
        ]
        
        guard let url = urlComponents.url else {
            completion(false, NSError(domain: "PinterestAuthManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to create auth URL"]))
            return
        }
        
        // Save state for verification
        UserDefaults.standard.set(state, forKey: "pinterest_auth_state")
        
        // Open Safari view controller with the auth URL
        let safariVC = SFSafariViewController(url: url)
        viewController.present(safariVC, animated: true, completion: nil)
        
        // The callback will be handled in SceneDelegate or AppDelegate via the URL scheme
    }
    
    /// Handles the callback URL from Pinterest OAuth
    func handleCallback(url: URL, completion: @escaping (Bool, Error?) -> Void) {
        // Extract authorization code and state from URL
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            self.authCompletion?(false, NSError(domain: "PinterestAuthManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid callback URL"]))
            completion(false, NSError(domain: "PinterestAuthManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid callback URL"]))
            return
        }
        
        // Get code and state from the callback
        guard let code = queryItems.first(where: { $0.name == "code" })?.value,
              let state = queryItems.first(where: { $0.name == "state" })?.value else {
            completion(false, NSError(domain: "PinterestAuthManager", code: 3, userInfo: [NSLocalizedDescriptionKey: "Code or state missing in callback"]))
            return
        }
        
        // Verify state to prevent CSRF attacks
        guard let savedState = UserDefaults.standard.string(forKey: "pinterest_auth_state"),
              savedState == state else {
            completion(false, NSError(domain: "PinterestAuthManager", code: 4, userInfo: [NSLocalizedDescriptionKey: "State mismatch, possible CSRF attack"]))
            return
        }
        
        // Exchange code for access token
        exchangeCodeForToken(code) { success, error in
            // Call the stored completion from startAuthFlow
            self.authCompletion?(success, error)
            
            // Also call the completion passed to handleCallback
            completion(success, error)
        }
    }
    
    /// Exchanges the authorization code for access and refresh tokens
    private func exchangeCodeForToken(_ code: String, completion: @escaping (Bool, Error?) -> Void) {
        // Create token request
        var request = URLRequest(url: URL(string: "https://api.pinterest.com/v5/oauth/token")!)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        // Basic Authentication: Add Authorization header with base64 encoded client_id:client_secret
        let authString = "\(clientID):\(clientSecret)"
        if let authData = authString.data(using: .utf8) {
            let base64Auth = authData.base64EncodedString()
            request.addValue("Basic \(base64Auth)", forHTTPHeaderField: "Authorization")
        }
        
        // Only include required parameters in the request body
        let parameters = [
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": redirectURI,
            "continuous_refresh": "true" // Use continuous refresh token as recommended
        ]
        
        // URL encode parameters
        let bodyString = parameters.map { key, value in
            let encodedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? key
            let encodedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? value
            return "\(encodedKey)=\(encodedValue)"
        }.joined(separator: "&")
        
        print("Token request body: \(bodyString)")
        print("Authorization: Basic \(authString.data(using: .utf8)!.base64EncodedString())")
        
        request.httpBody = bodyString.data(using: .utf8)
        
        // Execute request
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            // Log HTTP status code
            if let httpResponse = response as? HTTPURLResponse {
                print("Pinterest token response status: \(httpResponse.statusCode)")
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    completion(false, error)
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(false, NSError(domain: "PinterestAuthManager", code: 5, userInfo: [NSLocalizedDescriptionKey: "No data in response"]))
                }
                return
            }
            
            // Print raw response for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("Pinterest token response: \(responseString)")
            }
            
            do {
                // Update the TokenResponse struct to match Pinterest's response format
                struct TokenResponse: Codable {
                    let access_token: String
                    let refresh_token: String?
                    let token_type: String
                    let expires_in: Int
                    let refresh_token_expires_in: Int?
                    let scope: String
                    let response_type: String?
                }
                
                // Parse the token response
                let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
                
                // Save the tokens
                self.accessToken = tokenResponse.access_token
                self.refreshToken = tokenResponse.refresh_token
                
                // Calculate expiration date
                let expiresIn = tokenResponse.expires_in
                self.tokenExpirationDate = Date().addingTimeInterval(TimeInterval(expiresIn))
                
                // Save tokens to persistent storage
                self.saveTokens()
                
                DispatchQueue.main.async {
                    completion(true, nil)
                }
            } catch {
                print("Failed to decode token response: \(error)")
                
                // Try to decode error response
                if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let errorMessage = errorJson["message"] as? String {
                    DispatchQueue.main.async {
                        completion(false, NSError(domain: "PinterestAuthManager", code: 8, userInfo: [NSLocalizedDescriptionKey: errorMessage]))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(false, error)
                    }
                }
            }
        }
        
        task.resume()
    }
    /// Refreshes the access token using the refresh token
    func refreshAccessToken(completion: @escaping (Bool, Error?) -> Void) {
        guard let refreshToken = self.refreshToken else {
            completion(false, NSError(domain: "PinterestAuthManager", code: 6, userInfo: [NSLocalizedDescriptionKey: "No refresh token available"]))
            return
        }
        
        // Create refresh token request
        var request = URLRequest(url: URL(string: "https://api.pinterest.com/v5/oauth/token")!)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let parameters = [
            "grant_type": "refresh_token",
            "client_id": clientID,
            "client_secret": clientSecret,
            "refresh_token": refreshToken
        ]
        
        request.httpBody = parameters
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .data(using: .utf8)
        
        // Execute request
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    completion(false, error)
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(false, NSError(domain: "PinterestAuthManager", code: 7, userInfo: [NSLocalizedDescriptionKey: "No data in response"]))
                }
                return
            }
            
            do {
                // Parse the token response
                let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
                
                // Save the new tokens
                self.accessToken = tokenResponse.access_token
                self.refreshToken = tokenResponse.refresh_token
                
                // Calculate expiration date
                let expiresIn = tokenResponse.expires_in
                self.tokenExpirationDate = Date().addingTimeInterval(TimeInterval(expiresIn))
                
                // Save tokens to persistent storage
                self.saveTokens()
                
                DispatchQueue.main.async {
                    completion(true, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false, error)
                }
            }
        }
        
        task.resume()
    }
    
    /// Checks if the current access token is valid
    func isTokenValid() -> Bool {
        guard let accessToken = accessToken,
              let expirationDate = tokenExpirationDate else {
            return false
        }
        
        // Check if the token is still valid (with a 5-minute buffer)
        return !accessToken.isEmpty && expirationDate.timeIntervalSinceNow > 300
    }
    
    /// Logs out the user by clearing tokens
    func logout() {
        accessToken = nil
        refreshToken = nil
        tokenExpirationDate = nil
        
        // Clear saved tokens
        UserDefaults.standard.removeObject(forKey: "pinterest_access_token")
        UserDefaults.standard.removeObject(forKey: "pinterest_refresh_token")
        UserDefaults.standard.removeObject(forKey: "pinterest_token_expiration")
    }
    
    // MARK: - Helper Methods
    
    /// Generates a random state string for CSRF protection
    private func generateRandomState() -> String {
        let length = 32
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map { _ in characters.randomElement()! })
    }
    
    /// Saves tokens to UserDefaults (for simplicity)
    /// In a production app, use Keychain for secure storage
    private func saveTokens() {
        if let accessToken = accessToken {
            UserDefaults.standard.set(accessToken, forKey: "pinterest_access_token")
        }
        
        if let refreshToken = refreshToken {
            UserDefaults.standard.set(refreshToken, forKey: "pinterest_refresh_token")
        }
        
        if let expirationDate = tokenExpirationDate {
            UserDefaults.standard.set(expirationDate, forKey: "pinterest_token_expiration")
        }
    }
    
    /// Loads tokens from UserDefaults
    private func loadTokens() {
        accessToken = UserDefaults.standard.string(forKey: "pinterest_access_token")
        refreshToken = UserDefaults.standard.string(forKey: "pinterest_refresh_token")
        tokenExpirationDate = UserDefaults.standard.object(forKey: "pinterest_token_expiration") as? Date
    }
}


