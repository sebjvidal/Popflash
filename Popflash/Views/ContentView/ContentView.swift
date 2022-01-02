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
        .preferredColorScheme(colourScheme())
        .accentColor(TintColour.colour(withID: tint))
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
        
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(TintColour.colour(withID: tint))
    }
    
    func resetNade() {
        nade = nil
    }
    
    func colourScheme() -> ColorScheme? {
        switch appearance {
        case 1:
            return .light
        case 2:
            return .dark
        default:
            return .none
        }
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
        if url.isDynamicLink {
            DynamicLinks.dynamicLinks().handleUniversalLink(url) { dynamicLink, error in
                guard let dynamicLink = dynamicLink?.url else {
                    return
                }
                
                var urlString = dynamicLink.absoluteString
                urlString = urlString.replacingOccurrences(of: "https://", with: "")
                urlString = urlString.replacingOccurrences(of: "www.", with: "")
                urlString = urlString.replacingOccurrences(of: "popflash.app/", with: "popflash://")

                UIApplication.shared.open(URL(string: urlString)!)
            }
            
            return
        }
        
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
