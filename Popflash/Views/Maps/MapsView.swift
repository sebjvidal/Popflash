//
//  MapsView.swift
//  Popflash
//
//  Created by Seb Vidal on 03/02/2021.
//

import SwiftUI
import Kingfisher
import FirebaseFirestore

struct MapsView: View {
    
    @State var statusOpacity = 0.0
    
    @StateObject var mapsViewModel = MapsViewModel()
    
    @AppStorage("tabSelection") var tabSelection: Int = 0
    
    var body: some View {
        
        NavigationView {
            
            ZStack(alignment: .top) {
                
                ScrollView(offsetChanged: {
                    
                    let offset = $0.y
                    
                    statusOpacity = Double((1 / 42) * -offset)
                    
                }) {
                    
                    VStack {
                        
                        Header()
                        
                        MapsList(maps: mapsViewModel.maps)
                        
                        Spacer(minLength: 8)
                        
                    }
                    
                }
                .onAppear() {
                    
                    if mapsViewModel.maps.isEmpty {
                        
                        mapsViewModel.fetchData(ref: Firestore.firestore().collection("maps"))
                        
                    }
                    
                    tabSelection = 1
                    
                }
                
                StatusBarBlur(opacity: statusOpacity)
                
            }
//            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitle("Maps", displayMode: .inline)
            .navigationBarHidden(true)
            
        }
        
    }
    
}

private struct StatusBarBlur: View {
    
    var opacity: Double
    
    var body: some View {
        
        VisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
            .frame(height: 47)
            .edgesIgnoringSafeArea(.top)
            .opacity(opacity)
        
    }
    
}

private struct Header: View {
    
    var body: some View {
        
        VStack {

            Spacer()
                .frame(height: 48)

            HStack() {

                Text("Maps")
                    .font(.system(size: 32))
                    .fontWeight(.bold)
                    .padding(.leading, 16)

                Spacer()

                MapsFilterMenu()

            }

            Divider()
                .padding(.top, 2)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)

        }
        
    }
    
}

private struct MapsFilterMenu: View {
    
    var menuItems = ["A-Z", "Popularity", "Active Duty", "Reserves"]
    
    @AppStorage("maps.listFilter") var listFilter = "Popularity"
    
    var body: some View {
        
        Menu {
            
            ForEach(menuItems, id: \.self) { item in
                
                Button {
                    
                    listFilter = item
                    
                } label: {
                    
                    HStack {
                        
                        Text(item)
                        
                        if listFilter == item {
                            
                            Image(systemName: "checkmark")
                            
                        }
                        
                    }
                    
                }
                
            }
            
        } label: {
            
            Image(systemName: "line.horizontal.3.decrease.circle")
                .font(.system(size: 32))
                .padding(.trailing, 16)
            
        }
        
    }
    
}

private struct MapsList: View {
    
    var maps: [Map]
    
    @AppStorage("maps.listFilter") var listFilter = "Popularity"
    
    var body: some View {
        
        VStack {
            
            ForEach(filteredMaps(mapsList: maps), id: \.self) { map in
                
                NavigationLink(destination: MapsDetailView(map: map)){
                    
                    MapCell(map: map)
                        .shadow(radius: 6, y: 5)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 10)
                    
                }
                .buttonStyle(MapCellButtonStyle())
                
            }
            
        }
        
    }
    
    func filteredMaps(mapsList: [Map]) -> [Map] {
        
        let filteredMapsList = mapsList.sorted(by: {
            
            if listFilter == "Popularity" {
                return $0.views > $1.views
            } else if listFilter == "A-Z" {
                return $0.name < $1.name
            } else {
                return $0.name < $1.name
            }
            
        }).filter( {
            
            if listFilter == "Active Duty" {
                return $0.group == "Active Duty"
            } else if listFilter == "Reserves" {
                return $0.group == "Reserves"
            } else {
                return $0.group != ""
            }
            
        })
        
        return filteredMapsList
        
    }
    
}

private struct LoadingList: View {
    
    var body: some View {
        
        VStack {
            
            ForEach(1...10, id: \.self) { _ in
                
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .foregroundColor(Color("Loading"))
                    .frame(height: ((UIScreen.screenWidth - 32) / 1.777) + 80)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                
            }
            
        }
                
    }
    
}
