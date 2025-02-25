//
//  ClipsCVCell.swift
//  CollectionTabView
//
//  Created by Mohammad Noor on 22/1/25.
//

import UIKit
import WebKit

class ClipsCVCell: UICollectionViewCell {
    static let identifier = "ClipsCVCell"
    
    @IBOutlet weak var webViewHolder: UIView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    private var webView: WKWebView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpWebView()
    }
    
    override func prepareForReuse() {
        webView.load(URLRequest(url: URL(string: "about:blank")!))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        webView.frame = webViewHolder.bounds
    }

    
    func setUpWebView() {
        webView = WKWebView(frame: webViewHolder.bounds)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webViewHolder.addSubview(webView)
    }
    
    func configure(gifURL: String) {
            loader.startAnimating()
            
            guard let url = URL(string: gifURL) else {
                loader.stopAnimating()
                return
            }

            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                guard let self = self else { return }

                DispatchQueue.main.async {
                    self.loader.stopAnimating()
                }
                
                if let error = error {
                    print("Failed to load image: \(error.localizedDescription)")
                    return
                }

                guard let data = data else {
                    print("No data received.")
                    return
                }

                DispatchQueue.main.async {
                    self.webView.load(data, mimeType: "image/gif", characterEncodingName: "UTF-8", baseURL: NSURL() as URL)
                }
            }.resume()
        }
}

