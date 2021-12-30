//
//  FeaturedView.swift
//  Popflash
//
//  Created by Seb Vidal on 03/02/2021.
//

import SwiftUI
import Kingfisher
import FirebaseFirestore
import FirebaseFirestoreSwift

struct FeaturedView: View {
    
    @StateObject var featuredViewModel = FeaturedViewModel()
    
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
                        
                        FeaturedNade(nades: $featuredViewModel.featuredNade,
                                     selectedNade: $selectedNade)
                        
                        MoreFrom(maps: $featuredViewModel.featuredMap,
                                 selectedNade: $selectedNade)
                        
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(.some(EdgeInsets()))
                    .buttonStyle(.plain)
                    
                }
                .listStyle(.plain)
                .environment(\.defaultMinListRowHeight, 1)
                .navigationBarTitle("Featured", displayMode: .inline)
                .navigationBarHidden(true)
                .background(MapNavigationLink(selectedMap: $selectedMap))
                .overlay(alignment: .top) {
                    StatusBarBlur(outerGeo: outerGeo, statusOpacity: $statusOpacity)
                }
                .refreshable {
                    fetchFeaturedData()
                }
                
            }
            .navigationViewStyle(.stack)
            
        }
        .onOpenURL(perform: handleURL)
        .onAppear(perform: onAppear)
        .sheet(item: self.$selectedNade) { item in
            NadeView(nade: item)
        }
        
    }
    
    func fetchFeaturedData() {
        featuredViewModel.fetchData()
    }
    
    func onAppear() {
        if featuredViewModel.featuredNade.isEmpty {
            fetchFeaturedData()
        }
        
        tabSelection = 0
    }
    
    func handleURL(_ url: URL) {
        if !url.isDeepLink {
            return
        }
        
        if selectedMap != nil {
            return
        }
        
        if tabSelection != 0 {
            return
        }
        
        if !["featured", "map", "nade"].contains(url.host) {
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
    
    @State var dateTimeString = " "
    
    var body: some View {
        
        LazyVStack(alignment: .center, spacing: 0) {
            
            Spacer()
                .frame(height: 35)
            
            HStack {
                
                VStack(alignment: .leading) {
                    Text(dateTimeString)
                        .foregroundColor(.gray)
                        .font(.system(size: 13))
                        .fontWeight(.semibold)
                    
                    Text("Featured")
                        .font(.system(size: 32))
                        .fontWeight(.bold)
                    
                }
                
                Spacer()
                
            }
            
            Divider()
                .padding(.top, 6)
                .padding(.bottom, 16)
            
        }
        .padding(.horizontal)
        .task {
            
            dateTimeString = getDateString().uppercased()
            
        }
        
    }
    
    func getDateString() -> String {
        
        let date = Date()
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "EEEE d MMMM"
        
        let dateString = dateFormatter.string(from: date)
        
        return dateString.uppercased()
        
    }
    
}

private struct FeaturedNade: View {
    
    @Binding var nades: [Nade]
    
    @Binding var selectedNade: Nade?
    
    var body: some View {
        
        VStack {
            
            ForEach(nades, id: \.self) { nade in
                
                Button {
                    
                    selectedNade = nade
                    
                } label: {
                    
                    FeaturedCell(nade: nade)
                        .cellShadow()
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                    
                }
                
            }
            .buttonStyle(MapCellButtonStyle())
            
        }
        
    }
    
}

private struct FeaturedCell: View {
    
    var nade: Nade
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            KFImage(URL(string: nade.thumbnail))
                .resizable()
                .aspectRatio(CGSize(width: 16, height: 9), contentMode: .fit)
            
            VStack(alignment: .leading, spacing: 0) {
                
                Text(nade.map)
                    .foregroundColor(.gray)
                    .fontWeight(.semibold)
                    .padding(.top, 10)
                    .padding(.horizontal)
                
                Text(nade.name)
                    .font(.system(size: 22))
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                Text(nade.shortDescription)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 8)
                    .padding([.horizontal])
                
                VideoInfo(nade: nade)
                    .padding(.top, 10)
                    .padding(.bottom, 12)
                
                Text(nade.longDescription.replacingOccurrences(of: "\\n\\n", with: " "))
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                
                Divider()
                    .padding(.horizontal)
                
                SeeMore()
                
            }
            
        }
        .background(Color("Background"))
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        
    }
    
}


private struct SeeMore: View {
    
    @AppStorage("settings.tint") var tint: Int = 1
    
    var body: some View {
        
        HStack {
            
            Text("Learn More...")
                .foregroundColor(TintColour.colour(withID: tint))
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(TintColour.colour(withID: tint))
            
        }
        .padding(.top, 12)
        .padding(.horizontal, 18)
        .padding(.bottom, 15)
        
    }
    
}

private struct MoreFrom: View {
    
    @Binding var maps: [Map]
    @Binding var selectedNade: Nade?
    
    @State private var action: Int? = 0
    
    var body: some View {
        
        ForEach(maps, id: \.self) { map in
            
            VStack(alignment: .leading, spacing: 0) {
                
                Divider()
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                
                Text("More from \(map.name)")
                    .font(.system(size: 20))
                    .fontWeight(.semibold)
                    .padding(.top, 10)
                    .padding(.leading, 17)
                    .padding(.bottom, 10)
                
                ZStack {
                    
                    NavigationLink(destination: MapsDetailView(map: map), tag: 1, selection: $action) {
                        
                        EmptyView()
                        
                    }
                    .hidden()
                    .disabled(true)
                    
                    Button {
                        
                        action = 1
                        
                    } label: {
                        
                        MapCell(map: map)
                            .cellShadow()
                            .padding(.horizontal)
                            .padding(.bottom)
                        
                    }
                    .buttonStyle(MapCellButtonStyle())
                    
                }
                
                Top5(selectedNade: $selectedNade, map: map.name)
                
            }
            
        }
        
    }
    
}

private struct Top5: View {
    
    @StateObject var top5Nades = NadesViewModel()
    
    @Binding var selectedNade: Nade?
    
    var map: String
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            Text("Top 5 on \(map)")
                .font(.system(size: 20))
                .fontWeight(.semibold)
                .padding(.top, -4)
                .padding(.leading, 17)
                .padding(.bottom, 10)
            
            ScrollView(.horizontal, showsIndicators: false) {
                
                HStack(spacing: 16) {
                    
                    ForEach(top5Nades.nades, id: \.self) { nade in
                        
                        Button {
                            
                            selectedNade = nade
                            
                        } label: {
                            
                            ComplimentCell(nade: nade)
                            
                        }
                        
                    }
                    .buttonStyle(ComplimentsCellButtonStyle())
                    .padding(.bottom, 16)
                    
                }
                .padding(.horizontal)
                .onAppear() {
                    
                    fetchTop5Nades()
                    
                }
                
            }
            
        }
        
    }
    
    func fetchTop5Nades() {
        
        let db = Firestore.firestore()
        
        if top5Nades.nades.isEmpty {
            
            top5Nades.fetchData(ref: db.collection("nades").whereField("map", isEqualTo: map).order(by: "views", descending: true).limit(to: 5))
            
        }
        
    }
    
}

private struct Compliments: View {
    
    @StateObject private var complimentsViewModel = NadesViewModel()
    
    @Binding var nade: Nade
    
    var body: some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            
            VStack(alignment: .leading) {
                
                Divider()
                    .frame(minWidth: UIScreen.screenWidth - 32)
                    .padding(.horizontal)
                    .padding(.bottom, 4)
                    .onAppear() {
                        
                        self.complimentsViewModel.fetchData(ref: Firestore.firestore().collection("nades")
                                                                .whereField("id", in: nade.compliments))
                        
                    }
                
                Text("Use With")
                    .font(.system(size: 20))
                    .fontWeight(.semibold)
                    .padding(.leading, 18)
                
                HStack {
                    
                    Spacer()
                        .frame(width: 16)
                    
                    ForEach(complimentsViewModel.nades, id: \.self) { comp in
                        
                        Button {
                            
                            nade = comp
                            
                        } label: {
                            
                            ZStack(alignment: .top) {
                                
                                Rectangle()
                                    .foregroundColor(Color("Background"))
                                    .frame(width: 220, height: 194)
                                
                                VStack(alignment: .leading) {
                                    
                                    KFImage(URL(string: comp.thumbnail))
                                        .resizable()
                                        .frame(width: 220, height: 112.55)
                                    
                                    Text(comp.map)
                                        .foregroundColor(.gray)
                                        .font(.system(size: 14))
                                        .fontWeight(.semibold)
                                        .padding(.leading, 11)
                                    
                                    Text(comp.name)
                                        .fontWeight(.semibold)
                                        .padding(.top, 0)
                                        .padding(.leading, 11)
                                        .lineLimit(2)
                                    
                                }
                                
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                            .padding(.bottom)
                            .padding(.trailing, 8)
                            
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                    }
                    .cellShadow()
                    
                    Spacer()
                        .frame(width: 8)
                    
                }
                
            }
            
        }
        .frame(width: UIScreen.screenWidth)
        
    }
    
}

struct FeaturedView_Previews: PreviewProvider {
    static var previews: some View {
        FeaturedView()
    }
}
