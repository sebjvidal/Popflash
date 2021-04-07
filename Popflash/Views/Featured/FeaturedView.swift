//
//  FeaturedView.swift
//  Popflash
//
//  Created by Seb Vidal on 03/02/2021.
//

import SwiftUI
import Kingfisher
import FirebaseFirestore

struct FeaturedView: View {
    
    @State var statusOppacity = 0.0
    @State var selectedNade: Nade?
    @State var nadeViewIsPresented = false
    
    @AppStorage("tabSelection") var tabSelection: Int = 0
    
    var statusBarBlur: some View {
        
        VisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
            .frame(height: 47)
            .edgesIgnoringSafeArea(.top)
        
    }
    
    var body: some View {
        
        NavigationView {
            
            ZStack(alignment: .top) {
                
                ScrollView(offsetChanged: {
                    
                    let offset = $0.y
                    
                    statusOppacity = Double((1 / 35) * -offset)
                    
                }) {
                    
                    VStack(alignment: .leading) {
                        
                        Header()
                        
                        FeaturedNade(selectedNade: $selectedNade, nadeViewIsPresented: $nadeViewIsPresented)
                        
                        Divider()
                            .padding(.horizontal, 16)
                        
                        MoreFrom(selectedNade: $selectedNade, nadeViewIsPresented: $nadeViewIsPresented)
                        
                    }
                    .buttonStyle(PlainButtonStyle())
                    .fullScreenCover(item: self.$selectedNade) { item in
                        
                        NadeView(nade: item)
                        
                    }
                                    
                }
                .onAppear {
                    
                    tabSelection = 0
                                                            
                }
                
                statusBarBlur
                    .opacity(statusOppacity)
                
            }
            .navigationBarTitle("Featured", displayMode: .inline)
            .navigationBarHidden(true)
            
        }
        
    }
    
}


private struct Header: View {
    
    @State var dateTimeString = ""
    
    var body: some View {
        
        VStack {
            
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
                .padding(.leading)
                
                Spacer()
                
            }
            
            Divider()
                .padding(.horizontal)
                .padding(.top, 2)
                .padding(.bottom, 8)
            
        }
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
    
    @StateObject var featuredNades = NadesViewModel()
    
    @Binding var selectedNade: Nade?
    @Binding var nadeViewIsPresented: Bool
    
    var body: some View {
        
        VStack {
            
            ForEach(featuredNades.nades, id: \.self) { nade in
                
                Button {
                    
                    selectedNade = nade
                    nadeViewIsPresented.toggle()
                    
                } label: {
                    
                    FeaturedCell(nade: nade)
                        .cornerRadius(15)
                        .clipped()
                        .shadow(radius: 6, y: 5)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                    
                }
                
            }
            
        }
        .onAppear() {
            
            let db = Firestore.firestore()
            
            featuredNades.fetchData(ref: db.collection("featured").whereField(FieldPath.documentID(), isEqualTo: "nade"))
            
        }
        
    }
    
}

private struct FeaturedCell: View {
    
    var nade: Nade
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            Rectangle()
                .foregroundColor(Color("Background"))
            
            VStack {
                
                FeaturedVideo(thumbnail: nade.thumbnail)
                
                FeaturedVideoDetail(nade: nade)
                
            }
            
        }

    }
    
}

private struct MoreFrom: View {
    
    @StateObject var featuredMap = MapsViewModel()
    
    @Binding var selectedNade: Nade?
    @Binding var nadeViewIsPresented: Bool
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            ForEach(featuredMap.maps, id: \.self) { map in
                
                VStack(alignment: .leading) {
                    
                    Text("More from \(map.name)")
                        .font(.system(size: 20))
                        .fontWeight(.semibold)
                        .padding(.top, 3)
                        .padding(.leading, 17)
                        .padding(.bottom, 3)
                    
                    NavigationLink(destination: MapsDetailView(map: map)) {
                        
                        MapCell(map: map)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 10)
                            .shadow(radius: 6, y: 5)
                        
                    }
                    
                    Top5(selectedNade: $selectedNade, nadeViewIsPresented: $nadeViewIsPresented, map: map.name)
                    
                }
                
            }
            
        }
        .onAppear() {
            
            let db = Firestore.firestore()
            
            featuredMap.fetchData(ref: db.collection("featured").whereField(FieldPath.documentID(), isEqualTo: "map"))
            
        }
        
    }
    
}

private struct Top5: View {
    
    @StateObject var top5Nades = NadesViewModel()
    
    @Binding var selectedNade: Nade?
    @Binding var nadeViewIsPresented: Bool
    
    var map: String
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            Text("Top 5 on \(map)")
                .font(.system(size: 20))
                .fontWeight(.semibold)
                .padding(.top, -2)
                .padding(.leading, 17)
            
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
                            
                            ComplimentsCell(comp: nade)
                                .shadow(radius: 6, y: 5)
                                .padding(.bottom, 4)
                            
                        }
                                                
                    }
                    
                    Spacer()
                        .frame(width: 16)
                    
                }
                .onAppear() {
                    
                    let db = Firestore.firestore()
                    
                    top5Nades.fetchData(ref: db.collection("nades").whereField("map", isEqualTo: map).order(by: "views", descending: true).limit(to: 5))
                    
                }
                
            }
            .padding(.top, -4)
            
        }
        
    }
    
}

private struct ComplimentsCell: View {
    
    var comp: Nade
    
    var body: some View {
        
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
    
}

private struct FeaturedVideoDetail: View {
    
    var nade: Nade
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(nade.map)
                    .foregroundColor(.gray)
                    .fontWeight(.semibold)
                    .padding(.top, 2)
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
                    .padding(.top, 4)
                    .padding(.horizontal)
                
                SeeMore()
                    .padding(.horizontal, 18)
                    .padding(.top, 4)
                    .padding(.bottom, 15)
            }
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
                        
                        print(nade.compliments)
                        
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

struct FeaturedView_Previews: PreviewProvider {
    static var previews: some View {
        FeaturedView()
    }
}
