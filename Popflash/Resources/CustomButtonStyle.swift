//
//  CustomButtonStyle.swift
//  Popflash
//
//  Created by Seb Vidal on 06/04/2021.
//

import SwiftUI

struct MapCellButtonStyle: ButtonStyle {
    
    var buttonOverlay: some View {
        
        Rectangle()
            .foregroundColor(Color("Button_Overlay"))
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

struct ComplimentsCellButtonStyle: ButtonStyle {
    
    var buttonOverlay: some View {
        
        Rectangle()
            .foregroundColor(Color("Button_Overlay"))
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            .padding(.trailing, 8)
            .padding(.bottom, 20)
        
    }
    
    func makeBody(configuration: Configuration) -> some View {
        
        configuration
            .label
            .overlay(configuration.isPressed ? buttonOverlay.opacity(0.25) : buttonOverlay.opacity(0.0))
        
    }
    
}

struct FavouriteMapCellButtonStyle: ButtonStyle {
    
    var buttonOverlay: some View {
        
        Rectangle()
            .foregroundColor(Color("Button_Overlay"))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .padding(.leading, 8)
            .padding(.bottom, 16)
        
    }
    
    func makeBody(configuration: Configuration) -> some View {
        
        configuration
            .label
            .overlay(configuration.isPressed ? buttonOverlay.opacity(0.25) : buttonOverlay.opacity(0.0))
        
    }
    
}

struct FavouriteNadeCellButtonStyle: ButtonStyle {
    
    var buttonOverlay: some View {
        
        Rectangle()
            .foregroundColor(Color("Button_Overlay"))
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            .padding(.bottom, 8)
        
    }
    
    func makeBody(configuration: Configuration) -> some View {
        
        configuration
            .label
            .overlay(configuration.isPressed ? buttonOverlay.opacity(0.25) : buttonOverlay.opacity(0.0))
        
    }
    
}