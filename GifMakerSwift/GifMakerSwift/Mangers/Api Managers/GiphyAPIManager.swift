//
//  GiphyApiManager.swift
//  GifMakerSwift
//
//  Created by Mohammad Noor on 5/2/25.
//

import UIKit

struct GiphyAPIManager {
    static let shared = GiphyAPIManager()
    
    private init() {}
    
    func fetchGIFs(query: String,
                   page: Int,
                   baseURL: String,
                   apiKey: String,
                   limit: Int = 20,
                   rating: String = "g",
                   completion: @escaping ([GiphyInfo]?, Error?) -> Void) {
        
        let urlString = "\(baseURL)?api_key=\(apiKey)&q=\(query)&limit=\(limit)&offset=\(page * limit)&rating=\(rating)"
        guard let url = URL(string: urlString) else {
            completion(nil, MemePickerError.assetDownloadFailed)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error fetching GIFs: \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, error)
                return
            }
            
            do {
                let jsonResponse = try JSONDecoder().decode(GiphyResponse.self, from: data)
                let gifInfo = jsonResponse.data.compactMap { item in
                    GiphyInfo(url: item.images.original.url, size: CGSize(width: item.images.original.widthValue, height: item.images.original.heightValue))
                }
                completion(gifInfo, nil)
            } catch {
                print("Error decoding response: \(error.localizedDescription)")
                completion(nil, error)
            }
        }.resume()
    }
}
