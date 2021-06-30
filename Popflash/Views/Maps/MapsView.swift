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
    @AppStorage("maps.listFilter") var listFilter = "Popularity"
    
    var body: some View {
        
        NavigationView {
            
            List {
                
                Group {
                    
                    Header()
                    
                    MapsList(maps: mapsViewModel.maps)
                    
                }
                .listRowSeparator(.hidden)
                .listRowInsets(.some(EdgeInsets()))
                
            }
            .listStyle(.plain)
            .navigationBarTitle("Maps", displayMode: .inline)
            .navigationBarHidden(true)
            .onAppear() {

                if mapsViewModel.maps.isEmpty {

                    mapsViewModel.fetchData(ref: Firestore.firestore().collection("maps"))

                }

                tabSelection = 1

            }

        }
        
    }
    
}

private struct Header: View {
    
    var body: some View {
        
        LazyVStack(alignment: .center, spacing: 0) {

            Spacer()
                .frame(height: 52)

            HStack() {

                Text("Maps")
                    .font(.system(size: 32))
                    .fontWeight(.bold)
                    .padding(.leading, 16)

                Spacer()

                MapsFilterMenu()

            }

            Divider()
                .padding(.top, 6)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)

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
    
    @State private var action: Int? = 0
    
    var body: some View {
            
        ForEach(filteredMaps(mapsList: maps), id: \.self) { map in
            
            ZStack {
                
                NavigationLink(destination: MapsDetailView(map: map), tag: generateID(forMap: map.id), selection: $action) {
                    
                    EmptyView()
                    
                }
                .hidden()
                .disabled(true)

                Button {

                    action = generateID(forMap: map.id)

                } label: {

                    MapCell(map: map)
                        .shadow(radius: 6, y: 5)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)

                }

            }
            .buttonStyle(MapCellButtonStyle())
            
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
    
    func generateID(forMap: String) -> Int {
        
        let rawString = forMap
        var idString = ""
        
        for character in rawString {
            
            if character.isASCII {
                
                idString.append(String(character.asciiValue!))
                
            }
            
        }
        
        return Int(idString.prefix(9)) ?? 0
        
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
