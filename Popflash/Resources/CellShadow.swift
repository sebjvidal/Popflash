//
//  CellShadow.swift
//  CellShadow
//
//  Created by Seb Vidal on 17/07/2021.
//

import SwiftUI

struct CellShadow: ViewModifier {
    
    func body(content: Content) -> some View {
        
        content
            .shadow(color: .black.opacity(0.125), radius: 6, y: 5)
        
    }
    
}

extension View {
    
    func cellShadow() -> some View {
        
        self.modifier(CellShadow())
        
    }
    
}
