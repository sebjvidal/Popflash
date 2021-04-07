//
//  CustomButtonStyle.swift
//  Popflash
//
//  Created by Seb Vidal on 06/04/2021.
//

import SwiftUI

struct CustomButtonStyle: ButtonStyle {
    
    var buttonOverlay: some View {
        
        Rectangle()
            .foregroundColor(Color("Background"))
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            .padding(.horizontal, 16)
            .padding(.bottom, 10)
        
    }
    
    func makeBody(configuration: Configuration) -> some View {
        
        configuration
            .label
            .overlay(configuration.isPressed ? buttonOverlay.opacity(0.25) : buttonOverlay.opacity(0.0))
        
    }
    
}
