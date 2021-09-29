//
//  StatusBarBlur.swift
//  StatusBarBlur
//
//  Created by Seb Vidal on 29/09/2021.
//

import SwiftUI

struct StatusBarHelper: View {
    
    @State var outerGeo: GeometryProxy
    
    @Binding var statusOpacity: Double
    
    var body: some View {
        
        GeometryReader { geo in
            
            Color.clear
                .preference(key: ScrollOffset.self,
                            value: geo.frame(in: .global).minY)

        }
        .frame(height: 1)
        .onPreferenceChange(ScrollOffset.self) { offset in
            
            let topInset = outerGeo.safeAreaInsets.top
            let notchOffset: CGFloat = (topInset == 20 ? 27 : 0)
            
            statusOpacity = 1 - ((1 / (47)) * (offset + notchOffset))

        }
        
    }
    
}
