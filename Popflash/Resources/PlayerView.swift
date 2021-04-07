//
//  PlayerView.swift
//  Popflash
//
//  Created by Seb Vidal on 24/02/2021.
//

import SwiftUI
import UIKit
import AVFoundation

struct PlayerView: UIViewRepresentable {
    
    func makeUIView(context: Context) -> UIView {
        
        return QueuePlayerUIView(frame: .zero)
        
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
        // Do nothing here...
        
    }
    
}

class QueuePlayerUIView: UIView {
    
    
    @objc private let player = AVQueuePlayer()
    private var playerLayer = AVPlayerLayer()
    private var token: NSKeyValueObservation?
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspectFill
        
        layer.addSublayer(playerLayer)
        
        // Load Videos
        addAllVideosToPlayer()
        
        // Play Video
        player.volume = 0.0
        
        token = player.observe(\.currentItem) { [weak self] player, _ in
            
            if player.items().count == 1 {
                
                self?.addAllVideosToPlayer()
                
            }
            
        }
        
        player.play()
        
    }
    
    private func addAllVideosToPlayer() {
        
        for i in 0...1 {
            
            let url = Bundle.main.url(forResource: "Pan_\(i)", withExtension: "mp4")!
            let item = AVPlayerItem(url: url)
            
            player.insert(item, after: player.items().last)
            
        }
        
    }
    
    func play() {
        
        print("play() func called")
        
        player.pause()
        
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        playerLayer.frame = bounds
        
    }
    
    required init?(coder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented.")
        
    }
    
}

struct PlayerView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        PlayerView()
        
    }
    
}
