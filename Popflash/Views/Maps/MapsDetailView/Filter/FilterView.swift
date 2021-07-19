//
//  FilterView.swift
//  Popflash
//
//  Created by Seb Vidal on 22/06/2021.
//

import SwiftUI

struct FilterView: View {
    
    var map: Map
    
    @Binding var selectedType: String
    @Binding var selectedTick: String
    @Binding var selectedSide: String
    @Binding var selectedBind: String
    
    var body: some View {
        
        ScrollView(showsIndicators: false) {
            
            VStack(alignment: .leading, spacing: 8) {
                
                Header()
                
                QuickActions(map: map)
                
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
                    
                    SegmentedPicker(items: ["Smoke", "Flashbang", "Molotov", "Grenade"],
                                    defaultsKey: "type",
                                    style: .single,
                                    selectedItems: $selectedType)
                        .padding(.bottom, 8)
                    
                    Text("Tick-Rate")
                        .font(.headline)
                        .padding(.leading, 2)
                    
                    SegmentedPicker(items: ["64", "128"],
                                    defaultsKey: "tick",
                                    style: .single,
                                    selectedItems: $selectedTick)
                        .padding(.bottom, 8)
                    
                    Text("Side")
                        .font(.headline)
                        .padding(.leading, 2)
                    
                    SegmentedPicker(items: ["Terrorist", "Counter-\nTerrorist"],
                                    defaultsKey: "side",
                                    style: .single,
                                    selectedItems: $selectedSide)
                        .padding(.bottom, 8)
                    
                    Text("Jump-Throw Bind")
                        .font(.headline)
                        .padding(.leading, 2)
                    
                    SegmentedPicker(items: ["Yes", "No"],
                                    defaultsKey: "bind",
                                    style: .single,
                                    selectedItems: $selectedBind)
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
    
    var map: Map
    
    @FocusState var searchFocused: Bool
    
    var body: some View {
        
        HStack {
            
            SearchButton()
            
            FavouriteButton(map: map)
            
            OverviewButton(map: map)
            
        }
        .frame(height: 75)
        .padding(.top, 8)
        
    }
    
}

private struct SearchButton: View {
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        
        Button(action: search) {
            
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
        
    }
    
    func search() {
        
        dismiss()
        
    }
    
}

private struct FavouriteButton: View {
    
    var map: Map
    
    @AppStorage("favourites.maps") private var favouriteMaps: Array = [String]()
    
    var body: some View {
        
        Button(action: favourite) {
            
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .foregroundStyle(Color("Picker_Background"))
                .overlay {
                    
                    VStack(spacing: 4) {
                        
                        Image(systemName: isFavourite() ? "heart.slash.fill" : "heart.fill")
                            .font(.title2)
                        Text(isFavourite() ? "Unfavourite" : "Favourite")
                            .font(.callout)
                        
                    }
                    
                }
            
        }
        
    }
    
    func favourite() {
        
        if isFavourite() {
            
            if let index = favouriteMaps.firstIndex(of: map.name) {
                
                favouriteMaps.remove(at: index)
                
            }
            
        } else {
            
            favouriteMaps.append(map.name)
            
        }
        
    }
    
    func isFavourite() -> Bool {
        
        if favouriteMaps.contains(map.name) {
            
            return true
            
        } else {
            
            return false
            
        }
        
    }
    
}

private struct OverviewButton: View {
    
    var map: Map
    
    @State private var isShowing = false
    
    var body: some View {
        
        Button(action: showOverview) {
            
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
        .sheet(isPresented: $isShowing) {
            
            OverviewView(map: map)
            
        }
        
    }
    
    func showOverview() {
        
        isShowing.toggle()
        
    }
    
}
