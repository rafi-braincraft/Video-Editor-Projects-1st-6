//
//  SearchSuggestionApiManager.swift
//  GifMakerSwift
//
//  Created by Mohammad Noor on 11/2/25.
//
import UIKit

class TenorSearchSuggestionApiManager {
    static let shared = TenorSearchSuggestionApiManager()
    
    private init() {}
    
    func fetchSearchSuggestion(query: String,
                               baseURL: String,
                               apiKey: String, 
                               limit: Int = 50,
                               locale: String = "en_US",
                               completion: @escaping ([String]?, Error?) -> Void) {
        guard let url = URL(string: "\(baseURL)?q=\(query)&key=\(apiKey)&limit=\(limit)&locale=\(locale)") else {
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
                let response = try JSONDecoder().decode(TenorSuggestionResponse.self, from: data)
                completion(response.results, nil)
            } catch {
                completion(nil, error)
            }
        }.resume()
        
    }
}
