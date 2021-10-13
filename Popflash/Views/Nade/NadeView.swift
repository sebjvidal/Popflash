//
//  NadeView.swift
//  Popflash
//
//  Created by Seb Vidal on 11/02/2021.
//

import SwiftUI
import Kingfisher
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import AVKit

struct NadeView: View {
    
    @State var nade: Nade
    @State var player = AVPlayer()
    @State var isPlaying = false
    @State var progress: Float = 0
    @State var showControls = false
    @State var fullscreen = false
    @State var selection = "Video"
    
    var body: some View {
                        
        VStack(spacing: 0) {

            NadeContent(nade: nade,
                        player: player,
                        contentSelection: selection,
                        fullscreen: $fullscreen)

            SegmentedControl(selection: $selection)
            
            ScrollView {
                
                ScrollViewReader { scrollView in
                    
                    Details(nade: nade)
                        .id(0)
                        .onChange(of: nade) { _ in
                            
                            scrollView.scrollTo(0, anchor: .top)
                            
                        }
                    
                    Share(nade: nade)
                    
                    Compliments(nade: $nade, player: $player)
                    
                }
                
            }
            
        }
        .animation(.easeInOut(duration: 0.25), value: fullscreen)
        .onAppear(perform: onAppear)
        .background {
            
            Color.black
                .opacity(fullscreen ? 1 : 0)
                .edgesIgnoringSafeArea(.all)
                .animation(.easeInOut(duration: 0.25), value: fullscreen)

        }
        
    }
    
    func onAppear() {
        
        incrementViews()
        addToRecentlyViewed()
        
    }
    
    func incrementViews() {
            
        let db = Firestore.firestore()
        let viewsRef = db.collection("nades").document(nade.documentID)
        
        viewsRef.updateData([
            
            "views": FieldValue.increment(1.0)
            
        ])
        
    }
    
    func addToRecentlyViewed() {
        
        guard let user = Auth.auth().currentUser else {
            
            return
            
        }
        
        if user.isAnonymous {
            
            return
            
        }
        
        removeDuplicateViews(forUser: user.uid)
        
    }
    
    func removeDuplicateViews(forUser user: String) {
        
        let lowerDate = date(bound: .lower)
        let lowerString = dateString(from: lowerDate)
        
        guard let lowerDouble = Double(lowerString) else {
            
            return
            
        }
        
        let upperDate = date(bound: .upper)
        let upperString = dateString(from: upperDate)
        
        guard let upperDouble = Double(upperString) else {
            
            return
            
        }
        
        let db = Firestore.firestore()
        let recentRef = db.collection("nades").document(nade.documentID)
        let ref = db.collection("users").document(user).collection("recents")
            .whereField("ref", isEqualTo: recentRef)
            .whereField("dateAdded", isGreaterThan: lowerDouble)
            .whereField("dateAdded", isLessThan: upperDouble)
        
        ref.getDocuments { snapshot, error in
            
            guard let documents = snapshot?.documents else { return }
            
            for document in documents {

                db.collection("users").document(user).collection("recents").document(document.documentID).delete()
                
            }
            
            addRecent(forUser: user)
            
        }
        
    }
    
    func addRecent(forUser user: String) {
 
        var recentNade = nade
        
        recentNade.dateAdded = favouriteDate()
        
        let db = Firestore.firestore()
        let ref = db.collection("users").document(user).collection("recents").document()
        let recent = db.collection("nades").document(nade.documentID)
        
        guard let dateAdded = Double(dateString(from: Date())) else {
            
            return
            
        }
        
        ref.setData([
            "ref": recent,
            "dateAdded": dateAdded
        ]) { error in
            
            if let error = error {
                
                print(error.localizedDescription)
                
            }
            
        }
        
    }
    
    func favouriteDate() -> Double {
        
        let date = Date()
        let dateString = dateString(from: date)
        let dateDouble = Double(dateString) ?? 0
        
        return dateDouble
        
    }
    
}

private struct CloseButton: View {
    
    @State var player: AVPlayer
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        
        Button {
            
            player.pause()
            dismiss()
            
        } label: {
                
            Image(systemName: "multiply")
                .font(.system(size: 20, weight: .semibold))
                .frame(width: 35, height: 35)
                .background(.regularMaterial)
                .cornerRadius(25)
            
        }
        .buttonStyle(PlainButtonStyle())
        
    }
    
}

private struct NadeContent: View {
    
    var nade: Nade
    var player: AVPlayer
    var contentSelection: String
    
    @Binding var fullscreen: Bool
    
    var body: some View {
        
        ZStack {
            
            VideoView(nade: nade, player: player, fullscreen: $fullscreen)
                .opacity(contentSelection == "Video" ? 1 : 0)
            
            KFImage(URL(string: nade.lineup))
                .resizable()
                .frame(height: UIScreen.screenWidth / 1.777)
                .pinchToZoom()
                .opacity(contentSelection == "Line-up" ? 1 : 0)
            
        }
        .padding(.top, fullscreen ? 78 : 0)
        .zIndex(1)
        
    }
    
}

private struct VideoView: View {
    
    @State var nade: Nade
    @State var player: AVPlayer
    @State var isPlaying = false
    @State var progress: Float = 0
    @State var showControls = false
    
    @Binding var fullscreen: Bool
    
    @AppStorage("settings.autoPlayVideo") var autoPlayVideo = false
    
    var body: some View {
            
        GeometryReader { geo in
            
            ZStack {
                
                VideoPlayer(player: player)
                    .onTapGesture {
                        
                        showControls.toggle()
                        
                    }
                    .onAppear(perform: setupPlayer)
                    .onDisappear(perform: resetPlayer)

                VideoControls(player: $player, isPlaying: $isPlaying, progress: $progress, fullscreen: $fullscreen, showControls: $showControls)
                
            }
            .preference(key: SheetOffsetPreferenceKey.self, value: geo.frame(in: .global).minY)
            
        }
        .frame(width: width(), height: height())
        .onPreferenceChange(SheetOffsetPreferenceKey.self) {
            
            fullscreen = $0 == 0
            
            if $0 <= 57 && $0 > 0 {
                
                AppDelegate.orientationLock = UIInterfaceOrientationMask.allButUpsideDown
                
            } else {
                
                AppDelegate.orientationLock = UIInterfaceOrientationMask.portrait
                
            }
            
        }
        
    }
    
    func width() -> CGFloat {
        
        return fullscreen ? UIScreen.screenWidth * 1.777 : UIScreen.screenWidth
        
    }
    
    func height() -> CGFloat {
        
        return fullscreen ? UIScreen.screenWidth : (UIScreen.screenWidth) / 1.777
        
    }
    
    func setupPlayer() {
        
        player.replaceCurrentItem(with: AVPlayerItem(url: URL(string: nade.video)!))
        
        self.player.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 100), queue: .main) { (_) in
            
            self.progress = getSliderValue()
            
            if self.progress == 1.0 {
                
                self.isPlaying = false
                
            }
            
        }
        
        if autoPlayVideo {
            
            self.isPlaying = true
            self.player.play()
            
        }
        
    }
    
    func resetPlayer() {
        
        self.isPlaying = false
        self.player.pause()
        
    }
    
    func getSliderValue() -> Float {
        
        return Float(self.player.currentTime().seconds / (self.player.currentItem?.duration.seconds)!)
        
    }
    
    func getSeconds() -> Double {
        
        return Double(Double(self.progress) * (self.player.currentItem?.duration.seconds)!)
        
    }
    
}

private struct SheetOffsetPreferenceKey: PreferenceKey {
    
    static var defaultValue: CGFloat = .zero
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
    
}

private struct VideoControls: View {
    
    @Binding var player: AVPlayer
    @Binding var isPlaying: Bool
    @Binding var progress: Float
    @Binding var fullscreen: Bool
    @Binding var showControls: Bool
    
    var body: some View {
        
        ZStack {
            
            Color.black
                .opacity(0.4)
                .onTapGesture(perform: toggleControls)
            
            VStack {
                
                HStack {
                    
                    Spacer()
                    
                    Button(action: rewind, label: {
                        
                        Image(systemName: "backward.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 26))
                        
                    })
                    
                    Spacer()
                    
                    Button(action: playPause, label: {
                        
                        Image(systemName: progress == 1 ? "gobackward" : isPlaying ? "pause.fill" : "play.fill")
                            .foregroundColor(.white)
                            .font(.system(size: progress == 1 ? 36 : 42, weight: progress == 1 ? .bold : .regular))
                        
                    })
                    .frame(width: 45)
                    
                    Spacer()
                    
                    Button(action: forward, label: {
                        
                        Image(systemName: "forward.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 26))
                        
                    })
                    
                    Spacer()
                    
                }
                
            }
            
            VStack {
                
                Spacer()
                
                HStack(spacing: 16) {
                    
                    ProgressBar(value: $progress, player: $player, isplaying: $isPlaying)
                    
                    Button(action: manualFullscreen) {
                        
                        Image(fullscreen ? "minimise" : "maximise")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                        
                    }
                
                }
                .padding(.horizontal, fullscreen ? 34 : 20)
                .padding(.bottom, fullscreen ? 26: 16)
                
            }
            
        }
        .opacity(showControls ? 1 : 0)
        .animation(.easeInOut(duration: 0.25), value: showControls)
        
    }
    
    func toggleControls() {
        
        showControls.toggle()
        
    }
    
    func rewind() {
        
        let wasPlaying = isPlaying
        
        player.pause()
        player.seek(to: CMTime(seconds: 0, preferredTimescale: 1))
        progress = 0
        
        if wasPlaying {
            
            player.play()
            
            
        }
        
    }
    
    func playPause() {
        
        if !isPlaying {
            
            if progress == 1 {
                
                player.seek(to: CMTime(seconds: 0, preferredTimescale: 1))
                
            }
            
            player.play()
            isPlaying = true
            
        } else {
            
            player.pause()
            isPlaying = false
            
        }
        
    }
    
    func forward() {
        
        guard let playerItem = player.currentItem else {
            
            return
            
        }
        
        if !CMTIME_IS_INDEFINITE(playerItem.duration) && !CMTIME_IS_INVALID(playerItem.duration) {
            
            player.seek(to: playerItem.duration, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.positiveInfinity)
            progress = 1
            
        }
        
    }
    
    func manualFullscreen() {
        
        if fullscreen {
            
            UIDevice.current.setValue(UIDeviceOrientation.portrait.rawValue, forKey: "orientation")
            
        } else {
            
            UIDevice.current.setValue(UIDeviceOrientation.landscapeRight.rawValue, forKey: "orientation")
            
        }
        
    }
    
}

struct SegmentedControl: View {

    @Binding var selection: String
    
    var options = ["Video", "Line-up"]
    
    var body: some View {
        
        Picker("Content View", selection: $selection) {
            
            ForEach(options, id: \.self) { option in
                
                Text(option)
                
            }
            
        }
        .frame(maxWidth: UIScreen.screenWidth)
        .pickerStyle(.segmented)
        .padding([.top, .horizontal])
        .padding(.bottom, 10)
        
    }
    
}

private struct Details: View {
    
    var nade: Nade
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            HStack {
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    Text(nade.map)
                        .foregroundColor(.gray)
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                    
                    Text(nade.name)
                        .font(.system(size: 22))
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    Text(nade.shortDescription)
                        .padding(.top, 8)
                        .padding(.horizontal)
                    
                }
                
                Spacer(minLength: 0)
                
                FavouriteButton(nade: nade)
                    .padding()
                
            }
            
            VideoInfo(nade: nade)
                .padding(.top, 12)
                .padding(.bottom, 12)
            
            if !nade.warning.isEmpty {
                
                Warning(warning: nade.warning)
                
            }
            
            Text(nade.longDescription.replacingOccurrences(of: "\\n", with: "\n"))
                .padding(.horizontal)
            
        }
        
    }
    
    func videoDetails(nade: Nade) -> [Detail] {
        
        let details = [Detail(name: "VIEWS", value: "\(nade.views)", image: Image(systemName: "eye.fill")),
                       Detail(name: "FAVOURITES", value: "\(nade.favourites)", image: Image(systemName: "heart.fill")),
                       Detail(name: "TICK RATE", value: nade.tick, image: Image(systemName: "clock.fill")),
                       Detail(name: "JUMP BIND", value: nade.bind, image: Image(systemName: "keyboard.fill")),
                       Detail(name: "SIDE", value: nade.side, image: Image("\(nade.side.lowercased()).fill")),
                       Detail(name: "TYPE", value: nade.type, image: Image(systemName: "circle.fill"))]
        
        return details
        
    }
    
}

private struct FavouriteButton: View {

    var nade: Nade
    
    @State private var loading = true
    @State private var isFavourite = false
    @State private var showingLoginAlert = false
    @State private var showingLoginSheet = false
    
    @AppStorage("settings.tint") var tint: Int = 1
    
    var body: some View {
        
        Button(action: favouriteAction) {
            
            if loading {
                
                ProgressView()
                    .progressViewStyle(.circular)
                
            } else {
                
                Image(systemName: isFavourite ? "heart.fill" : "heart")
                    .font(.system(size: 21))
                    .foregroundColor(isFavourite ? Color("Heart") : TintColour.colour(withID: tint))
                    .offset(y: 0.5)
                
            }
            
        }
        .frame(width: 40, height: 40)
        .background(.regularMaterial)
        .clipShape(Circle())
        .onAppear(perform: getFavourite)
        .sheet(isPresented: $showingLoginSheet) {
            
            LoginSheet()
            
        }
        .alert(isPresented: $showingLoginAlert) {
            
            Alert(title: Text("Sign In"),
                  message: Text("Sign in to Popflash to add grenade line-ups to your favourites."),
                  primaryButton: .default(Text("Sign In"), action: showLogin),
                  secondaryButton: .cancel())
            
        }
        
    }

    
    func getFavourite() {
        
        guard let user = Auth.auth().currentUser else { return }
        
        if user.isAnonymous {
        
            loading = false
            
            return
            
        }
        
        let db = Firestore.firestore()
        let ref = db.collection("users").document(user.uid).collection("nades").whereField("id", isEqualTo: nade.id)
        
        ref.getDocuments { snapshot, error in
            
            guard let documents = snapshot?.documents else { return }
            
            for document in documents {
                
                let data = document.data()
                
                if data["id"] as! String == nade.id {
                    
                    isFavourite = true
                    
                }
                
            }
            
            loading = false
            
        }
        
    }
    
    func favouriteAction() {
        
        if loading {
            
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
        
        guard let user = Auth.auth().currentUser else { return }
        
        if user.isAnonymous { return }
        
        loading = true
        
        let db = Firestore.firestore()
        let ref = db.collection("users").document(user.uid).collection("nades").document()
        
        var favouriteNade = nade
        
        favouriteNade.dateAdded = favouriteDate()
        
        do {
            
            try ref.setData(from: favouriteNade, completion: { error in
                
                if let error = error {
                    
                    print(error.localizedDescription)
                    
                    return
                    
                }
                
                isFavourite = true
                loading = false
                
            })
            
        } catch let error {
            
            print(error.localizedDescription)
            
        }
        
    }
    
    func removeFromFavourites() {
        
        guard let user = Auth.auth().currentUser else { return }
        
        if user.isAnonymous { return }
        
        loading = true
        
        let db = Firestore.firestore()
        let ref = db.collection("users").document(user.uid).collection("nades").whereField("id", isEqualTo: nade.id)
        
        ref.getDocuments { snapshot, error in
            
            guard let documents = snapshot?.documents else { return }
            
            for document in documents {
                
                db.collection("users").document(user.uid).collection("nades").document(document.documentID).delete() { error in
                    
                    if let error = error {
                        
                        print(error.localizedDescription)
                        
                    }
                    
                    isFavourite = false
                    loading = false
                    
                }
                
            }
            
        }
        
    }
    
    func favouriteDate() -> Double {
        
        let date = Date()
        let formatter = DateFormatter()
        
        formatter.dateFormat = "yyyyMMddHHmmss"
        
        let dateString = formatter.string(from: date)
        let dateDouble = Double(dateString) ?? 0
        
        print(dateDouble)
        
        return dateDouble
        
    }
    
    func showLogin() {
        
        showingLoginSheet = true
        
    }
    
}

struct VideoInfo: View {
    
    var nade: Nade

    var body: some View {
    
        ScrollView(.horizontal, showsIndicators: false) {
        
            VStack {
            
                Divider()
                    .padding(.horizontal)
                    
                HStack {
                    
                    Spacer()
                        .frame(width: 24)
                
                    ForEach(videoDetails(detailsOf: nade), id: \.self) { detail in
                    
                        ZStack {
                            
                            detail.image
                                .foregroundColor(Color("Detail_Icon"))
                                .frame(width: 80)
                        
                            VStack {
                    
                                Text(detail.name)
                                    .font(.system(size: 11))
                                    .fontWeight(.semibold)
                                
                                Spacer()
                                    .frame(height: 36)
                                
                                Text(detail.value)
                                    .font(.system(size: 12))
                                    .fontWeight(.semibold)
                                    
                            }
                        
                        }
                        .padding(.vertical, 2)
                        .padding(.horizontal, 4)
                        .foregroundColor(Color("Detail_Name"))
                        
                        if detail != videoDetails(detailsOf: nade).last {

                            Divider()
                                .frame(height: 40)

                        }
                    
                    }
                    
                    Spacer()
                        .frame(width: 24)
                
                }
                
                Divider()
                    .padding(.horizontal)

            
            }
        
        }
    
    }
    
    func videoDetails(detailsOf: Nade) -> [Detail] {
        
        let nade = detailsOf
        
        let details = [Detail(name: "VIEWS", value: "\(nade.views)", image: Image(systemName: "eye.fill")),
                       Detail(name: "FAVOURITES", value: "\(nade.favourites)", image: Image(systemName: "heart.fill")),
                       Detail(name: "TICK RATE", value: nade.tick, image: Image(systemName: "clock.fill")),
                       Detail(name: "JUMP BIND", value: nade.bind, image: Image(systemName: "keyboard.fill")),
                       Detail(name: "SIDE", value: nade.side, image: Image("\(nade.side.lowercased()).fill")),
                       Detail(name: "TYPE", value: nade.type, image: Image(systemName: "circle.fill"))]
        
        return details
        
    }

}

private struct Warning: View {
    
    var warning: String
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            HStack {

                Image(systemName: "exclamationmark.triangle.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.black, .yellow)
                    .font(.system(size: 24))
                    .padding(.leading, 4)
                    .padding(.trailing, 4)
                
                Text("\(warning)")
                
            }
            
            Divider()
                .padding(.top, 8)
            
        }
        .padding(.horizontal)
        
    }
    
}

private struct Compliments: View {
    
    @StateObject private var complimentsViewModel = NadesViewModel()
    
    @Binding var nade: Nade
    @Binding var player: AVPlayer
    
    let processor = CroppingImageProcessor(size: CGSize(width: 1284, height: 1), anchor: CGPoint(x: 0.5, y: 1.0))
    
    var body: some View {
        
        if !nade.compliments.isEmpty {
            
            ScrollView(.horizontal, showsIndicators: false) {
                
                VStack(alignment: .leading, spacing: 11) {
                    
                    Text("Use With")
                        .font(.system(size: 20))
                        .fontWeight(.semibold)
                        .padding(.top, 3)
                        .padding(.leading, 2)
                    
                    HStack(spacing: 16) {
                        
                        ForEach(complimentsViewModel.nades, id: \.self) { comp in
                            
                            Button {
                                
                                nade = comp
                                player.replaceCurrentItem(with: AVPlayerItem(url: URL(string: comp.video)!))
                                
                            } label: {
                                
                                ComplimentCell(nade: comp)
                                    .padding(.bottom)
                                
                            }
                            .buttonStyle(ComplimentsCellButtonStyle())
                            
                        }
                        
                    }
                    
                }
                .padding(.horizontal)
                
            }
            .onAppear(perform: loadCompliments)
            .onChange(of: nade) { _ in
                
                self.complimentsViewModel.nades.removeAll()
                self.complimentsViewModel.fetchData(ref: Firestore.firestore().collection("nades")
                                                            .whereField("id", in: nade.compliments))
                
            }
            
        }
        
    }
    
    func loadCompliments() {
        
        self.complimentsViewModel.nades.removeAll()
        self.complimentsViewModel.fetchData(ref: Firestore.firestore().collection("nades")
                                                    .whereField("id", in: nade.compliments))
        
    }
    
}

private struct Share: View {
    
    @State var nade: Nade
    @State var showingShareSheet = false
    
    @AppStorage("settings.tint") var tint: Int = 1
    
    var body: some View {
        
        Button(action: shareAction) {
            
            VStack(alignment: .leading) {
                
                Divider()
                
                Label("Share", systemImage: "square.and.arrow.up")
                    .foregroundColor(TintColour.colour(withID: tint))
                    .padding(.top, 5)
                    .padding(.leading, 1)
                
                Divider()
                
            }
            .background(Color(uiColor: .systemBackground))
            
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
        .sheet(isPresented: $showingShareSheet, content: {
            
            ShareSheet(items: [URL(string: "https://popflash.app/dust2_xbox_smoke")!])
                .ignoresSafeArea()
            
        })
        
    }
    
    func shareAction() {
        
        showingShareSheet = true
        
    }
    
}

private struct VideoPlayer: UIViewControllerRepresentable {
    
    var player: AVPlayer
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<VideoPlayer>) -> AVPlayerViewController {
        
        let controller = AVPlayerViewController()
        
        controller.player = player
        controller.showsPlaybackControls = false
        controller.videoGravity = .resizeAspectFill
        
        try! AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        
        return controller
        
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: UIViewControllerRepresentableContext<VideoPlayer>) { }
    
}
