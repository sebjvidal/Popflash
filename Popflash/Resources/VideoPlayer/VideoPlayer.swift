//
//  VideoPlayer.swift
//  Popflash
//
//  Created by Seb Vidal on 26/12/2021.
//

import SwiftUI
import AVKit

struct VideoPlayer: UIViewControllerRepresentable {
    var player: AVPlayer
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<VideoPlayer>) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        controller.videoGravity = .resizeAspectFill
        
        try! AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: UIViewControllerRepresentableContext<VideoPlayer>) {}
}
