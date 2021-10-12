//
//  TintView.swift
//  TintView
//
//  Created by Seb Vidal on 10/10/2021.
//

import SwiftUI

struct TintView: View {
    
    var body: some View {
        
        List {
            
            Group {
                
                Divider()
                    .padding(.horizontal)
                
                TintList()
                
            }
            .listRowSeparator(.hidden)
            .listRowInsets(.some(EdgeInsets()))
            
        }
        .listStyle(.plain)
        .navigationBarTitle("App Tint", displayMode: .large)
        .environment(\.defaultMinListRowHeight, 1)
        
    }
    
}

private struct TintList: View {
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            ForEach(TintColour.tintColours, id: \.self) { colour in
                
                TintOption(id: colour.id, name: colour.name, colour: colour.colour)
                
                if colour != TintColour.tintColours.last {
                    
                    Divider()
                        .padding(.leading, 60)
                    
                }
                
            }
            
        }
        .background(Color("Background"))
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        .padding([.top, .horizontal])
        .padding(.bottom, 8)
        .cellShadow()
        
    }
    
}

private struct TintOption: View {
    
    var id: Int
    var name: String
    var colour: Color
    
    @AppStorage("settings.tint") var tint: Int = 1

    var body: some View {
        
        Button(action: setTint) {
            
            HStack {
                
                Circle()
                    .foregroundColor(colour)
                    .frame(width: 30, height: 30)
                    .padding(.leading)
                    .padding(.trailing, 6)
                
                Text(name + (id == 1 ? " (Default)" : ""))
                
                Spacer()
                
                Image(systemName: "checkmark")
                    .padding(.trailing)
                    .foregroundColor(TintColour.colour(withID: tint))
                    .opacity(tint == id ? 1 : 0)
                
            }
            .padding(.vertical, 12)
            .padding(.top, colour == TintColour.tintColours.first?.colour ? 2 : 0)
            .padding(.bottom, colour == TintColour.tintColours.last?.colour ? 2 : 0)
            .background(Color("Background"))
            
        }
        .buttonStyle(RoundedTableCell())
        
    }
    
    func setTint() {
        
        tint = id
        
    }
    
}
