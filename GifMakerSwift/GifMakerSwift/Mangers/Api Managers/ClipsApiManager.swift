//
//  TenorApiManager.swift
//  CollectionTabView
//
//  Created by Mohammad Noor on 23/1/25.
//

import UIKit

struct ClipsApiManager {
    static let shared = ClipsApiManager()
    private let apiKey = "C8AKUBKQA181"
    private let baseURL = "https://api.tenor.com/v1/search"
    
    private init () {}
    
    func fetchGIFs(query: String, page: Int, completion: @escaping ([String]?, Error?) -> Void) {
        let limit = 30
        let urlString = "\(baseURL)?q=\(query)&key=\(apiKey)&limit=\(limit)&contentfilter=high&pos=\(page * limit)"
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
                let jsonResponse = try JSONDecoder().decode(ClipsResponse.self, from: data)
                let gifURLs = jsonResponse.results.map { $0.media.first?.gif?.url ?? "" }
                completion(gifURLs, nil)
            } catch {
                print("Error decoding response: \(error.localizedDescription)")
                completion(nil, error)
            }
        }.resume()
    }
}




