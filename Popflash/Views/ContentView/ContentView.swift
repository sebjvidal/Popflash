//
//  ContentView.swift
//  Popflash
//
//  Created by Seb Vidal on 04/02/2021.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

public var standard = UserDefaults.standard

struct ContentView: View {
    
    @State var showWelcomeView = false
    @State var map: Map?
    @State var nade: Nade?
    
    @AppStorage("tabSelection") var tabSelection = 0
    @AppStorage("firstLaunch") var firstLaunch = true
    
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
        .onOpenURL { url in
            
            handleURL(url)
            
        }
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
    
    func displayWelcomeView() {
        
        if firstLaunch {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                
                showWelcomeView = true
                firstLaunch = false
                
            }
            
        }
        
    }
    
    func handleURL(_ url: URL) {
        
        guard url.isDeepLink else {
            
            return
            
        }
        
        if let tabIdentifier = url.tabIdentifier {
            
            tabSelection = tabIdentifier
            
        }
        
        if let nadeID = url.nadeID {
            
            self.nade = nil
            
            fetchNade(withID: nadeID)
            
        }
        
    }
    
    func fetchNade(withID id: String) {
        
        let db = Firestore.firestore()
        let ref = db.collection("nades").whereField("id", isEqualTo: id).limit(to: 1)
        
        ref.getDocuments { snapshot, error in
            
            guard let documents = snapshot?.documents else {
                
                return
                
            }
            
            for document in documents {
                
                let nade = nadeFrom(doc: document)
                
                self.nade = nade
                
            }
            
        }
        
    }
    
}
