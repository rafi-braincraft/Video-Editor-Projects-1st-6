//
//  to.swift
//  pinterestAPIReleaseAdition
//
//  Created by BCL Device 5 on 12/5/25.
//


import Foundation
import UIKit
import AuthenticationServices

/// Singleton class to manage all Pinterest API operations
class PinterestAPIManager: NSObject {
    
    // MARK: - Singleton
    static let shared = PinterestAPIManager()
    private override init() {
        super.init()
    }
    
    // MARK: - Constants
    private struct API {
        static let baseURL = "https://api.pinterest.com/v5"
        static let authURL = "https://www.pinterest.com/oauth/"
        static let redirectURI = "pinterestapp://auth"
        
        // Update these with your own app credentials
        static let clientID = "YOUR_CLIENT_ID"
        static let clientSecret = "YOUR_CLIENT_SECRET"
    }
    
    // MARK: - Properties
    private var accessToken: String? {
        get { UserDefaults.standard.string(forKey: "pinterest_access_token") }
        set { UserDefaults.standard.set(newValue, forKey: "pinterest_access_token") }
    }
    
    private var refreshToken: String? {
        get { UserDefaults.standard.string(forKey: "pinterest_refresh_token") }
        set { UserDefaults.standard.set(newValue, forKey: "pinterest_refresh_token") }
    }
    
    private var tokenExpirationDate: Date? {
        get {
            let timestamp = UserDefaults.standard.double(forKey: "pinterest_token_expiry")
            return timestamp > 0 ? Date(timeIntervalSince1970: timestamp) : nil
        }
        set {
            let timestamp = newValue?.timeIntervalSince1970 ?? 0
            UserDefaults.standard.set(timestamp, forKey: "pinterest_token_expiry")
        }
    }
    
    var isAuthenticated: Bool {
        guard let token = accessToken, let expiryDate = tokenExpirationDate else {
            return false
        }
        // Check if token is still valid (with 5 minute buffer)
        return expiryDate.timeIntervalSinceNow > 300
    }
    
    // MARK: - Authentication
    
    /// Generate the OAuth URL for Pinterest login
    func authorizationURL() -> URL? {
        let scopes = "boards:read,pins:read,user_accounts:read"
        let urlString = "\(API.authURL)authorize?client_id=\(API.clientID)&redirect_uri=\(API.redirectURI)&response_type=code&scope=\(scopes)"
        return URL(string: urlString)
    }
    
    /// Exchange authorization code for access token
    func exchangeCodeForToken(code: String, completion: @escaping (Bool, Error?) -> Void) {
        let parameters = [
            "grant_type": "authorization_code",
            "client_id": API.clientID,
            "client_secret": API.clientSecret,
            "code": code,
            "redirect_uri": API.redirectURI
        ]
        
        var request = URLRequest(url: URL(string: "\(API.authURL)token")!)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let bodyString = parameters.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        request.httpBody = bodyString.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                completion(false, error)
                return
            }
            
            guard let data = data else {
                completion(false, NSError(domain: "PinterestAPIError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"]))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let tokenResponse = try decoder.decode(TokenResponse.self, from: data)
                
                self.accessToken = tokenResponse.accessToken
                self.refreshToken = tokenResponse.refreshToken
                
                // Calculate expiration time
                if let expiresIn = tokenResponse.expiresIn {
                    self.tokenExpirationDate = Date(timeIntervalSinceNow: TimeInterval(expiresIn))
                }
                
                completion(true, nil)
            } catch {
                completion(false, error)
            }
        }.resume()
    }
    
    /// Refresh the access token using refresh token
    func refreshAccessToken(completion: @escaping (Bool, Error?) -> Void) {
        guard let refreshToken = self.refreshToken else {
            completion(false, NSError(domain: "PinterestAPIError", code: 1, userInfo: [NSLocalizedDescriptionKey: "No refresh token available"]))
            return
        }
        
        let parameters = [
            "grant_type": "refresh_token",
            "refresh_token": refreshToken,
            "client_id": API.clientID,
            "client_secret": API.clientSecret
        ]
        
        var request = URLRequest(url: URL(string: "\(API.authURL)token")!)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let bodyString = parameters.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        request.httpBody = bodyString.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                completion(false, error)
                return
            }
            
            guard let data = data else {
                completion(false, NSError(domain: "PinterestAPIError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"]))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let tokenResponse = try decoder.decode(TokenResponse.self, from: data)
                
                self.accessToken = tokenResponse.accessToken
                if let newRefreshToken = tokenResponse.refreshToken {
                    self.refreshToken = newRefreshToken
                }
                
                // Calculate expiration time
                if let expiresIn = tokenResponse.expiresIn {
                    self.tokenExpirationDate = Date(timeIntervalSinceNow: TimeInterval(expiresIn))
                }
                
                completion(true, nil)
            } catch {
                completion(false, error)
            }
        }.resume()
    }
    
    /// Log out user by clearing all stored tokens
    func logout() {
        accessToken = nil
        refreshToken = nil
        tokenExpirationDate = nil
    }
    
    // MARK: - API Requests
    
    /// Generic API request function with auth handling
    private func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        parameters: [String: Any]? = nil,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        // Check if authenticated or try to refresh token
        if !isAuthenticated {
            if let refreshToken = self.refreshToken {
                refreshAccessToken { [weak self] success, error in
                    if success {
                        self?.request(endpoint: endpoint, method: method, parameters: parameters, completion: completion)
                    } else {
                        completion(.failure(error ?? NSError(domain: "PinterestAPIError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Authentication failed"])))
                    }
                }
                return
            } else {
                completion(.failure(NSError(domain: "PinterestAPIError", code: 3, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])))
                return
            }
        }
        
        // Construct URL
        guard var urlComponents = URLComponents(string: "\(API.baseURL)/\(endpoint)") else {
            completion(.failure(NSError(domain: "PinterestAPIError", code: 4, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        // Add query parameters for GET requests
        if method == "GET", let parameters = parameters {
            urlComponents.queryItems = parameters.map { 
                URLQueryItem(name: $0.key, value: "\($0.value)") 
            }
        }
        
        guard let url = urlComponents.url else {
            completion(.failure(NSError(domain: "PinterestAPIError", code: 4, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        // Add auth header
        if let token = accessToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Add body for non-GET requests
        if method != "GET", let parameters = parameters {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: parameters)
                request.httpBody = jsonData
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                completion(.failure(error))
                return
            }
        }
        
        // Execute request
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "PinterestAPIError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            // Handle response status code
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200...299:
                    // Success
                    break
                case 401:
                    // Unauthorized - token might be expired
                    self.refreshAccessToken { [weak self] success, error in
                        if success {
                            self?.request(endpoint: endpoint, method: method, parameters: parameters, completion: completion)
                        } else {
                            completion(.failure(NSError(domain: "PinterestAPIError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Authentication failed"])))
                        }
                    }
                    return
                default:
                    // Other errors
                    completion(.failure(NSError(domain: "PinterestAPIError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "API error with status code: \(httpResponse.statusCode)"])))
                    return
                }
            }
            
            // Parse response
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let result = try decoder.decode(T.self, from: data)
                completion(.success(result))
            } catch {
                print("Decoding error: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    // MARK: - Pinterest API Endpoints
    
    /// Get user profile information
    func getUserProfile(completion: @escaping (Result<User, Error>) -> Void) {
        request(endpoint: "user_account", completion: completion)
    }
    
    /// Get user pins
    func getUserPins(bookmark: String? = nil, pageSize: Int = 25, completion: @escaping (Result<PinsResponse, Error>) -> Void) {
        var parameters: [String: Any] = ["page_size": pageSize]
        if let bookmark = bookmark {
            parameters["bookmark"] = bookmark
        }
        
        request(endpoint: "pins", parameters: parameters, completion: completion)
    }
    
    /// Get user boards
    func getUserBoards(bookmark: String? = nil, pageSize: Int = 25, completion: @escaping (Result<BoardsResponse, Error>) -> Void) {
        var parameters: [String: Any] = ["page_size": pageSize]
        if let bookmark = bookmark {
            parameters["bookmark"] = bookmark
        }
        
        request(endpoint: "boards", parameters: parameters, completion: completion)
    }
}