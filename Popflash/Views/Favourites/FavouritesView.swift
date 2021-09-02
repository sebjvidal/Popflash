//
//  FavouritesView.swift
//  Popflash
//
//  Created by Seb Vidal on 13/02/2021.
//

import SwiftUI
import Kingfisher
import FirebaseFirestore

struct FavouritesView: View {
    
    @State var statusOpacitiy = 0.0
    @State var isShowing = false
    @State var selectedNade: Nade?
    
    @AppStorage("tabSelection") var tabSelection: Int = 0
    
    var body: some View {
        
        NavigationView {
            
            List {
                
                Group {
                    
                    Header()
                    
                    FavouriteMaps(isShowing: $isShowing)
                    
                    FavouriteNades(selectedNade: $selectedNade)
                    
                }
                .listRowSeparator(.hidden)
                .listRowInsets(.some(EdgeInsets()))
                
            }
            .listStyle(.plain)
            .onAppear {
                
                standard.set(2, forKey: "tabSelection")
                
            }
            .navigationBarTitle("Favourites", displayMode: .inline)
            .navigationBarHidden(true)
            .sheet(item: self.$selectedNade) { item in
                
                NadeView(nade: item)
                
            }
            .sheet(isPresented: $isShowing) {
                
                EditFavouriteMapsView()
                    .interactiveDismissDisabled()
                
            }
            
        }
        .onAppear(perform: onAppear)
        
    }
    
    func onAppear() {
        
        tabSelection = 2
        
    }
    
}

private struct Header: View {
    
    var body: some View {
        
        LazyVStack(alignment: .leading, spacing: 0) {
            
            Spacer()
                .frame(height: 52)
            
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
    
    @Binding var isShowing: Bool
    
    @ObservedObject var mapsViewModel = FavouriteMapsViewModel()
    
    @State private var showingFavouriteMapsEdittingView = false
    
    var body: some View {
        
        ZStack(alignment: .topLeading) {
            
            ScrollView(.horizontal, showsIndicators: false) {
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    Divider()
                        .padding(.horizontal)
                        .padding(.bottom, 47)
                    
                    HStack {
                        
                        Spacer()
                            .frame(width: 8)
                        
                        ForEach(mapsViewModel.maps.sorted(by: {
                            
                            $0.position < $1.position
                            
                        }), id: \.self) { map in
                            
                            NavigationLink(destination: MapsDetailView(map: map)) {
                                
                                FavouriteMapCell(map: map)
                                
                            }
                            .buttonStyle(FavouriteMapCellButtonStyle())
                            .padding(.leading, 8)
                            .padding(.bottom, 16)
                            
                        }
                        
                        EditFavouritesButton(isShowing: $isShowing)
                        
                        Spacer()
                            .frame(minWidth: 16)
                        
                    }
                    .frame(minWidth: UIScreen.screenWidth)
                    
                    Divider()
                        .padding(.horizontal)
                    
                }
                
            }
            
            Text("Maps")
                .font(.system(size: 20))
                .fontWeight(.semibold)
                .padding(.top, 12)
                .padding(.leading, 18)
            
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
        .cellShadow()
        
    }
    
}

private struct EditFavouritesButton: View {
    
    @Binding var isShowing: Bool
    
    var body: some View {
        
        Button {
            
            isShowing.toggle()
            
        } label: {
            
            ZStack {
                
                Rectangle()
                    .frame(width: 100, height: 150)
                    .foregroundColor(Color("Favourite_Map_Background"))
                
                Circle()
                    .frame(width: 50, height: 50)
                    .foregroundColor(Color("Favourite_Map_Button"))
                
                Image(systemName: "plus")
                    .foregroundColor(.blue)
                    .font(.system(size: 24))
                
            }
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            .shadow(color: .black.opacity(0.1), radius: 6, y: 5)
            .buttonStyle(FavouriteMapCellButtonStyle())
            .padding(.leading, 8)
            .padding(.bottom, 16)
            
        }
        
    }
    
}

private struct FavouriteNades: View {
    
    @Binding var selectedNade: Nade?
    @State var nadeViewIsPresented = false
    
    @StateObject var favouritesViewModel = FavouritesViewModel()
    
    @AppStorage("favourites.nades") var favouriteNades = [String]()
    
    var body: some View {
        
        HStack(alignment: .bottom) {
            
            Text("Grenades")
                .font(.system(size: 20))
                .fontWeight(.semibold)
                .padding(.top, 2)
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
        
        favouritesViewModel.fetchData()
        
    }
    
}

struct FavouriteNadeCell: View {
    
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
    
}
