//
//  PhotoPropertiesViewController.swift
//  CleanerApp
//
//  Created by Mohammad Noor on 15/12/24.
//
import UIKit


class PhotoPropertiesViewController: UIViewController {
    var imageUrl: String?

    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        if let imageUrl = imageUrl, let url = URL(string: imageUrl) {
            loadImage(from: url)
        }
    }

    func loadImage(from url: URL) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
            }
        }
    }
}
