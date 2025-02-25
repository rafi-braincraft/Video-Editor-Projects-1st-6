//
//  TenorApiManager.swift
//  GifMakerSwift
//
//  Created by Mohammad Noor on 5/2/25.
//

//
//  TenorApiManager.swift
//  CollectionTabView
//
//  Created by Mohammad Noor on 23/1/25.
//

import UIKit

struct TenorAPIManager {
    static let shared = TenorAPIManager()
    
    private init () {}
    
    func fetchGIFs(query: String,
                   page: Int,
                   baseURL: String,
                   apiKey: String, 
                   limit: Int = 20,
                   mediaType: String = "gif",
                   contentFilter:String = "high",
                   locale:String = "en-US",
                   completion: @escaping ([TenorInfo]?, Error?) -> Void) {
        
        let urlString = "\(baseURL)?q=\(query)&contentfilter=\(contentFilter)&key=\(apiKey)&limit=\(limit)&pos=\(page * limit)&media_filter=\(mediaType)&locale=\(locale)"
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
                let jsonResponse = try JSONDecoder().decode(TenorResponse.self, from: data)
                //let gifURLs = jsonResponse.results.map { $0.media.first?.gif?.url ?? "" }
                let gifInfo = jsonResponse.results.compactMap { item in
                    item.media.first?.gif.map {TenorInfo(url: $0.url, size: $0.size)}
                }
                completion(gifInfo, nil)
            } catch {
                print("Error decoding response: \(error.localizedDescription)")
                completion(nil, error)
            }
        }.resume()
    }
}

