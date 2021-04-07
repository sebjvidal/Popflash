//
//  MapsDetailView.swift
//  Popflash
//
//  Created by Seb Vidal on 04/02/2021.
//

import SwiftUI
import Kingfisher
import FirebaseFirestore

extension UINavigationController {
    override open func viewDidLoad() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        
        navigationBar.standardAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
    }
}

struct MapsDetailView: View {
    
    var map: Map
    
    @StateObject private var viewModel = NadesViewModel()
    @StateObject private var searchViewModel = NadesViewModel()
    
    @State private var scrollOffset = 0.0
    
    @State private var searchQuery = ""
    
    @AppStorage("tabSelection") var tabSelection: Int = 0
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            ScrollView(axes: .vertical, showsIndicators: true, offsetChanged: {
                
                scrollOffset = Double($0.y)
                
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                
            }) {
                
                Header(map: map, offset: scrollOffset)
                    
                SearchBar(searchQuery: $searchQuery)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                    .onChange(of: searchQuery) {
                        
                        if $0 != "" {
                            
                            self.searchViewModel.fetchData(ref: Firestore.firestore().collection("nades")
                                                                    .whereField("map", isEqualTo: map.name)
                                                                    .whereField("tags", arrayContainsAny: searchQuery.lowercased().split(separator: " ")))
                            
                        }
                        
                    }
                
                NadeList(nades: searchQuery != "" ? $searchViewModel.nades : $viewModel.nades,
                         searchQuery: $searchQuery)

                Spacer()
                    .frame(height: 10)
            
            }
            .onAppear() {
                
                let db = Firestore.firestore()
//
                db.collection("maps").document(map.id).setData([
                    "views": map.views + 1
                ], merge: true)
//
                self.viewModel.fetchData(ref: Firestore.firestore().collection("nades")
                                                  .whereField("map", isEqualTo: map.name))
                
            }
            .navigationBarTitle(Text(""), displayMode: .inline)
            .toolbar {
                
                FavouriteToolbarItem(mapName: map.name)
                
            }
            
            VisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
                .frame(height: 91)
                .edgesIgnoringSafeArea(.top)
                .opacity(scrollOffset >= -90 ? 0 : scrollOffset <= -125 ? 1 : Double((1 / 35) * (-90 - scrollOffset)))
            
            KFImage(URL(string: map.icon))
                .resizable()
                .scaledToFit()
                .frame(width: 45)
                .padding(.top, 39)
                .edgesIgnoringSafeArea(.top)
                .opacity(scrollOffset <= -88 ? 1 : 0)
            
        }
        
    }
    
}

private struct FavouriteToolbarItem: ToolbarContent {
    
    var mapName: String
    
    @AppStorage("favourites.maps") private var favouriteMaps: Array = [String()]
    
    var body: some ToolbarContent {
        
        ToolbarItem(placement: .navigationBarTrailing) {
            
            Button {
                
                if favouriteMaps.contains(mapName) {
                    
                    if let index = favouriteMaps.firstIndex(of: mapName) {
                        
                        favouriteMaps.remove(at: index)
                    }
                    
                } else {
                    
                    favouriteMaps.insert(mapName, at: 0)
                    
                }
                
            } label: {
                
                if favouriteMaps.contains(mapName) {
                    
                    Image(systemName: "heart.fill")
                        .font(.system(size: 21))
                        .foregroundColor(Color("Heart"))
                    
                } else {
                    
                    Image(systemName: "heart")
                        .font(.system(size: 21))
                    
                }
                
            }
            
        }
        
    }
    
}

private struct NadeList: View {
    
    @Binding var nades: [Nade]
    @Binding var searchQuery: String
    
    @State private var selectedNade: Nade?
    
    var body: some View {
        
        if nades.isEmpty {
                
                ForEach(1..<10, id: \.self) { _ in
                    
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .foregroundColor(Color("Loading"))
                        .frame(height: ((UIScreen.screenWidth - 32) / 1.77) + 91)
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                    
                }
                
//            }
            
        } else {
            
            LazyVStack {
                
                ForEach(nades.sorted(by: { $0.tags.count > $1.tags.count }), id: \.self) { nade in

                    Button {
                        
                        self.selectedNade = nade
                        
                    } label: {
                        
                        NadeCell(nade: nade)
                        
                    }
                    .buttonStyle(PlainButtonStyle())
                    .fullScreenCover(item: self.$selectedNade) { item in
                        
                        NadeView(nade: item)
                        
                    }

                }
                
            }

        }
        
    }
    
}

private struct SearchBar: View {
    
    @Binding var searchQuery: String
    
    @State private var isEditing = false
    
    var body: some View {
        
        HStack {
            
            ZStack {
                
                Color("Search_Bar")
                    .frame(height: 38)
                    .cornerRadius(10)
                    .animation(.default)
//                    .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                
                HStack {
                    
                    Image(systemName: "magnifyingglass")
                        .padding(.leading, 12)
                        .foregroundColor(Color("Search_Bar_Icons"))
                    
                    TextField("Search", text: $searchQuery)
                        .font(.system(size: 18))
                        .onTapGesture {
                            
                            self.isEditing = true
                            
                        }
                        .animation(.default)
                    
                    if self.searchQuery != "" {
                        
                        Button {
                            
                            self.searchQuery = ""
                            
                        } label: {
                        
                            Image(systemName: "multiply.circle.fill")
                                .padding(.trailing, 10)
                                .foregroundColor(Color("Search_Bar_Icons"))
                            
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                    }
                    
                }
                
            }
            
            if isEditing {
                
                Button("Cancel") {
                    
                    self.searchQuery = ""
                    self.isEditing = false
                    
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    
                }
                .padding(.horizontal, 6)
                .transition(AnyTransition.move(edge: .trailing).combined(with: .opacity))
                .animation(.default)
                
            }
            
        }
        
    }
    
}

private struct NadeCell: View {
    var nade: Nade
    
    var body: some View {
        
        ZStack(alignment: .topTrailing) {
            
            ZStack(alignment: .bottom) {
                
                NadeCellBackground(thumbnail: nade.thumbnail)
                    .blur(radius: 20)
                    .padding([.leading, .bottom, .trailing], -10.0)
                
                NadeCellBackground(thumbnail: nade.thumbnail)
                    .padding(.bottom, 90)
                
                ZStack {
                    
                    VisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
                        .frame(height: 91)
                    
                    NadeCellDetails(name: nade.name,
                                    shortDescription: nade.shortDescription,
                                    views: nade.views,
                                    favourites: nade.favourites,
                                    tick: nade.tick,
                                    bind: nade.bind)
                        .padding(.top, 8)
                    
                }
                
            }
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            .shadow(radius: 6, y: 5)
            .padding(.leading, 16)
            .padding(.trailing, 16)
            .padding(.bottom, 10)
            
            NadeCellTypeIcon(type: nade.type)
            
        }
        
    }
    
}

private struct NadeCellTypeIcon: View {
    
    var type: String

    var body: some View {

        ZStack {

            VisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .frame(width: 40, height: 40)

            if type == "Molotov" {

                Image("\(type)_Icon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30)

            } else {

                Image("\(type)_Icon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25)

            }

        }
        .padding(.trailing, 24)
        .padding(.top, 8)

    }

}

private struct NadeCellDetails: View {
    
    var name: String
    var shortDescription: String
    
    var views: Int
    var favourites: Int
    var tick: String
    var bind: String
    
    var body: some View {
        
        HStack {
            VStack(alignment: .leading) {
                Text(name)
                    .font(.headline)
                    .lineLimit(1)
                Text(shortDescription)
                    .font(.subheadline)
                    .lineLimit(1)
                HStack {
                    Image(systemName: "eye.fill")
                        .font(.caption2)
                        .padding(.trailing, -4)
                    Text(String(views))
                        .font(.caption2)
                        .padding(.trailing, 16)
                    Image(systemName: "heart.fill")
                        .font(.caption2)
                        .padding(.trailing, -4)
                    Text(String(favourites))
                        .font(.caption2)
                        .padding(.trailing, 16)
                    Image(systemName: "clock.fill")
                        .font(.caption2)
                        .padding(.trailing, -4)
                    Text(tick)
                        .font(.caption2)
                        .padding(.trailing, 16)
                    Image("keyboard.fill")
                        .font(.caption2)
                        .padding(.trailing, -4)
                    Text(bind)
                        .font(.caption2)
                    
                }
                .padding(.top, 4)
            }
            .padding(.leading)
            Spacer()
            Image(systemName: "chevron.right")
                .padding()
        }
        .padding(.bottom, 12)
        
    }
    
}

private struct NadeCellBackground: View {
    
    var thumbnail: String
    
    var body: some View {
        
        KFImage(URL(string: thumbnail))
            .resizable()
            .aspectRatio(contentMode: ContentMode.fill)
            .frame(width: UIScreen.screenWidth - 32, height: (UIScreen.screenWidth - 32) / 1.77)
        
    }
    
}

private struct Header: View {
    
    var map: Map
    var offset: Double
    
    var body: some View {
        
        VStack {
            
            ZStack {
                
                Rectangle()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.clear)
                
                KFImage(URL(string: map.icon))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: offset >= 0 ? 100 : offset <= -88 ? 45 : CGFloat(100 - abs(offset / 1.59)))
                    .opacity(offset <= -88 ? 0 : 1)
                
            }
            
            Text("\(map.name)")
                .font(.system(size: 32))
                .font(.title)
                .fontWeight(.bold)
            
            Text("\(map.group) • \(map.scenario)")
                .foregroundColor(.gray)
                .padding(.bottom, 45)
            
        }
        
    }
    
}
