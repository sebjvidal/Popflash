//
//  ProgressBar.swift
//  Popflash
//
//  Created by Seb Vidal on 12/03/2021.
//

import SwiftUI
import UIKit
import AVKit

//class CustomSlider: UISlider {
//
//    private var thumbTouchSize = CGSize(width: 100, height: 100)
//
//    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
//        let increasedBounds = bounds.insetBy(dx: -thumbTouchSize.width, dy: -thumbTouchSize.height)
//        let containsPoint = increasedBounds.contains(point)
//        return containsPoint
//    }
//
//    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
//        let percentage = CGFloat((value - minimumValue) / (maximumValue - minimumValue))
//        let thumbSizeHeight = thumbRect(forBounds: bounds, trackRect:trackRect(forBounds: bounds), value:0).size.height
//        let thumbPosition = thumbSizeHeight + (percentage * (bounds.size.width - (2 * thumbSizeHeight)))
//        let touchLocation = touch.location(in: self)
//        return touchLocation.x <= (thumbPosition + thumbTouchSize.width) && touchLocation.x >= (thumbPosition - thumbTouchSize.width)
//    }
//}

struct ProgressBar : UIViewRepresentable {
    
    func makeCoordinator() -> ProgressBar.Coordinator {
        
        return ProgressBar.Coordinator(parent1: self)
        
    }
    
    
    @Binding var value : Float
    @Binding var player : AVPlayer
    @Binding var isplaying : Bool
    
    func makeUIView(context: UIViewRepresentableContext<ProgressBar>) -> UISlider {
     
        let slider = UISlider()
        
        slider.minimumTrackTintColor = .white
        slider.maximumTrackTintColor = .gray
        slider.setThumbImage(UIImage(named: "Thumb_Image"), for: .normal)
        slider.value = value
        slider.addTarget(context.coordinator, action: #selector(context.coordinator.changed(slider:)), for: .valueChanged)
        
        return slider
        
    }
    
    func updateUIView(_ uiView: UISlider, context: UIViewRepresentableContext<ProgressBar>) {
        
        uiView.value = value
        
    }
    
    class Coordinator : NSObject{
        
        var parent : ProgressBar
        
        init(parent1 : ProgressBar) {
            
            parent = parent1
            
        }
        
        @objc func changed(slider : UISlider){
            
            if slider.isTracking{
                
                parent.player.pause()
                
                let sec = Double(slider.value * Float((parent.player.currentItem?.duration.seconds)!))
                
                parent.player.seek(to: CMTime(seconds: sec, preferredTimescale: 100))
                
            } else {
                
                let sec = Double(slider.value * Float((parent.player.currentItem?.duration.seconds)!))
                  
                parent.player.seek(to: CMTime(seconds: sec, preferredTimescale: 100))
                
                if parent.isplaying{
                    
                    parent.player.play()
                    
                }
                
            }
            
        }
        
    }
    
}
