//
//  FavouritesView.swift
//  Popflash
//
//  Created by Seb Vidal on 13/02/2021.
//

import SwiftUI
import Kingfisher
import FirebaseAuth
import FirebaseFirestore

struct FavouritesView: View {
    
    @State private var statusOpacity: Double = 0
    @State private var selectedNade: Nade?
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
                        
                        FavouriteMaps()
                        
                        FavouriteNades(selectedNade: $selectedNade)
                        
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(.some(EdgeInsets()))
                    
                }
                .listStyle(.plain)
                .onAppear(perform: onAppear)
                .environment(\.defaultMinListRowHeight, 1)
                .navigationBarTitle("Favourites", displayMode: .inline)
                .navigationBarHidden(true)
                .background(MapNavigationLink(selectedMap: $selectedMap))
                .overlay(alignment: .top) {
                    
                    StatusBarBlur(outerGeo: outerGeo, statusOpacity: $statusOpacity)
                    
                }
                .sheet(item: self.$selectedNade) { item in
                    
                    NadeView(nade: item)
                    
                }
                
            }
            .navigationViewStyle(.stack)
            
        }
        .onAppear(perform: onAppear)
        .onOpenURL(perform: handleURL)
        
    }
    
    func onAppear() {
        tabSelection = 2
    }
    
    func handleURL(_ url: URL) {
        if !url.isDeepLink {
            return
        }
        
        if selectedMap != nil {
            return
        }
        
        if tabSelection != 2 {
            return
        }
        
        if !["favourites", "map", "nade"].contains(url.host) {
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
        
        LazyVStack(alignment: .leading, spacing: 0) {
            
            Spacer()
                .frame(height: 51)
            
            HStack() {
                
                Text("Favourites")
                    .font(.system(size: 32))
                    .fontWeight(.bold)
                    .padding(.leading, 16)
                    .padding(.bottom, 5)
                
            }
            
        }
        
    }
    
}


private struct FavouriteMaps: View {
    @State private var showingFavouriteMapsEdittingView = false
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                Divider()
                    .padding(.horizontal)
                
                mapsText
                    .hidden()
                    .background {
                        GeometryReader { geo in
                            mapsText
                                .offset(x: geo.frame(in: .named("favouriteMaps")).minX < 0 ? -geo.frame(in: .named("favouriteMaps")).minX : 0)
                        }
                    }
                
                FavouriteMapsList()
                    .padding([.horizontal, .bottom])
                
                Divider()
                    .padding(.horizontal)
                
            }
            .frame(minWidth: UIScreen.screenWidth)
        }
        .coordinateSpace(name: "favouriteMaps")
    }
    
    var mapsText: some View {
        Text("Maps")
            .font(.system(size: 20))
            .fontWeight(.semibold)
            .padding(.vertical, 11)
            .padding(.leading, 18)
    }
}

private struct FavouriteMapsList: View {
    @State var showingEditSheet = false
    @State var showingLoginSheet = false
    @StateObject var mapsViewModel = FavouriteMapsViewModel()
    
    var body: some View {
        HStack(spacing: 16) {
            ForEach(mapsViewModel.maps.sorted(by: { $0.position < $1.position }), id: \.self) { map in
                NavigationLink(destination: MapsDetailView(map: map)) {
                    FavouriteMapCell(map: map)
                }
            }
            
            EditFavouritesButton(showingEditSheet: $showingEditSheet, showingLoginSheet: $showingLoginSheet)
        }
        .buttonStyle(FavouriteMapCellButtonStyle())
        .onAppear(perform: onAppear)
        .sheet(isPresented: $showingEditSheet) {
            EditFavouriteMapsView()
                .interactiveDismissDisabled()
        }
        .sheet(isPresented: $showingLoginSheet, onDismiss: onAppear) {
            LoginSheet()
        }
    }
    
    func onAppear() {
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        if user.isAnonymous {
            mapsViewModel.clear()
        } else {
            mapsViewModel.fetchData()
        }
    }
}


private struct FavouriteMapCell: View {
    
    var map: Map
    
    var body: some View {
        
        ZStack(alignment: .center) {
            
            KFImage(URL(string: map.background))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 150)
            
            KFImage(URL(string: map.icon))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 65)
                .shadow(radius: 10)
                .shadow(radius: 10)
                .shadow(radius: 10)
            
        }
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        .cellShadow()
        
    }
    
}

private struct EditFavouritesButton: View {
    @Binding var showingEditSheet: Bool
    @Binding var showingLoginSheet: Bool
    @State private var showingLoginAlert = false
    @AppStorage("settings.tint") var tint: Int = 1
    
    var body: some View {
        Button(action: showEditFavouritesMapView) {
            ZStack {
                Rectangle()
                    .frame(width: 100, height: 150)
                    .foregroundColor(Color("Favourite_Map_Background"))
                
                Circle()
                    .frame(width: 50, height: 50)
                    .foregroundColor(Color("Favourite_Map_Button"))
                
                Image(systemName: "plus")
                    .foregroundColor(TintColour.colour(withID: tint))
                    .font(.system(size: 24))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        .shadow(color: .black.opacity(0.1), radius: 6, y: 5)
        .buttonStyle(FavouriteMapCellButtonStyle())
        .alert(isPresented: $showingLoginAlert) {
            Alert(title: Text("Sign In"),
                  message: Text("Sign in to Popflash to add maps to your favourites."),
                  primaryButton: .default(Text("Sign In"), action: showLogin),
                  secondaryButton: .cancel()
            )
        }
    }
    
    func showEditFavouritesMapView() {
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        if user.isAnonymous {
            showingLoginAlert.toggle()
        } else {
            showingEditSheet.toggle()
        }
    }
    
    func showLogin() {
        showingLoginSheet.toggle()
    }
}

private struct FavouriteNades: View {
    @Binding var selectedNade: Nade?
    @State var nadeViewIsPresented = false
    @StateObject var favouritesViewModel = FavouritesViewModel()
    @AppStorage("loggedInStatus") var loggedInStatus = false
    
    var body: some View {
        HStack(alignment: .center) {
            Text("Grenades")
                .font(.system(size: 20))
                .fontWeight(.semibold)
                .padding(.vertical, 11)
                .padding(.leading, 2)
            
            Spacer()
            
            Menu {
                Button("Map") {}
                Button("Date Added: Oldest") {}
                Button("Date Added: Newest") {}
            } label: {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .font(.title3)
            }
            .buttonStyle(.borderless)
        }
        .padding(.horizontal)
        .onAppear(perform: onAppear)
        .onChange(of: loggedInStatus, perform: update)
        
        ForEach(favouritesViewModel.nades, id: \.self) { nade in
            Button {
                self.selectedNade = nade
                nadeViewIsPresented.toggle()
            } label: {
                FavouriteNadeCell(nade: nade)
                    .padding(.horizontal)
                    .padding(.bottom, 16)
            }
            .buttonStyle(FavouriteNadeCellButtonStyle())
        }
    }
    
    func onAppear() {
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        if user.isAnonymous {
            favouritesViewModel.clear()
        } else {
            favouritesViewModel.fetchData()
        }
    }
    
    func update(_ status: Bool) {
        if status == true {
            favouritesViewModel.fetchData()
        } else {
            favouritesViewModel.clear()
        }
    }
}

struct FavouriteNadeCell: View, Equatable {
    
    var nade: Nade
    
    let processor = CroppingImageProcessor(size: CGSize(width: 1, height: 722), anchor: CGPoint(x: 1, y: 0.5))
    
    var body: some View {
        
        HStack(spacing: 0) {
            
            KFImage(URL(string: nade.thumbnail))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 166, height: 106)
                .clipped()
            
            ZStack(alignment: .topLeading) {
                
                KFImage(URL(string: nade.thumbnail))
                    .setProcessor(processor)
                    .resizable()
                    .frame(height: 106)
                    .overlay(.thickMaterial)
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    Text(nade.map)
                        .font(.system(size: 14))
                        .fontWeight(.semibold)
                        .padding(.top, 8)
                        .padding(.leading, 4)
                        .foregroundStyle(.secondary)
                    
                    Text(nade.name)
                        .fontWeight(.semibold)
                        .padding(.top, 0)
                        .padding(.leading, 4)
                        .lineLimit(2)
                    
                    Text(nade.shortDescription)
                        .font(.subheadline)
                        .padding(.top, 0)
                        .padding(.horizontal, 4)
                        .lineLimit(2)
                    
                }
                .padding(.leading, 8)
                
            }
            
        }
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        .drawingGroup()
        .cellShadow()
        
    }
    
    static func == (lhs: FavouriteNadeCell, rhs: FavouriteNadeCell) -> Bool {
        return lhs.nade.nadeID == rhs.nade.nadeID
    }
}
