//
//  StatusBarBlur.swift
//  StatusBarBlur
//
//  Created by Seb Vidal on 29/09/2021.
//

import SwiftUI

struct StatusBarBlur: View {
    
    @State var outerGeo: GeometryProxy
    
    @Binding var statusOpacity: Double
    
    var body: some View {
        
        VisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
            .frame(height: outerGeo.safeAreaInsets.top)
            .ignoresSafeArea()
            .opacity(statusOpacity)
        
    }
    
}
