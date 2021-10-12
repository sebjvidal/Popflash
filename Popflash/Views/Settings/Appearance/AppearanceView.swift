//
//  AppearanceView.swift
//  AppearanceView
//
//  Created by Seb Vidal on 09/10/2021.
//

import SwiftUI

struct AppearanceView: View {
    
    var body: some View {
        
        List {
            
            Group {
                
                Divider()
                    .padding(.horizontal)
                
                AppearanceList()
                
                AppearanceExplanation()
                
            }
            .listRowSeparator(.hidden)
            .listRowInsets(.some(EdgeInsets()))
            
        }
        .listStyle(.plain)
        .navigationBarTitle("Appearance", displayMode: .large)
        .environment(\.defaultMinListRowHeight, 1)
        
    }
    
}

private struct AppearanceList: View {
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            AppearanceOption(id: 0, option: "Automatic")
            
            Divider()
                .padding(.leading)
            
            AppearanceOption(id: 1, option: "Light")
            
            Divider()
                .padding(.leading)
            
            AppearanceOption(id: 2, option: "Dark")
            
        }
        .background(Color("Background"))
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        .padding([.top, .horizontal])
        .padding(.bottom, 8)
        .cellShadow()
        
    }
    
}

private struct AppearanceOption: View {
    
    var id: Int
    var option: String
    
    @AppStorage("settings.appearance") var appearance: Int = 0
    @AppStorage("settings.tint") var tint: Int = 1

    var body: some View {
        
        Button(action: setAppearance) {
            
            HStack {
                
                Text(option)
                    .padding(.horizontal)
                
                Spacer()
                
                Image(systemName: "checkmark")
                    .foregroundColor(TintColour.colour(withID: tint))
                    .padding(.trailing)
                    .opacity(appearance == id ? 1 : 0)
                
            }
            .padding(.vertical, 12)
            .background(Color("Background"))
            
        }
        .buttonStyle(RoundedTableCell())
        
    }
    
    func setAppearance() {
        
        appearance = id
        
    }
    
}

private struct AppearanceExplanation: View {
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 16) {
            
            Text("Automatic: Change the colour scheme based on the system appearance.")
            
            Text("Light/Dark: Always use the Light/Dark colour scheme, regardless of the system appearance.")
            
        }
        .font(.caption)
        .foregroundStyle(.secondary)
        .padding(.vertical, 8)
        .padding(.horizontal, 20)
        
    }
    
}
