//
//  TintColours.swift
//  TintColours
//
//  Created by Seb Vidal on 10/10/2021.
//

import SwiftUI

struct TintColour: Identifiable, Hashable {
    
    var id: Int
    var name: String
    var colour: Color
    
}

extension TintColour {
    
    static let tintColours = [
        TintColour(id: 0, name: "Red", colour: .red),
        TintColour(id: 1, name: "Orange", colour: .orange),
        TintColour(id: 2, name: "Yellow", colour: .yellow),
        TintColour(id: 3, name: "Green", colour: .green),
        TintColour(id: 4, name: "Teal", colour: .teal),
        TintColour(id: 5, name: "Cyan", colour: .cyan),
        TintColour(id: 6, name: "Blue", colour: .blue),
        TintColour(id: 7, name: "Indigo", colour: .indigo),
        TintColour(id: 8, name: "Purple", colour: .purple),
        TintColour(id: 9, name: "Pink", colour: Color("Pink"))
    ]
    
    
    static func colour(withID id: Int) -> Color {
        
        guard let tintColour = tintColours.first(where: { colour in
            
            colour.id == id
            
        }) else {
            
            return .blue
            
        }
        
        return tintColour.colour
        
    }
    
    static func name(forID id: Int) -> String {
        
        guard let tintColour = tintColours.first(where: { colour in
            
            colour.id == id
            
        }) else {
            
            return "Blue"
            
        }
        
        return tintColour.name
        
    }
    
}
