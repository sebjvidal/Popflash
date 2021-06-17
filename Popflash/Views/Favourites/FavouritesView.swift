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
    
    @AppStorage("favourites.nades") var favouriteNades: Array = [String]()
    
    var statusBarBlur: some View {
        
        Rectangle()
            .frame(height: 47)
            .background(.regularMaterial)
            .edgesIgnoringSafeArea(.top)
            .opacity(statusOpacitiy)
        
    }
    
    var body: some View {
        
        NavigationView {
            
            ZStack {
                
                ScrollView {
                    
                    VStack {
                        
                        Header()
                        
                        FavouriteMaps(isShowing: $isShowing)
                        
                        FavouriteNades()
                        
                    }
                    
                }
                .onAppear {
                    
                    standard.set(2, forKey: "tabSelection")
                    
                }
                .navigationBarTitle("Favourites", displayMode: .inline)
                .navigationBarHidden(true)
                
                statusBarBlur
                
            }
            .sheet(isPresented: $isShowing, content: {
                
                EditFavouriteMapsView()
                
            })
            .navigationBarTitle("", displayMode: .inline)
            
        }
        
    }
    
}

private struct FavouriteMaps: View {
    
    @Binding var isShowing: Bool
    
    @ObservedObject var mapsViewModel = MapsViewModel()
    
    @State private var showingFavouriteMapsEdittingView = false
    
    @AppStorage("tabSelection") var tabSelection: Int = 0
    @AppStorage("favourites.maps") private var favouriteMaps: Array = [String]()
    
    var body: some View {
        
        ScrollView(axes: .horizontal,
                   showsIndicators: false) {
            
            VStack(alignment: .leading) {
                
                Divider()
                    .frame(minWidth: UIScreen.screenWidth - 32)
                    .padding(.horizontal)
                    .padding(.bottom, 4)
                
                Text("Maps")
                    .font(.system(size: 20))
                    .fontWeight(.semibold)
                    .padding(.leading, 18)

                HStack {
                    
                    Spacer()
                        .frame(width: 8)
                    
                    if mapsViewModel.maps.isEmpty {
                        
                        ForEach(favouriteMaps.filter({ $0 != "" }), id: \.self) { _ in
                            
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .frame(width: 100, height: 150)
                                .foregroundColor(Color("Loading"))
                                .padding(.leading, 8)
                                .padding(.bottom, 16)
                            
                        }
                        
                    } else {
                        
                        ForEach(favouriteMaps.filter({ $0 != "" }), id: \.self) { favouriteMap in
                            
                            let map = mapsViewModel.maps.first(where: { $0.name == favouriteMap })!
                            
                            NavigationLink(destination: MapsDetailView(map: map)) {
                                
                                FavouriteMapCell(map: map)
                                    .contentShape(Rectangle())
                                
                            }
                            .buttonStyle(FavouriteMapCellButtonStyle())
                            
                        }
                        
                    }
                    
                    EditFavouritesButton(isShowing: $isShowing)
                    
                    Spacer()
                        .frame(width: 24)
                    
                }
                .buttonStyle(FavouriteMapCellButtonStyle())
                
                Divider()
                    .frame(minWidth: UIScreen.screenWidth - 32)
                    .padding(.top, -8)
                    .padding(.horizontal)
                
            }
            
        }
        .padding(.top, -6)
        .onAppear() {
            
            tabSelection = 2
            
            self.mapsViewModel.fetchData(ref: Firestore.firestore().collection("maps"))
            
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
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .shadow(radius: 5, y: 4)
        .padding(.leading, 8)
        .padding(.bottom, 16)
        
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
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .shadow(color: Color.black.opacity(0.15), radius: 5, y: 4)
            .padding(.leading, 8)
            .padding(.bottom, 16)
            
        }
        
    }
    
}

private struct FavouriteNades: View {
    
    @StateObject var favouritesViewModel = NadesViewModel()
    
    @AppStorage("favourites.nades") var favouriteNades = [String]()
    
    @State var selectedNade: Nade?
    @State var nadeViewIsPresented = false
    
    var body: some View {
        
        VStack {
            
            HStack {
                
                Text("Grenades")
                    .font(.system(size: 20))
                    .fontWeight(.semibold)
                    .padding(.top, -4)
                    .padding(.leading, 2)
                
                Spacer()
                
            }
            
            ForEach(favouritesViewModel.nades, id: \.self) { nade in
                    
                Button {
                    
                    self.selectedNade = nade
                    nadeViewIsPresented.toggle()
                    
                } label: {
                    
                    FavouriteNadeCell(nade: nade)
                        .padding(.bottom, 8)
                    
                }
                .buttonStyle(FavouriteNadeCellButtonStyle())
                .fullScreenCover(item: self.$selectedNade) { item in
                    
                    NadeView(nade: item)
                    
                }
                
            }
            
            Spacer(minLength: 12)
            
        }
        .padding(.horizontal)
        .onAppear() {
            
            if !favouriteNades.isEmpty {
                
                self.favouritesViewModel.fetchData(ref: Firestore.firestore().collection("nades").whereField("id", in: favouriteNades))
                
            }
            
        }
        
    }
    
}

private struct FavouriteNadeCell: View {
    
    var nade: Nade
    
    let processor = CroppingImageProcessor(size: CGSize(width: 1, height: 722), anchor: CGPoint(x: 1, y: 0.5))
    
    var body: some View {
        
        HStack(spacing: 0) {
            
            KFImage(URL(string: nade.thumbnail))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 166, height: 106)
                .clipped()
            
            ZStack {
                
                KFImage(URL(string: nade.thumbnail))
                    .setProcessor(processor)
                    .resizable()
                    .frame(height: 106)
                    .overlay(.regularMaterial)
                
                VStack(alignment: .leading) {

                    Text(nade.map)
                        .foregroundColor(.gray)
                        .font(.system(size: 14))
                        .fontWeight(.semibold)
                        .padding(.top, 8)
                        .padding(.leading, 4)

                    Text(nade.name)
                        .fontWeight(.semibold)
                        .padding(.top, 0)
                        .padding(.leading, 4)
                        .lineLimit(2)

                    Spacer()

                    HStack {

                        Image(systemName: "eye.fill")
                            .font(.system(size: 10))

                        Text(String(nade.views))
                            .font(.system(size: 12))

                        Image(systemName: "heart.fill")
                            .font(.system(size: 12))

                        Text(String(nade.favourites))
                            .font(.system(size: 12))

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .padding(.trailing, 12)

                    }
                    .padding(.leading, 6)
                    .padding(.bottom, 10)

                }
                .padding(.leading, 8)
                
            }
            
        }
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .shadow(radius: 6, y: 4)
        
    }
    
}

private struct Header: View {
    
    var body: some View {
        
        VStack {
            
            Spacer()
                .frame(height: 48)
            
            HStack {
                
                Text("Favourites")
                    .font(.system(size: 32))
                    .fontWeight(.bold)
                    .padding(.leading)
                
                Spacer()
                
            }
            
        }
        
    }
    
}
