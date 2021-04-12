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

private struct NewButton: View {
    
    var lastAdded: String
    
    var body: some View {
        
        if recentlyAdded(dateString: lastAdded) {
            
            ZStack {
                
                Rectangle()
                    .frame(width: 75, height: 26)
                    .foregroundColor(.blue)
                    .cornerRadius(13)
                
                Text("NEW")
                    .font(.headline)
                    .foregroundColor(.white)
                
            }
            
        }
        
    }
    
    func recentlyAdded(dateString: String) -> Bool {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "dd-MM-y"
        
        let calendar = Calendar.current
        let currentDate = Date()
        guard let lastAddedDate = dateFormatter.date(from: dateString) else { return false }
        
        var dateComponent = DateComponents()
        
        dateComponent.day = -7
        
        guard let dateThreshold = calendar.date(byAdding: dateComponent, to: currentDate) else { return false }
        
        if lastAddedDate > dateThreshold {
            
            return true
            
        } else {
            
            return false
            
        }
        
    }
    
}

public struct MapCell: View {
    
    var map: Map
    
    @AppStorage("settings.compactMapsView") var compactMapsView = false
    
    public var body: some View {
        
        ZStack(alignment: .bottom) {
            
            VStack {
                
                if !compactMapsView {
                    
                    KFImage(URL(string: map.background)!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .foregroundColor(Color("Loading"))
                        .background(Color("Loading"))
                        .frame(height: UIScreen.screenWidth / 1.777 - 32)
                    
                }
                
                ZStack {
                    
                    let processor = CroppingImageProcessor(size: CGSize(width: 1284, height: 1), anchor: CGPoint(x: 0.5, y: 1))
                    
                    KFImage(URL(string: map.background)!)
                        .resizable()
                        .setProcessor(processor)
                        .frame(height: 80)
                    
                    VisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
                        .frame(height: 80)
                    
                    
                    HStack {
                        
                        KFImage(URL(string: map.icon))
                            .resizable()
                            .frame(width: 55, height: 55)
                            .padding(.leading, 12)
                        
                        VStack(alignment: .leading) {
                            
                            Text(map.name)
                                .font(.headline)
                            
                            Text(map.group)
                                .font(.subheadline)
                            
                        }
                        
                        Spacer()
                        
                        NewButton(lastAdded: map.lastAdded)
                        
                        Image(systemName: "chevron.right")
                            .padding(.trailing, 12)
                        
                    }
                    
                }
                .padding(.top, -2)
                
            }
            
        }
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        
    }
    
}

private struct MapsList: View {
    
    var maps: [Map]
    
    @AppStorage("maps.listFilter") var listFilter = "Popularity"
    
    var body: some View {
        
        LazyVStack {
            
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
