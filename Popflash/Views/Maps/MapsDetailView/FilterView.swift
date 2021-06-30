//
//  FilterView.swift
//  Popflash
//
//  Created by Seb Vidal on 22/06/2021.
//

import SwiftUI

struct FilterView: View {
    
    var body: some View {
        
        SwiftUI.ScrollView(showsIndicators: false) {
            
            VStack(alignment: .leading, spacing: 8) {
                
                Header()
                
                QuickActions()
                
                Divider()
                    .padding(.top, 8)
                
                Group {
                    
                    Text("Filter")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.leading, 2)
                    
                    Text("Type")
                        .font(.headline)
                        .padding(.leading, 2)
                    SegmentedPicker(items: ["Smoke_Icon", "Flashbang_Icon", "Molotov_Icon", "Grenade_Icon"])
                        .padding(.bottom, 8)
                    
                    Text("Tick-Rate")
                        .font(.headline)
                        .padding(.leading, 2)
                    SegmentedPicker(items: ["64", "128"], style: .single)
                        .padding(.bottom, 8)
                    
                    Text("Side")
                        .font(.headline)
                        .padding(.leading, 2)
                    SegmentedPicker(items: ["Terrorist", "Counter-\nTerrorist"], style: .single)
                        .padding(.bottom, 8)
                    
                    Text("Jump-Throw Bind")
                        .font(.headline)
                        .padding(.leading, 2)
                    SegmentedPicker(items: ["Yes", "No"], style: .single)
                        .padding(.bottom, 8)
                    
                }
                
            }
            .padding(.horizontal)
            
        }
        
    }
    
}

private struct Header: View {
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        
        HStack(alignment: .center) {
            
            Text("More")
                .font(.title2)
                .fontWeight(.semibold)
            
            Spacer()
            
            Button {
                
                dismiss()
                
            } label: {
                
                Circle()
                    .frame(width: 30, height: 30)
                    .foregroundStyle(Color("Picker_Background"))
                    .overlay(Image(systemName: "multiply").font(.headline).foregroundStyle(Color("Search_Bar_Icons")))
                
            }
            
        }
        .padding(.top, 16)
        .padding(.leading, 2)
        
    }
    
}

private struct QuickActions: View {
    
    var body: some View {
        
        HStack {
            
            Button {
                
            } label: {
                
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .foregroundStyle(Color("Picker_Background"))
                    .overlay {
                        
                        VStack(spacing: 4) {
                            
                            Image(systemName: "magnifyingglass")
                                .font(.title2)
                            Text("Search")
                                .font(.callout)
                            
                        }
                        
                    }
                
            }
            
            Button {
                
            } label: {
                
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .foregroundStyle(Color("Picker_Background"))
                    .overlay {
                        
                        VStack(spacing: 4) {
                            
                            Image(systemName: "heart.fill")
                                .font(.title2)
                            Text("Favourite")
                                .font(.callout)
                            
                        }
                        
                    }
                
            }
            
            Button {
                
            } label: {
                
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .foregroundStyle(Color("Picker_Background"))
                    .overlay {
                        
                        VStack(spacing: 4) {
                            
                            Image(systemName: "map.fill")
                                .font(.title2)
                            Text("Overview")
                                .font(.callout)
                            
                        }
                        
                    }
                
            }
            
        }
        .frame(height: 75)
        .padding(.top, 8)
        
    }
    
}
