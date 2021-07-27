import SwiftUI
import Kingfisher
import BottomSheet
import FirebaseFirestore


struct MapsDetailView: View {
    
    var map: Map
    
    @StateObject private var viewModel = NadesViewModel()
    
    @State private var selectedNade: Nade?
    @State private var scrollOffset = 0.0
    @State private var searchQuery = ""
    @State private var showingBottomSheet = false
    @State private var showingNavigationBarTitle = false
    
    @AppStorage("maps.filter.type") private var selectedType: String = "All"
    @AppStorage("maps.filter.tick") private var selectedTick: String = "All"
    @AppStorage("maps.filter.side") private var selectedSide: String = "All"
    @AppStorage("maps.filter.bind") private var selectedBind: String = "All"
    
    @AppStorage("tabSelection") var tabSelection: Int = 0
    
    var body: some View {
                
        List {
                
            Group {
                
                Header(icon: map.icon,
                       name: map.name,
                       group: map.group,
                       scenario: map.scenario)
                
                SearchBar(placeholder: "Search \(map.name)",
                          query: $searchQuery)
                    .padding(.bottom, 6)
                    .onChange(of: searchQuery) { _ in

                        handleSearch()
                        
                    }
                
                NadeList(nades: $viewModel.nades, selectedNade: $selectedNade)
                    .onChange(of: [selectedType, selectedTick, selectedSide, selectedBind]) { _ in
                        
                        viewModel.nades.removeAll()
                        loadNades()
                        
                    }
                
                ActivityIndicator()
                    .onAppear(perform: loadNades)
                
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
            .listRowSeparator(.hidden)
            .listRowInsets(.some(EdgeInsets()))
            
        }
        .listStyle(.plain)
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(false)
        .toolbar {

            MoreToolbarItem(showingBottomSheet: $showingBottomSheet)
            
            FavouriteToolbarItem(mapName: map.name)
            
        }
        .sheet(item: self.$selectedNade) { item in
            
            NadeView(nade: item)
                            
        }
        .bottomSheet(isPresented: $showingBottomSheet,
                     detents: [.medium(), .large()],
                     prefersGrabberVisible: true) {
            
            FilterView(map: map,
                       selectedType: $selectedType,
                       selectedTick: $selectedTick,
                       selectedSide: $selectedSide,
                       selectedBind: $selectedBind)
            
        }

    }
    
    func loadNades() {

        if searchQuery.isEmpty {
            
            let ref = filteredRef(ref: Firestore.firestore().collection("nades")
                                    .whereField("map", isEqualTo: map.name))
            
            viewModel.fetchData(ref: ref.limit(to: 10))
        
        } else {
            
            let ref = filteredRef(ref: Firestore.firestore().collection("nades")
                                    .whereField("map", isEqualTo: map.name)
                                    .whereField("tags", arrayContainsAny: searchQuery.lowercased().split(separator: " ")))
            
            viewModel.fetchData(ref: ref.limit(to: 10))
        
        }

    }

    func handleSearch() {

        viewModel.nades.removeAll()
        loadNades()

    }
    
    func filteredRef(ref: Query) -> Query {
        
        var filteredRef = ref
        let filters = ["type": selectedType,
                       "tick": selectedTick,
                       "side": selectedSide,
                       "bind": selectedBind]
        
        for filter in filters {
            
            if filter.value != "All" {
                
                filteredRef = filteredRef.whereField(filter.key, isEqualTo: filter.value.replacingOccurrences(of: "\n", with: ""))
                
            }
            
        }
        
        return filteredRef
        
    }
    
}

private struct Header: View {
    
    var icon: String
    var name: String
    var group: String
    var scenario: String
    
    var body: some View {
        
        LazyVStack(alignment: .center) {
            
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
            
        }
        .padding(.top, 4)
        .padding(.bottom, 45)
        
    }
    
}

private struct FavouriteToolbarItem: ToolbarContent {
    
    var mapName: String
    
    @AppStorage("favourites.maps") private var favouriteMaps: Array = [String()]
    
    var body: some ToolbarContent {
        
        ToolbarItem(placement: .navigationBarTrailing) {
            
            Button(action: favourite, label: {
                
                Image(systemName: favouriteMaps.contains(mapName) ? "heart.fill" : "heart")
                
            })
            
        }
        
    }
    
    func favourite() {
        
        if favouriteMaps.contains(mapName) {
            
            if let index = favouriteMaps.firstIndex(of: mapName) {
                
                favouriteMaps.remove(at: index)
            }
            
        } else {
            
            favouriteMaps.insert(mapName, at: 0)
            
        }
        
    }
    
}

private struct MoreToolbarItem: ToolbarContent {
    
    @Binding var showingBottomSheet: Bool

    var body: some ToolbarContent {

        ToolbarItem(placement: .navigationBarTrailing) {

            Button(action: seeMore, label: {

                Image(systemName: "ellipsis.circle")
                
            })

        }

    }

    func seeMore() {

        showingBottomSheet.toggle()

    }

}

private struct NadeList: View {
    
    @Binding var nades: [Nade]
    @Binding var selectedNade: Nade?
    
    @AppStorage("favourites.nades") var favouriteNades: Array = [String]()
    
    var body: some View {
            
        ForEach(nades, id: \.self) { nade in
                
            Button {
                
                self.selectedNade = nade
                
            } label: {
                
                NadeCell(nade: nade)
                    .equatable()
                    .cellShadow()
                    .padding(.bottom, 8)
                
            }
            .buttonStyle(NadeCellButtonStyle())
            .contentShape(Circle())
//            .swipeActions {
//                
//                Button {
//
//                    favouriteButtonAction(nade: nade.id)
//
//                } label: {
//
//                    Label("", image: isFavourite(nadeID: nade.id) ? "Unfavourite_Swipe_Action" : "Favourite_Swipe_Action")
//
//                }
//                .tint(Color("True_Background"))
//                
//                Button {
//                    
//                    print("Tapped!")
//                    
//                } label: {
//
//                    Label("", image: "Share_Swipe_Action")
//                    
//                }
//                .tint(Color("True_Background"))
//                
//            }
            
        }
        
    }
    
    func isFavourite(nadeID: String) -> Bool {
        
        if favouriteNades.contains(nadeID) {
            
            return true
            
        } else {
            
            return false
            
        }
        
    }
    
    func favouriteButtonAction(nade: String) {
        
        if isFavourite(nadeID: nade) {
            
            if let index = favouriteNades.firstIndex(of: nade) {
                
                favouriteNades.remove(at: index)
                
            }
            
        } else {
            
            favouriteNades.append(nade)
            
        }
        
    }
    
}

struct NadeCell: View, Equatable {
    
    var nade: Nade
    
    let processor = CroppingImageProcessor(size: CGSize(width: 1284, height: 1), anchor: CGPoint(x: 0.5, y: 1))
    
    var body: some View {
        
        ZStack(alignment: .topTrailing) {
            
            VStack(spacing: 0) {
                
                KFImage(URL(string: nade.thumbnail))
                    .resizable()
                    .frame(width: UIScreen.screenWidth - 32, height: (UIScreen.screenWidth - 32) / 1.777)
                    .aspectRatio(contentMode: .fit)
                
                ZStack {
                    
                    KFImage(URL(string: nade.thumbnail))
                        .resizable()
                        .setProcessor(processor)
                        .frame(height: 90)
                        .overlay(.regularMaterial)
                    
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
        
    }
    
    static func == (lhs: NadeCell, rhs: NadeCell) -> Bool {
        
        return lhs.nade.id == lhs.nade.id
        
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
                
                Label("\(bind)", systemImage: "keyboard.fill")
                
            }
            .foregroundStyle(.primary)
            .padding(.trailing, 16)
            .font(.system(size: 11))
            
        }
        
    }
    
}

private struct NadeCellTypeIcon: View {

    var type: String

    var body: some View {

        ZStack {

            Image("\(type)_Icon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30)

        }
        .frame(width: 40, height: 40)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .padding(.trailing, 8)
        .padding(.top, 8)

    }

}

private struct ActivityIndicator: View {
    
    var body: some View {
        
        LazyVStack {
            
            ProgressView()
                .padding(.top, 12)
                .padding(.bottom, 20)
            
        }
        
    }
    
}

private struct HeaderOffsetPreferenceKey: PreferenceKey {
    
    static var defaultValue: CGFloat = .zero
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
    
}
