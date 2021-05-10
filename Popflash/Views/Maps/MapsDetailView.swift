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
    
    @State private var time = Timer.publish(every: 0.1, on: .main, in: .tracking).autoconnect()
    
    @AppStorage("tabSelection") var tabSelection: Int = 0
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            ScrollView(axes: .vertical, showsIndicators: true, offsetChanged: {
                
                scrollOffset = Double($0.y)
                
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                
            }) {
                
//                LazyVStack {
                    
                    Header(icon: map.icon,
                           name: map.name,
                           group: map.group,
                           scenario: map.scenario)
                    
                    SearchBar(searchQuery: $searchQuery)
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                        .onChange(of: searchQuery) {
                            
                            if $0 != "" {
                                
                                let queryArray = searchQuery.lowercased().split(separator: " ")
                                
                                if queryArray.count > 0 {
                                    
                                    self.searchViewModel.fetchData(ref: Firestore.firestore().collection("nades")
                                                                    .whereField("map", isEqualTo: map.name)
                                                                    .whereField("tags", arrayContainsAny: searchQuery.lowercased().split(separator: " ")))
                                    
                                }
                                
                            } else {
                                
                                self.searchViewModel.nades = [Nade]()
                                
                            }
                            
                        }
                    
                    NadeList(nades: searchQuery != "" ? $searchViewModel.nades : $viewModel.nades,
                             searchQuery: $searchQuery,
                             isLoading: false)
                    
                    ProgressView()
                        .padding(.top, 4)
                        .padding(.bottom, 20)
                    
                    GeometryReader { g in

                        Color.clear
                            .onAppear {

                                self.time = Timer.publish(every: 0.1, on: .main, in: .tracking).autoconnect()

                            }
                            .onReceive(self.time) { (_)in

                                if g.frame(in: .global).maxY < UIScreen.screenHeight {
                                    
                                    loadNades()

                                }

                            }

                    }
                    .frame(width: 0, height: 0)
                    
//                }
                
            }
            .onAppear() {
                
//                let db = Firestore.firestore()
//
//                db.collection("maps").document(map.id).setData([
//                    "views": map.views + 1
//                ], merge: true)
                
                loadNades()
                
            }
            .navigationBarTitle(Text(""), displayMode: .inline)
            .toolbar {
                
                FavouriteToolbarItem(mapName: map.name)
                
            }
            
//            VisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
//                            .frame(height: 91)
//                            .edgesIgnoringSafeArea(.top)
//                            .opacity(scrollOffset >= -90 ? 0 : scrollOffset <= -125 ? 1 : Double((1 / 35) * (-90 - scrollOffset)))
//
//            KFImage(URL(string: map.icon))
//                .resizable()
//                .scaledToFit()
//                .frame(width: 45)
//                .padding(.top, 39)
//                .edgesIgnoringSafeArea(.top)
//                .opacity(scrollOffset <= -88 ? 1 : 0)
            
        }
        
    }
    
    func loadNades() {
            
        self.viewModel.fetchData(ref: Firestore.firestore().collection("nades")
                                    .whereField("map", isEqualTo: map.name)
                                    .limit(to: 10))

    }
    
}

private struct Header: View {
    
    var icon: String
    var name: String
    var group: String
    var scenario: String
    
    var body: some View {
        
        VStack {
            
            KFImage(URL(string: icon))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
            
            Text("\(name)")
                .font(.system(size: 32))
                .font(.title)
                .fontWeight(.bold)
            
            Text("\(group) • \(scenario)")
                .foregroundColor(.gray)
                .padding(.bottom, 45)
            
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

private struct NadeList: View {
    
    @Binding var nades: [Nade]
    @Binding var searchQuery: String
    
    @State var isLoading: Bool
    
    @State private var selectedNade: Nade?
    
    var body: some View {
        
        LazyVStack {
            
            ForEach(nades, id: \.self) { nade in
                    
                Button {
                    
                    self.selectedNade = nade
                    
                } label: {
                    
                    NadeCell(nade: nade)
                            .shadow(radius: 6, y: 5)
                    
                }
                .buttonStyle(NadeCellButtonStyle())
                .fullScreenCover(item: self.$selectedNade) { item in
                    
                    NadeView(nade: item)
                    
                }
                
            }
            
        }
        
    }
    
}

struct NadeCell: View {
    
    var nade: Nade
    
    let processor = CroppingImageProcessor(size: CGSize(width: 1284, height: 1), anchor: CGPoint(x: 0.5, y: 1))
    
    var body: some View {
        
        ZStack(alignment: .topTrailing) {
            
            VStack(spacing: 0) {
                
                KFImage(URL(string: nade.thumbnail))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                
                ZStack {
                    
                    KFImage(URL(string: nade.thumbnail))
                        .resizable()
                        .setProcessor(processor)
                        .frame(height: 90)
                    
                    VisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
                        .frame(height: 90)
                    
                    HStack {
                        
                        VStack(alignment: .leading, spacing: 0) {
                            
                            Text(nade.name)
                                .font(.headline)
                            
                            Text(nade.shortDescription)
                                .font(.subheadline)
                                .lineLimit(1)
                            
                            NadeDetails(views: nade.views,
                                        favourites: nade.favourites,
                                        tick: nade.tick,
                                        bind: nade.bind)
                                .padding(.top, 16)
                            
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                        
                    }
                    .padding(.leading, 12)
                    .padding(.trailing)
                    
                }
                
            }
            
            NadeCellTypeIcon(type: nade.type)
            
        }
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        .padding(.horizontal)
        .padding(.bottom, 8)
        
    }
    
}

struct NadeDetails: View {
    
    var views: Int
    var favourites: Int
    var tick: String
    var bind: String
    
    var body: some View {
        
        HStack {
            
            Group {

                Label("\(views)", systemImage: "eye.fill")
                
                Label("\(favourites)", systemImage: "heart.fill")
                
                Label("\(tick)", systemImage: "clock.fill")
                
                Label("\(bind)", image: "keyboard.fill")
                
            }
            .padding(.trailing, 16)
            .font(.system(size: 11))
            
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
        .padding(.trailing, 8)
        .padding(.top, 8)

    }

}

