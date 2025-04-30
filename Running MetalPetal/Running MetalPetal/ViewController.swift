//
//  ViewController.swift
//  Running MetalPetal
//
//  Created by BCL Device 5 on 16/3/25.
//

import UIKit
import AVFoundation
import MetalPetal

class ViewController: UIViewController {
    @IBOutlet weak var selectBackgroundButtonOutlet: UIButton!
    @IBOutlet weak var videoView: UIView!
    
    private var metalContext: MTIContext!
   // private let downloadPath: String = "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4"
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var videoURL: URL?
    var context: MTIContext?
    private var isFirstTimeLoad: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ImagePickerManager.shared.delegate = self
        self.downloadVideo()
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if isFirstTimeLoad {
            self.isFirstTimeLoad = false
            playerLayer = AVPlayerLayer()
            playerLayer?.frame = videoView.bounds
            playerLayer?.backgroundColor = UIColor.red.cgColor
            videoView.backgroundColor = .clear
            videoView.layer.addSublayer(playerLayer!)
        }
    }
    
    private func downloadVideo() {
//        MemeMakerPickerFileManager.shared.downloadAsset(
//            url: downloadPath,
//            folderName: "Demo"
//        ) {[weak self] cacheURL, error in
//            guard let self = self else { return }
//
//            if let savedURL = cacheURL {
//       
//            } else if let error = error {
//                debugPrint("Error downloading file: \(error)")
//            }
//        }
        let savedURL = Bundle.main.url(forResource: "airlines", withExtension: "mp4")
        DispatchQueue.main.async {
            self.videoURL = savedURL
            self.player = AVPlayer(url: savedURL!)
            self.playerLayer!.player = self.player
            self.player?.play()
        }
    }
    
    @IBAction func selectBackgroundButtonAction(_ sender: Any) {
        ImagePickerManager.shared.presentImagePicker(from: self)
    }
    
    func applyChromaKeyEffect(to image: UIImage) {
        guard let videoURL = videoURL else { return }
        self.selectBackgroundButtonOutlet.isEnabled = false
        self.selectBackgroundButtonOutlet.layer.opacity = 0.1
        ChromaKeyFilter.shared.applyChroma(with: image, from: videoURL, to: self.videoView)
    }
    
    @objc private func playerDidFinishPlaying() {
        self.selectBackgroundButtonOutlet.isEnabled = true
        self.selectBackgroundButtonOutlet.layer.opacity = 1.0
        ChromaKeyFilter.shared.dispose()
    }
}

extension ViewController: ImagePickerDelegate {
    func didSelect(image: UIImage?) {
        guard let image = image else { return }
        self.applyChromaKeyEffect(to: image)
    }
}
