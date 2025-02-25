//
//  GiphySearchSuggestionApiManager.swift
//  GifMakerSwift
//
//  Created by Mohammad Noor on 18/2/25.
//


import UIKit

class GiphySearchSuggestionApiManager {
    static let shared = GiphySearchSuggestionApiManager()
    
    private init() {}
    
    func fetchSearchSuggestions(query: String,
                                baseURL: String,
                                apiKey: String,
                                limit: Int = 50,
                                completion: @escaping ([String]?, Error?) -> Void) {
        
        let urlString = "\(baseURL)?api_key=\(apiKey)&q=\(query)&limit=\(limit)&offset=0"
        
        guard let url = URL(string: urlString) else {
            completion(nil, MemePickerError.assetDownloadFailed)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, MemePickerError.assetDownloadFailed)
                return
            }
            
            do {
                let response = try JSONDecoder().decode(GiphySearchSuggestionResponse.self, from: data)
                let suggestions = response.data.map {$0.name}
                completion(suggestions, nil)
            } catch {
                completion(nil, error)
            }
        }.resume()
    }
}
