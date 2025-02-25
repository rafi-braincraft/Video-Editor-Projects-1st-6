//
//  ViewController.swift
//  GifMakerSwift
//
//  Created by Mohammad Noor on 26/1/25.
//

import UIKit
import WebKit
import PhotosUI

extension UIDevice {
    static var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
}

class MainViewController: UIViewController {
    @IBOutlet weak var galleryImageView: UIImageView!
    @IBOutlet weak var galleryWebView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .dark
        view.window?.overrideUserInterfaceStyle = .dark
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickerNavVC" {
            if let destinationVC = segue.destination as? UINavigationController {
                if let pickerVC = destinationVC.viewControllers.first as? MemeMakerPickerController {
                    //pickerVC.tempValue = sender as! Int
                    if(UIDevice.isIPad) {
                       // pickerVC.modalPresentationStyle = .overCurrentContext
                    }
                    pickerVC.delegate = self
                }
            }
        }
    }
    
    @IBAction func goToSubVC(_ sender: UIButton) {
        performSegue(withIdentifier: "PickerNavVC", sender: nil)
//        var configure = PHPickerConfiguration()
//        configure.filter = .images
//        configure.selectionLimit = 1
//        let picker = PHPickerViewController(configuration: configure)
//        present(picker, animated: true)
    }
}


extension MainViewController: MemeMakerPickerControllerDelegate {
    
    func memeMakerMediaPickerController(didFinishPickingWithImage image: UIImage) {
        galleryImageView.isHidden = false
        galleryWebView.isHidden = true
        
        galleryImageView.contentMode = .scaleAspectFit
        galleryImageView.image = image
    }
    
    func memeMakerMediaPickerController(didFinishPickingWithGif gifURL: URL) {
        
        galleryImageView.isHidden = true
        galleryWebView.isHidden = false
        
        //galleryWebView.load(URLRequest(url: videoURL))
        galleryWebView.contentMode = .scaleAspectFit
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            do {
                let data = try Data(contentsOf: gifURL)
                galleryWebView.load(data,
                                    mimeType: "image/gif",
                                    characterEncodingName: "UTF-8",
                                    baseURL: NSURL() as URL)
                
            } catch {
                
            }
            
        }
    }
    
    func memeMakerMediaPickerController(didFinishPickingWithVideo videoURL: URL) {
        
        galleryImageView.isHidden = true
        galleryWebView.isHidden = false
        
        galleryWebView.load(URLRequest(url: videoURL))
    }
}
