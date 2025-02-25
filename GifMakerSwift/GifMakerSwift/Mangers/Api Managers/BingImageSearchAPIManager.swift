//
//  BingImageSearchAPIManager.swift
//  GifMakerSwift
//
//  Created by Mohammad Noor on 16/2/25.
//
import UIKit

struct BingImageSearchAPIManager {
    static let shared = BingImageSearchAPIManager()
    
    private init() {}
    
    func fetchGIFs(
        query: String,
        page: Int,
        baseUrl: String,
        subscriptionKey: String,
        limit count: Int = 20,
        imageType: String = "AnimatedGifhttps",
        locale mkt: String = "en-us",
        maxFileSize: Int = 500000,
        safeSearch: String = "Strict",
        completion: @escaping ([BingImageInfo]?,Error?) -> Void)
    {
        let urlString = "\(baseUrl)?q=\(query)&imageType=\(imageType)&mkt=\(mkt)&maxFileSize=\(maxFileSize)&count=\(count)&safeSearch=\(safeSearch)&offset=\(count * page)"
        
        guard let url = URL(string: urlString) else {
            completion(nil, MemePickerError.assetDownloadFailed)
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue(subscriptionKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        
        URLSession.shared.dataTask(with: request) {data, _, error in
            
            if let error = error {
                print("\(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, error)
                return
            }
            
            do {
                
                let jsonResponse = try JSONDecoder().decode(BingImageSearchResponse.self, from: data)
                let imagesInfo = jsonResponse.value.map {
                    BingImageInfo(url: $0.contentUrl, size: CGSize(width: $0.width, height: $0.height))
                }
                
                completion(imagesInfo, nil)
            } catch {
                print("\(error.localizedDescription)")
                completion(nil, error)
            }
        }.resume()
    }
    
}


