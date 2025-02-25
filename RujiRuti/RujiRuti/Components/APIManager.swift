//
//  APIManager.swift
//  RujiRuti
//
//  Created by Mohammad Noor on 6/11/24.
//

import UIKit

class APIManager {
    static let shared = APIManager()
    private let pixabayToken = "46903998-ab2886592e7af509a2e435983"
    private let baseURL = "https://pixabay.com/api/"
    private let imageType = "photo"
    
    private init() {}
    
    func fetchData(searchTag: String, completion: @escaping ([String]) -> Void) {
        let urlString = "\(baseURL)?key=\(pixabayToken)&q=\(searchTag)&image_type=\(imageType)"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received.")
                return
            }
            
            do {
                let pixabayResponse = try JSONDecoder().decode(PixabayResponse.self, from: data)
                let imageUrls = pixabayResponse.hits.map { $0.webformatURL }
                DispatchQueue.main.async {
                    completion(imageUrls)
                }
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }.resume()
    }
}

