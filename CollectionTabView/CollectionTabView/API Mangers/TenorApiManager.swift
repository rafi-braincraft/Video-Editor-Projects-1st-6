//
//  TenorApiManager.swift
//  CollectionTabView
//
//  Created by Mohammad Noor on 23/1/25.
//

import UIKit

struct TenorAPIManager {
    static let shared = TenorAPIManager()
    private let apiKey = "C8AKUBKQA181"
    private let baseURL = "https://api.tenor.com/v1/search"
    
    private init () {}
    
    func fetchGIFs(query: String, page: Int, completion: @escaping ([String]?) -> Void) {
        let limit = 30
        let urlString = "\(baseURL)?q=\(query)&key=\(apiKey)&limit=\(limit)&contentfilter=high&pos=\(page * limit)"
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error fetching GIFs: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = data else {
                completion(nil)
                return
            }

            do {
                let jsonResponse = try JSONDecoder().decode(TenorResponse.self, from: data)
                let gifURLs = jsonResponse.results.map { $0.media.first?.gif?.url ?? "" }
                completion(gifURLs)
            } catch {
                print("Error decoding response: \(error.localizedDescription)")
                completion(nil)
            }
        }.resume()
    }
}


