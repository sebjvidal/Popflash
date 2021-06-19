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
    
    @StateObject var featuredNadeViewModel = NadesViewModel()
    @StateObject var featuredMapViewModel = MapsViewModel()
    
    @State private var statusOppacity = 0.0
    @State private var selectedNade: Nade?
    @State private var nadeViewIsPresented = false
    
    @AppStorage("tabSelection") var tabSelection: Int = 0
    
    var statusBarBlur: some View {
        
        Rectangle()
            .frame(height: UIDevice.current.hasNotch ? 47 : 20)
            .background(.regularMaterial)
            .edgesIgnoringSafeArea(.top)
        
    }
    
    var body: some View {
        
        NavigationView {
                
                List {
                    
                    Group {
                        
                        Header()
                        
                        FeaturedNade(nades: $featuredNadeViewModel.nades,
                                     selectedNade: $selectedNade,
                                     nadeViewIsPresented: $nadeViewIsPresented)

                        MoreFrom(maps: $featuredMapViewModel.maps,
                                 selectedNade: $selectedNade,
                                 nadeViewIsPresented: $nadeViewIsPresented)
                        
                    }
                    .listRowSeparator(.hidden)
                    .buttonStyle(.plain)
                    .fullScreenCover(item: self.$selectedNade) { item in
                        
                        NadeView(nade: item)
                        
                    }
                    .listRowInsets(.some(EdgeInsets()))
                                    
                }
                .listStyle(.plain)
                .navigationBarTitle("Featured", displayMode: .inline)
                .navigationBarHidden(true)
                .refreshable {
                    
                    featuredNadeViewModel.nades.removeAll()
                    fetchFeaturedData()
                    
                }
                .onAppear {
                    
                    if featuredNadeViewModel.nades.isEmpty {
                        
                        fetchFeaturedData()
                        
                    }
                    
                    tabSelection = 0
                                                            
                }
            
        }
        
    }
    
    func fetchFeaturedData() {
        
        let db = Firestore.firestore()
        
        let nadeRef = db.collection("featured").whereField(FieldPath.documentID(), isEqualTo: "nade").limit(to: 1)
        let mapRef = db.collection("featured").whereField(FieldPath.documentID(), isEqualTo: "map").limit(to: 1)
        
        featuredNadeViewModel.fetchData(ref: nadeRef)
        featuredMapViewModel.fetchData(ref: mapRef)
        
    }
    
}

private struct Header: View {
    
    @State var dateTimeString = ""
    
    var body: some View {
        
        LazyVStack(alignment: .center, spacing: 0) {

            Spacer()
                .frame(height: 32)

            HStack {

                VStack(alignment: .leading) {

                    Text(dateTimeString.uppercased())
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
                .padding(.top, 10)
                .padding(.bottom, 4)

        }
        .padding(.horizontal)
        .onAppear() {
            
            dateTimeString = getDateString()
            
        }
        
    }
    
    func getDateString() -> String {
        
        let date = Date()
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "EEEE d MMMM"
        
        let dateString = dateFormatter.string(from: date)
        
        return dateString
        
    }
    
}

private struct FeaturedNade: View {
    
    @Binding var nades: [Nade]
    
    @Binding var selectedNade: Nade?
    @Binding var nadeViewIsPresented: Bool
    
    var body: some View {
        
        VStack {
            
            ForEach(nades, id: \.self) { nade in
                
                Button {
                    
                    selectedNade = nade
                    nadeViewIsPresented.toggle()
                    
                } label: {
                    
                    FeaturedCell(nade: nade)
                        .shadow(radius: 6, y: 5)
                        .padding(.horizontal)
                        .padding(.bottom, 6)
                    
                }
                
            }
            
        }
        
    }
    
}

private struct FeaturedCell: View {
    
    var nade: Nade
    
    var body: some View {
            
        VStack(spacing: 0) {
            
            FeaturedVideo(thumbnail: nade.thumbnail)

            FeaturedVideoDetail(nade: nade)
            
        }
        .background(Color("Background"))
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
    
    }
        
}

private struct MoreFrom: View {
        
    @Binding var maps: [Map]
    @Binding var selectedNade: Nade?
    @Binding var nadeViewIsPresented: Bool
    
    @State private var action: Int? = 0
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            Divider()
                .padding(.horizontal, 16)
                .opacity(maps.isEmpty ? 0 : 1)
            
            ForEach(maps, id: \.self) { map in
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    Text("More from \(map.name)")
                        .font(.system(size: 20))
                        .fontWeight(.semibold)
                        .padding(.top, 10)
                        .padding(.leading, 17)
                        .padding(.bottom, 10)
                        
                    Button {

                        action = 1

                    } label: {
                        
                        MapCell(map: map)
                            .padding(.horizontal, 16)
                            .shadow(radius: 6, y: 5)
                        
                    }
                    
                    NavigationLink(destination: MapsDetailView(map: map), tag: 1, selection: $action) {
                    
                        EmptyView()
                        
                    }
                    .hidden()
                    .disabled(true)
                    
                    Top5(selectedNade: $selectedNade, nadeViewIsPresented: $nadeViewIsPresented, map: map.name)
                    
                }
                
            }
            
        }
        
    }
    
}

private struct Top5: View {
    
    @StateObject var top5Nades = NadesViewModel()
    
    @Binding var selectedNade: Nade?
    @Binding var nadeViewIsPresented: Bool
    
    var map: String
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            Text("Top 5 on \(map)")
                .font(.system(size: 20))
                .fontWeight(.semibold)
                .padding(.leading, 17)
                .padding(.bottom, 2)
            
            ScrollView(axes: .horizontal, showsIndicators: false) {
                
                HStack {
                    
                    Spacer()
                        .frame(width: 16)
                    
                    ForEach(top5Nades.nades, id: \.self) { nade in
                                                
                        Button {
                            
                            print(nade.name)
                            
                            selectedNade = nade
                            nadeViewIsPresented.toggle()
                            
                        } label: {
                            
                            ComplimentCell(nade: nade)
                                .padding(.bottom, 16)
                                .fixedSize()
                            
                        }
                                                
                    }
                    .buttonStyle(ComplimentsCellButtonStyle())
                    
                    Spacer()
                        .frame(width: 8)
                    
                }
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

private struct FeaturedVideo: View {
    
    var thumbnail: String
    
    var body: some View {
        
        KFImage(URL(string: thumbnail))
            .resizable()
            .frame(width: UIScreen.screenWidth - 32,
                   height: (UIScreen.screenWidth - 32 ) / 1.77)
            .aspectRatio(contentMode: .fill)
        
    }
    
}

private struct FeaturedVideoDetail: View {
    
    var nade: Nade
    
    var body: some View {
            
        VStack(alignment: .leading) {
            
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
                .padding(.top, 4)
                .padding([.horizontal])
            
            VideoInfo(nade: nade)
                .padding(.top, -8)
            
            Text(nade.longDescription.replacingOccurrences(of: "\\n", with: "\n"))
                .lineLimit(3)
                .padding([.horizontal])
            
            Divider()
                .padding(.horizontal)
            
            SeeMore()
                .padding(.top, 4)
                .padding(.horizontal, 18)
                .padding(.bottom, 16)
            
        }
        
    }
    
}

private struct SeeMore: View {
    
    var body: some View {
        
        HStack {
            
            Text("Learn More...")
                .foregroundColor(.blue)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.blue)
            
        }
        
    }
    
}

private struct Compliments: View {
    
    @StateObject private var complimentsViewModel = NadesViewModel()
    
    @Binding var nade: Nade
    
    var body: some View {
        
        ScrollView(axes: .horizontal, showsIndicators: false) {
            
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
                    .shadow(radius: 6, y: 5)
                    
                    Spacer()
                        .frame(width: 8)
                    
                }
                
            }
            
        }
        .frame(width: UIScreen.screenWidth)
        
    }
    
}
