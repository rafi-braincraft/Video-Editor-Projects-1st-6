//
//  PinterestAPIManager.swift
//  PinterestPinsApiTest
//
//  Created by BCL Device 5 on 13/5/25.
//


import Foundation
import UIKit

class PinterestAPIManager {
    // MARK: - Properties
    static let shared = PinterestAPIManager()
    
    private let baseURL = "https://api.pinterest.com/v5"
    
    // MARK: - Methods
    
    /// Fetches the current user's information
    func fetchUserProfile(completion: @escaping (Result<User, Error>) -> Void) {
        guard checkAndRefreshTokenIfNeeded() else {
            completion(.failure(NSError(domain: "PinterestAPIManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])))
            return
        }
        
        let endpoint = "/user_account"
        executeRequest(endpoint: endpoint, method: "GET") { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let user = try decoder.decode(User.self, from: data)
                    completion(.success(user))
                } catch {
                    completion(.failure(error))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Fetches the user's boards
    func fetchBoards(completion: @escaping (Result<[Board], Error>) -> Void) {
        guard checkAndRefreshTokenIfNeeded() else {
            completion(.failure(NSError(domain: "PinterestAPIManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])))
            return
        }
        
        let endpoint = "/boards"
        executeRequest(endpoint: endpoint, method: "GET") { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let boardsResponse = try decoder.decode(BoardsResponse.self, from: data)
                    completion(.success(boardsResponse.items))
                } catch {
                    completion(.failure(error))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Fetches pins for a specific board
    func fetchPinsForBoard(boardId: String, pagination: String? = nil, completion: @escaping (Result<PinsResponse, Error>) -> Void) {
        guard checkAndRefreshTokenIfNeeded() else {
            completion(.failure(NSError(domain: "PinterestAPIManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])))
            return
        }
        
        var endpoint = "/boards/\(boardId)/pins"
        
        // Add pagination if provided
        if let bookmark = pagination {
            endpoint += "?bookmark=\(bookmark)"
        }
        
        executeRequest(endpoint: endpoint, method: "GET") { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let pinsResponse = try decoder.decode(PinsResponse.self, from: data)
                    completion(.success(pinsResponse))
                } catch {
                    completion(.failure(error))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Fetches all pins for the user
    func fetchAllPins(pagination: String? = nil, completion: @escaping (Result<PinsResponse, Error>) -> Void) {
        guard checkAndRefreshTokenIfNeeded() else {
            completion(.failure(NSError(domain: "PinterestAPIManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])))
            return
        }
        
        var endpoint = "/pins"
        
        // Add pagination if provided
        if let bookmark = pagination {
            endpoint += "?bookmark=\(bookmark)"
        }
        
        executeRequest(endpoint: endpoint, method: "GET") { result in
            switch result {
            case .success(let data):
                do {
                    // Print the raw JSON for debugging
                    if let jsonString = String(data: data, encoding: .utf8) {
                        
                        
                        print("Raw JSON: \(jsonString)")
                    }
                    
                    // Try parsing with more verbose error handling
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    
                    let pinsResponse = try decoder.decode(PinsResponse.self, from: data)
                    completion(.success(pinsResponse))
                } catch {
                    print("Decoding error: \(error)")
                    
                    if let decodingError = error as? DecodingError {
                        switch decodingError {
                        case .keyNotFound(let key, let context):
                            print("Missing key: \(key) - \(context.debugDescription)")
                        case .typeMismatch(let type, let context):
                            print("Type mismatch: expected \(type) - \(context.debugDescription)")
                        case .valueNotFound(let type, let context):
                            print("Value not found: expected \(type) - \(context.debugDescription)")
                        case .dataCorrupted(let context):
                            print("Data corrupted: \(context.debugDescription)")
                        @unknown default:
                            print("Unknown decoding error: \(decodingError)")
                        }
                    }
                    
                    completion(.failure(error))
                }
                break
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Executes a request to the Pinterest API
    private func executeRequest(endpoint: String, method: String, parameters: [String: Any]? = nil, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let accessToken = PinterestAuthManager.shared.accessToken else {
            completion(.failure(NSError(domain: "PinterestAPIManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "No access token available"])))
            return
        }
        
        guard let url = URL(string: baseURL + endpoint) else {
            completion(.failure(NSError(domain: "PinterestAPIManager", code: 3, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        if let parameters = parameters, method == "POST" || method == "PUT" {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: parameters)
                request.httpBody = jsonData
            } catch {
                completion(.failure(error))
                return
            }
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "PinterestAPIManager", code: 4, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                }
                return
            }
            
            if httpResponse.statusCode == 401 {
                // Token expired, trigger refresh
                PinterestAuthManager.shared.refreshAccessToken { success, error in
                    if success {
                        // Retry the request
                        self.executeRequest(endpoint: endpoint, method: method, parameters: parameters, completion: completion)
                    } else {
                        DispatchQueue.main.async {
                            completion(.failure(error ?? NSError(domain: "PinterestAPIManager", code: 5, userInfo: [NSLocalizedDescriptionKey: "Failed to refresh token"])))
                        }
                    }
                }
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "PinterestAPIManager", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "API error: \(httpResponse.statusCode)"])))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "PinterestAPIManager", code: 6, userInfo: [NSLocalizedDescriptionKey: "No data in response"])))
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(.success(data))
            }
        }
        
        task.resume()
    }
    
    /// Checks if the token is valid and refreshes if needed
    private func checkAndRefreshTokenIfNeeded() -> Bool {
        guard PinterestAuthManager.shared.accessToken != nil else {
            return false
        }
        
        if !PinterestAuthManager.shared.isTokenValid(), let _ = PinterestAuthManager.shared.refreshToken {
            // Token expired but we have a refresh token
            // For simplicity, we'll return false here and let the caller handle the refresh
            // In a real app, you might want to refresh the token here and return true once refreshed
            return false
        }
        
        return PinterestAuthManager.shared.isTokenValid()
    }
}
