//
//  ActivityIndicator.swift
//  ActivityIndicator
//
//  Created by Seb Vidal on 24/08/2021.
//

import SwiftUI

struct ActivityIndicator: View {
    
    var body: some View {
        
        LazyVStack {
            
            ProgressView()
                .padding(.top, 12)
                .padding(.bottom, 20)
            
        }
        
    }
    
}
