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
    
    @IBOutlet weak var clipsErrorImageView: UIImageView!
    @IBOutlet weak var clipsCellLoader: UIActivityIndicatorView!
    @IBOutlet weak var webView: WKWebView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpWebView()
    }
    
    override func prepareForReuse() {
        webView.load(URLRequest(url: URL(string: "about:blank")!))
        
        clipsCellLoader.stopAnimating()
        webView.isHidden = false
        clipsErrorImageView.isHidden = true
    }
    
    func setUpWebView() {
        webView.isUserInteractionEnabled = false
    }
    
    func internetConnectionIsAvailable(isAvailable: Bool) {
        if isAvailable {
            webView.isHidden = false
            clipsErrorImageView.isHidden = true
        } else {
            webView.isHidden = true
            clipsCellLoader.stopAnimating()
            clipsErrorImageView.isHidden = false
        }
        
    }
    
    func loadGif(fileURL path: URL) {
        guard FileManager.default.fileExists(atPath: path.path)
        else {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            do {
                let data = try Data(contentsOf: path)
                internetConnectionIsAvailable(isAvailable: true)
                self.webView.load(
                    data,
                    mimeType: "image/gif",
                    characterEncodingName: "UTF-8",
                    baseURL: NSURL() as URL
                )
                
                webView.contentMode = .scaleAspectFit
            }
            catch {
                print("Error loading gif: \(error.localizedDescription)")
            }
            
            clipsCellLoader.stopAnimating()
        }
    }
}

