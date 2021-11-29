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
    
    @StateObject var mapsViewModel = MapsViewModel()
    
    @State private var statusOpacity: Double = 0
    @State private var hideNavBar = true
    @State private var selectedMap: Map?
    
    @AppStorage("tabSelection") var tabSelection: Int = 0
    
    var body: some View {
        
        GeometryReader { outerGeo in
            
            NavigationView {
                
                List {
                    
                    Group {
                        
                        StatusBarHelper(outerGeo: outerGeo,
                                        statusOpacity: $statusOpacity)
                        
                        Header()
                        
                        MapsList(maps: mapsViewModel.maps)
                        
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(.some(EdgeInsets()))
                    
                }
                .listStyle(.plain)
                .environment(\.defaultMinListRowHeight, 1)
                .navigationBarTitle("Maps", displayMode: .inline)
                .navigationBarHidden(true)
                .overlay(alignment: .top) {
                    
                    StatusBarBlur(outerGeo: outerGeo, statusOpacity: $statusOpacity)
                    
                }
                .background(MapNavigationLink(selectedMap: $selectedMap))
                
            }
            .navigationViewStyle(.stack)
        }
        .onAppear(perform: onAppear)
        .onOpenURL(perform: handleURL)
    }
    
    func onAppear() {
        if mapsViewModel.maps.isEmpty {
            mapsViewModel.fetchData()
        }

        tabSelection = 1
    }
    
    func handleURL(_ url: URL) {
        if !url.isDeepLink {
            return
        }
        
        if selectedMap != nil {
            return
        }
        
        if tabSelection != 1 {
            return
        }
        
        if !["maps", "map", "nade"].contains(url.host) {
            UIApplication.shared.open(url)
            return
        }
        
        if let id = url.mapID {
            fetchMap(withID: id) { map in
                selectedMap = map
            }
        }
    }
}

private struct Header: View {
    
    var body: some View {
        
        LazyVStack(alignment: .center, spacing: 0) {

            Spacer()
                .frame(height: 51)

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
    
    @State private var action: Map?
    
    var body: some View {
        
        ForEach(filteredMaps(mapsList: maps), id: \.self) { map in
            
            ZStack {
                
                NavigationLink(destination: MapsDetailView(map: map), tag: map, selection: $action) {
                    
                    EmptyView()
                    
                }
                .hidden()
                .disabled(true)
                
                Button {
                    
                    action = map
                    
                } label: {
                    
                    MapCell(map: map)
                        .cellShadow()
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

struct MapsView_Previews: PreviewProvider {

    @State var map: String?

    static var previews: some View {

        MapsView()
            .preferredColorScheme(.light)

        MapsView()
            .preferredColorScheme(.dark)

    }

}
