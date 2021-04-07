//
//  MapsView.swift
//  Popflash
//
//  Created by Seb Vidal on 03/02/2021.
//

import SwiftUI
import Kingfisher
import FirebaseFirestore

var filtered = false
var filter = "line.horizontal.3.decrease.circle"
var filterFilled = "line.horizontal.3.decrease.circle.fill"

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
        
        print(dateThreshold)
        
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
                    
                    let processor = CroppingImageProcessor(size: CGSize(width: 1284, height: 1), anchor: CGPoint(x: 0.5, y: 1)) |> DownsamplingImageProcessor(size: CGSize(width: 1284, height: 100))
                    
                    KFImage(URL(string: map.background)!)
                        .resizable()
                        .setProcessor(processor)
                        //.aspectRatio(contentMode: .fit)
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

struct MapsView: View {
    
    @ObservedObject public var mapsViewModel = MapsViewModel()
    
    @State var statusBarBlurOpacity = 1.0
    
    @AppStorage("maps.listFilter") var listFilter = "Popularity"
    @AppStorage("tabSelection") var tabSelection: Int = 0
    
    // Status bar blur
    var StatusBarBlur: some View {
        VisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
            .frame(height: 47)
            .edgesIgnoringSafeArea(.top)
    }
    
    var Header: some View {
        VStack {
            
            Spacer()
                .frame(height: 48)
            
            HStack() {
                Text("Maps")
                    .font(.system(size: 32))
                    .fontWeight(.bold)
                    .padding(.leading, 16)
                
                Spacer()
                
                Menu {
                    
                    Button {
                        
                        listFilter = "A-Z"
                        
                    } label: {
                        
                        if listFilter == "A-Z" {
                            
                            HStack {
                                
                                Text("A-Z")
                                
                                Image(systemName: "checkmark")
                                
                            }
                            
                        } else {
                            
                            Text("A-Z")
                            
                        }
                        
                    }
                    
                    Button {
                        
                        listFilter = "Popularity"
                        
                    } label: {
                        
                        if listFilter == "Popularity" {
                            
                            HStack {
                                
                                Text("Popularity")
                                
                                Image(systemName: "checkmark")
                                
                            }
                            
                        } else {
                            
                            Text("Popularity")
                            
                        }
                        
                    }
                    
                    Button {
                        
                        listFilter = "Active Duty"
                        
                    } label: {
                        
                        if listFilter == "Active Duty" {
                            
                            HStack {
                                
                                Text("Active Duty")
                                
                                Image(systemName: "checkmark")
                                
                            }
                            
                        } else {
                            
                            Text("Active Duty")
                            
                        }
                        
                    }
                    
                    Button {
                        
                        listFilter = "Reserves"
                        
                    } label: {
                        
                        if listFilter == "Reserves" {
                            
                            HStack {
                                
                                Text("Reserves")
                                
                                Image(systemName: "checkmark")
                                
                            }
                            
                        } else {
                            
                            Text("Reserves")
                            
                        }
                        
                    }
                    
                } label: {
                    
                    Image(systemName: "line.horizontal.3.decrease.circle")
                        .font(.system(size: 32))
                        .padding(.trailing, 16)
                    
                }
                
            }
            
            Divider()
                .padding(.top, 2)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            
        }
        
    }
    
    @State private var buttonIcon = filter
    @State private var statusOpacity = 0.0
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                ScrollView(
                    axes: .vertical,
                    showsIndicators: true,
                    offsetChanged: {
                        
                        let offset = $0.y
                        
                        statusOpacity = Double((1 / 42) * -offset)
                        
                    }) {
                    
                    Header
                    
                    VStack{
                        
                        if mapsViewModel.maps.isEmpty {
                            
                            ForEach(1..<10, id: \.self) { _ in
                                
                                RoundedRectangle(cornerRadius: 15, style: .continuous)
                                    .foregroundColor(Color("Loading"))
                                    .frame(height: ((UIScreen.screenWidth - 32) / 1.77) + 80)
                                    .padding(.horizontal, 16)
                                    .padding(.bottom, 8)
                                
                            }
                            
                        } else {
                            
                            ForEach(mapsViewModel.maps.sorted(by: {
                                
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
                                
                            }), id: \.self) { map in
                                
                                NavigationLink(destination: MapsDetailView(map: map)){
                                    
                                    MapCell(map: map)
                                        .shadow(radius: 6, y: 5)
                                        .padding(.horizontal, 16)
                                        .padding(.bottom, 10)
                                    
                                }
                                .buttonStyle(CustomButtonStyle())
                                
                            }
                            
                        }
                        
                    }
                    
                    Spacer()
                        .frame(height: 10)
                    
                }
                
                StatusBarBlur
                    .opacity(statusOpacity)
                
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitle("Maps", displayMode: .inline)
            .navigationBarHidden(true)
        }
        .onAppear() {
            
            if mapsViewModel.maps.isEmpty {
                
                mapsViewModel.fetchData(ref: Firestore.firestore().collection("maps"))
                
            }

            tabSelection = 1
            
        }
    }
}
