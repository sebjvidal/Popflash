//
//  ContentView.swift
//  Popflash
//
//  Created by Seb Vidal on 04/02/2021.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseDynamicLinks

public var standard = UserDefaults.standard

struct ContentView: View {
    
    @State var showWelcomeView = false
    @State var map: Map?
    @State var nade: Nade?
    
    @AppStorage("tabSelection") var tabSelection = 0
    @AppStorage("firstLaunch") var firstLaunch = true
    @AppStorage("settings.appearance") var appearance: Int = 0
    @AppStorage("settings.tint") var tint: Int = 1
    
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
        .preferredColorScheme(appearance == 0 ? .none :
                                appearance == 1 ? .light :
                                appearance == 2 ? .dark : .none)
        .accentColor(TintColour.colour(withID: tint))
//        .tint(TintColour.colour(withID: tint))
        .onOpenURL(perform: handleURL)
        .sheet(isPresented: $showWelcomeView) {
            WelcomeView()
                .interactiveDismissDisabled()
        }
        .sheet(item: $nade) { nade in
            NadeView(nade: nade)
        }
        
    }
    
    func onAppear() {
        displayWelcomeView()
    }
    
    func resetNade() {
        nade = nil
    }
    
    func displayWelcomeView() {
        if firstLaunch {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showWelcomeView = true
                firstLaunch = false
            }
        }
    }
    
    func handleURL(_ url: URL) {
        if nade == nil {
            if let nadeID = url.nadeID {
                fetchNade(withID: nadeID) { nade in
                    self.nade = nade
                }
            }
        }
        
        if let tabIdentifier = url.tabIdentifier {
            tabSelection = tabIdentifier
        }
    }
}
