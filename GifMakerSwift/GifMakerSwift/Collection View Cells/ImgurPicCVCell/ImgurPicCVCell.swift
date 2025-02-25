//
//  ImgurPicCVCell.swift
//  GifMakerSwift
//
//  Created by Mohammad Noor on 19/2/25.
//

import UIKit
import WebKit

class ImgurPicCVCell: UICollectionViewCell {
    static let idetifier = "ImgurPicCVCell"
    
    @IBOutlet weak var tenorWebView: WKWebView!
    @IBOutlet weak var tenorLoader: UIActivityIndicatorView!
    @IBOutlet weak var tenorErrorImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpTenorWebView()
    }
    
    func setUpTenorWebView() {
        //tenorWebView.scrollView.isScrollEnabled = false
        tenorWebView.isUserInteractionEnabled = false
    }
    
    override func prepareForReuse() {
        tenorWebView.load(URLRequest(url: URL(string: "about:blank")!))
        tenorLoader.stopAnimating()
        tenorWebView.isHidden = false
        tenorErrorImageView.isHidden = true
    }
    
    func internetConnectionIsAvailable(isAvailable: Bool) {
        if isAvailable {
            tenorWebView.isHidden = false
            tenorErrorImageView.isHidden = true
        } else {
            tenorWebView.isHidden = true
            tenorLoader.stopAnimating()
            tenorErrorImageView.isHidden = false
        }
    }
    
    func loadTenorGIF(fileURL url: URL) {
        guard FileManager.default.fileExists(atPath: url.path) else {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            do {
                let data = try Data(contentsOf: url)
                internetConnectionIsAvailable(isAvailable: true)
                self.tenorWebView.load(data,
                                       mimeType: "image/gif",
                                       characterEncodingName: "UTF-8",
                                       baseURL: NSURL() as URL
                )
                tenorWebView.contentMode = .scaleAspectFit
                
            } catch {
                print("Error loading tenor gif \(error.localizedDescription)")
            }
            tenorLoader.stopAnimating()
        }
        
        
    }
}
