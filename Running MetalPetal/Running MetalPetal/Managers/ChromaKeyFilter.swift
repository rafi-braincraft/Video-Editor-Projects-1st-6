//
//  ChromaKeyFilter.swift
//  Running MetalPetal
//
//  Created by BCL Device 5 on 18/3/25.
//


import Foundation
import MetalPetal
import AVFoundation

class ChromaKeyFilter {
    static let shared = ChromaKeyFilter()
    
    private var context: MTIContext?
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var playerItem: AVPlayerItem?
    
    private init() {}
    
    func applyChroma(with image: UIImage?, from videoURL: URL?, to videoView: UIView) {
        do {
            context = try MTIContext(device: MTLCreateSystemDefaultDevice()!)
        } catch {
            debugPrint("Failed to create context")
        }
        
        guard let backImage = image?.cgImage, let context = context else { return }
        
        let backgroundMTI = MTIImage(cgImage: backImage, options: [.SRGB: false], isOpaque: true)
        guard let videoURL = videoURL else {
            debugPrint("Failed to get videoURL")
            return
        }
        let asset = AVAsset(url: videoURL)
        let composition = MTIVideoComposition(asset: asset, context: context, queue: .main) { request in
            let filter = MTIChromaKeyBlendFilter()
            filter.inputImage = request.anySourceImage
            filter.inputBackgroundImage = backgroundMTI
            filter.thresholdSensitivity = 0.4
            filter.smoothing = 0.1
            filter.color = MTIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
            return filter.outputImage!
        }
        
        self.playerItem = AVPlayerItem(asset: asset)
        playerItem?.videoComposition = composition.makeAVVideoComposition()
        self.player = AVPlayer(playerItem: playerItem)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = videoView.bounds
        playerLayer?.videoGravity = .resizeAspect
        videoView.layer.addSublayer(playerLayer!)
        player?.play()
    }
    
    func dispose() {
        self.player?.pause()
        self.player = nil
        self.playerLayer?.removeFromSuperlayer()
        self.playerLayer = nil
        self.context = nil
    }
}
