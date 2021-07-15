//
//  ContentView.swift
//  Popflash
//
//  Created by Seb Vidal on 04/02/2021.
//

import SwiftUI

public var standard = UserDefaults.standard

struct ContentView: View {
    
    @State var firstLaunch = false
    @State var tabSelection = standard.integer(forKey: "tabSelection")
    
    var body: some View {
        
        TabView(selection: $tabSelection) {
            
            FeaturedView()
                .tabItem {
                    
                    Image(systemName: "star.fill")
                    Text("Featured")
                    
                }
                .tag(0)
            
            MapsView()
                .tabItem {
                    
                    Image(systemName: "map.fill")
                    Text("Maps")
                    
                }
                .tag(1)
            
            FavouritesView()
                .tabItem {
                    
                    Image(systemName: "heart.fill")
                    Text("Favourites")
                    
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                
                .tag(3)
            
        }
        .onAppear() {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                
                firstLaunch = standard.bool(forKey: "firstLaunch")
                
            }
            
        }
        
    }
    
}
