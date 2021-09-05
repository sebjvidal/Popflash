//
//  ContentView.swift
//  Popflash
//
//  Created by Seb Vidal on 04/02/2021.
//

import SwiftUI
import FirebaseAuth

public var standard = UserDefaults.standard

struct ContentView: View {
    
    @State var showWelcomeView = false
    @State var tabSelection = standard.integer(forKey: "tabSelection")
    
    @AppStorage("firstLaunch") var firstLaunch = true
    @AppStorage("loggedInStatus") var loggedIn = false
    
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
        .onAppear(perform: onAppear)
        .sheet(isPresented: $showWelcomeView) {
            
            WelcomeView()
                .interactiveDismissDisabled()
            
        }
        
    }
    
    func onAppear() {
        
        displayWelcomeView()
        initStateDidChangeListener()
        
    }
    
    func displayWelcomeView() {
        
        if firstLaunch && !loggedIn {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                
                showWelcomeView = true
                
            }
            
        }
        
    }
    
    func initStateDidChangeListener() {
        
        Auth.auth().addStateDidChangeListener { auth, user in
            
            guard let user = user else {
                
                return
                
            }
            
        }
        
    }
    
}
