//
//  VisualEffectView.swift
//  VisualEffectView
//
//  Created by Seb Vidal on 26/09/2021.
//

import SwiftUI

 struct VisualEffectView: UIViewRepresentable {
     
     var effect: UIVisualEffect?

     func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView {
         
         UIVisualEffectView()
         
     }

     func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) {
         
         uiView.effect = effect
         
     }
     
 }
