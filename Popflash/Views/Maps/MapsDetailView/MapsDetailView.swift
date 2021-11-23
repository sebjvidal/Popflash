import SwiftUI
import Kingfisher
import BottomSheet
import FirebaseAuth
import FirebaseFirestore

struct MapsDetailView: View {
    
    var map: Map
    
    @StateObject private var viewModel = NadesViewModel()
    
    @State private var isFavourite = false
    @State private var selectedNade: Nade?
    @State private var scrollOffset = 0.0
    @State private var searchQuery = ""
    @State private var showingBottomSheet = false
    @State private var selectedMap: Map?
    
    @AppStorage("maps.filter.type") private var selectedType: [String] = ["All"]
    @AppStorage("maps.filter.tick") private var selectedTick: [String] = ["All"]
    @AppStorage("maps.filter.side") private var selectedSide: [String] = ["All"]
    @AppStorage("maps.filter.bind") private var selectedBind: [String] = ["All"]
    
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
        .onOpenURL(perform: handleURL)
        .background(MapNavigationLink(selectedMap: $selectedMap))
        .toolbar {
            
            MoreToolbarItem(showingBottomSheet: $showingBottomSheet)
            
            ToolbarItem(placement: .navigationBarTrailing) {
                
                FavouriteToolbarItem(map: map, isFavourite: $isFavourite)
                
            }
            
        }
        .sheet(item: self.$selectedNade) { item in
            
            NadeView(nade: item)
            
        }
        .bottomSheet(isPresented: $showingBottomSheet,
                     detents: [.medium(), .large()],
                     prefersGrabberVisible: true,
                     uiApplication: UIApplication.shared) {
            
            FilterView(map: map,
                       isFavourite: $isFavourite,
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
                       "side": selectedSide,
                       "bind": selectedBind]
        
        for filter in filters {
            if filter.value != ["All"] {
                filteredRef = filteredRef.whereField(filter.key, isEqualTo: filter.value[0].replacingOccurrences(of: "\n", with: ""))
            }
        }
        
        let tickExclusion = ["64": "128",
                             "128": "64"]
        
        if selectedTick != ["All"] {
            if let exclusion = tickExclusion[selectedTick[0]] {
                filteredRef = filteredRef.whereField("tick", isNotEqualTo: exclusion)
            }
        }
        
        return filteredRef
    }
    
    func handleURL(_ url: URL) {
        if selectedMap != nil {
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

private struct FavouriteToolbarItem: View {
    
    var map: Map

    @Binding var isFavourite: Bool
    @State var isLoading = true
    @State var showingLoginAlert = false
    @State var showingLoginSheet = false
    
    var body: some View {

        Button(action: favourite) {
            
            ZStack {
                
                ProgressView()
                    .progressViewStyle(.circular)
                    .opacity(isLoading ? 1 : 0)
                
                Image(systemName: isFavourite ? "heart.fill" : "heart")
                    .opacity(isLoading ? 0 : 1)
                
            }
            .onAppear(perform: getFavourite)

        }
        .sheet(isPresented: $showingLoginSheet) {
            
            LoginSheet()
            
        }
        .alert(isPresented: $showingLoginAlert) {
            
            Alert(title: Text("Sign In"),
                  message: Text("Sign in to Popflash to add maps to your favourites."),
                  primaryButton: .default(Text("Sign In"), action: showLogin),
                  secondaryButton: .cancel())
            
        }
        
    }
    
    func getFavourite() {
        
        guard let user = Auth.auth().currentUser else {
            
            return
            
        }
        
        if user.isAnonymous {
            
            isLoading = false
            
            return
            
        }
        
        let db = Firestore.firestore()
        let mapRef = db.collection("maps").document(map.id)
        let ref = db.collection("users").document(user.uid).collection("maps").whereField("map", isEqualTo: mapRef)
        
        ref.getDocuments { snapshot, error in
            
            guard let documents = snapshot?.documents else {
                
                return
                
            }
            
            isFavourite = !documents.isEmpty
            
            DispatchQueue.main.async {
                
                isLoading = false
                
            }
            
        }
        
    }
    
    func favourite() {
        
        if isLoading {
            
            return
            
        }
        
        guard let user = Auth.auth().currentUser else {
            
            return
            
        }
        
        if user.isAnonymous {
            
            showingLoginAlert = true
            
        } else {
            
            if isFavourite {
                
                removeFromFavourites()
                
            } else {
                
                addToFavourites()
                
            }
            
        }
        
    }
    
    func addToFavourites() {
        
        guard let user = Auth.auth().currentUser else {
            
            return
            
        }
        
        if user.isAnonymous {
            
            return
            
        }
        
        isLoading = true
        
        let db = Firestore.firestore()
        let ref = db.collection("users").document(user.uid).collection("maps").document()
        
        guard let dateDouble = Double(dateString(from: Date())) else {
            
            return
            
        }
        
        ref.setData([
            "id": map.id,
            "map": db.collection("maps").document(map.id),
            "position": dateDouble
        ]) { error in
            
            isLoading = false
            
            if let error = error {
                
                print(error.localizedDescription)
                
                return
                
            }
            
            isFavourite = true
            
        }
        
    }
    
    func removeFromFavourites() {
        
        guard let user = Auth.auth().currentUser else {
            
            return
            
        }
        
        if user.isAnonymous {
            
            return
            
        }
        
        isLoading = true
        
        let db = Firestore.firestore()
        let mapRef = db.collection("maps").document(map.id)
        let ref = db.collection("users").document(user.uid).collection("maps").whereField("map", isEqualTo: mapRef)
        
        ref.getDocuments { snapshot, error in
            
            guard let documents = snapshot?.documents else {
                
                return
                
            }
            
            for document in documents {
                
                let favRef = db.collection("users").document(user.uid).collection("maps").document(document.documentID)
                
                favRef.delete { error in
                    
                    if let error = error {
                        
                        print(error.localizedDescription)
                        
                        isLoading = false
                        
                        return
                        
                    }
                    
                    isLoading = false
                    isFavourite = false
                    
                }
                
            }
            
        }
        
    }
    
    func showLogin() {
        
        showingLoginSheet = true
        
    }
    
}

private struct MoreToolbarItem: ToolbarContent {
    
    @Binding var showingBottomSheet: Bool

    var body: some ToolbarContent {

        ToolbarItem(placement: .navigationBarTrailing) {

            Button(action: seeMore, label: {

                Image(systemName: "ellipsis")
                
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
    
    var body: some View {
            
        ForEach(nades, id: \.self) { nade in
            
            Button {
                
                selectNade(nade: nade)
                
            } label: {
                
                NadeCell(nade: nade)
                    .equatable()
                    .cellShadow()
                    .padding(.bottom, 8)
                
            }
            .buttonStyle(NadeCellButtonStyle())
            
        }
        
    }
    
    func selectNade(nade: Nade) {
        
        selectedNade = nade
        
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    
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
                            .padding(.horizontal)
                        
                    }
                    .padding(.leading, 12)
                    
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
        
        HStack(spacing: 0) {
            
            Label("\(views)", systemImage: "eye.fill")
            
            Spacer(minLength: 0)
            
            Label("\(favourites)", systemImage: "heart.fill")
            
            Spacer(minLength: 0)
            
            Label("\(tick)", systemImage: "clock.fill")
            
            Spacer(minLength: 0)
            
            Label("\(bind)", systemImage: "keyboard.fill")
            
        }
        .foregroundStyle(.primary)
        .font(.caption2)
        .labelStyle(.compact)
        
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
