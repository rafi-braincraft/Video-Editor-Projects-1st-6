// PinterestAPI.swift
import Foundation

class PinterestAPI {
    static let shared = PinterestAPI()
    
    private let baseURL = "https://api.pinterest.com/v5"
    private var accessToken: String? {
        get {
            return UserDefaults.standard.string(forKey: "pinterest_access_token")
        }
        set {
            if let token = newValue {
                UserDefaults.standard.set(token, forKey: "pinterest_access_token")
            } else {
                UserDefaults.standard.removeObject(forKey: "pinterest_access_token")
            }
        }
    }
    
    var isAuthenticated: Bool {
        return accessToken != nil
    }
    
    // Set the access token
    func setAccessToken(_ token: String) {
        self.accessToken = token
    }
    
    // Clear the access token (logout)
    func logout() {
        self.accessToken = nil
    }
    
    // Fetch user's pins
    func fetchUserPins(completion: @escaping (Result<[Pin], Error>) -> Void) {
        guard let token = accessToken else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "No access token"])))
            return
        }
        
        // Endpoint to get the authenticated user's pins
        let urlString = "\(baseURL)/user_account/pins"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                // For debugging
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Response: \(jsonString)")
                }
                
                let decoder = JSONDecoder()
                let pinsResponse = try decoder.decode(PinsResponse.self, from: data)
                completion(.success(pinsResponse.items))
            } catch {
                print("Decoding error:", error)
                completion(.failure(error))
            }
        }.resume()
    }
    
    // Fetch a specific pin by ID
    func fetchPin(by pinId: String, completion: @escaping (Result<Pin, Error>) -> Void) {
        guard let token = accessToken else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "No access token"])))
            return
        }

        let urlString = "\(baseURL)/pins/\(pinId)"
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }

            do {
                let decoder = JSONDecoder()
                let pin = try decoder.decode(Pin.self, from: data)
                completion(.success(pin))
            } catch {
                print("Decoding error:", error)
                completion(.failure(error))
            }
        }.resume()
    }
}
