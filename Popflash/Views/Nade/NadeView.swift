//
//  NadeView.swift
//  Popflash
//
//  Created by Seb Vidal on 11/02/2021.
//

import SwiftUI
import Kingfisher
import FirebaseFirestore
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
            
            SwiftUI.ScrollView {
                
                ScrollViewReader { value in
                    
                    Details(nade: nade)
                        .id(0)
                        .onChange(of: nade) { _ in
                            value.scrollTo(0, anchor: .top)
                        }
                    
                    Compliments(nade: $nade, player: $player)
                    
                    
                }
                
            }
            
        }
        .animation(.easeInOut(duration: 0.25), value: fullscreen)
        .background {
            
            Color.black
                .opacity(fullscreen ? 1 : 0)
                .edgesIgnoringSafeArea(.all)
                .animation(.easeInOut(duration: 0.25), value: fullscreen)

        }
        .onChange(of: nade) { _ in
            
            print("Test")
            
//            incrementViews()
            
        }
        
    }
    
    func onAppear() {
        
        incrementViews()
        
    }
    
    func incrementViews() {
            
        let db = Firestore.firestore()
        let viewsRef = db.collection("nades").document(nade.documentID)
        
        viewsRef.updateData([
            
            "views": FieldValue.increment(1.0)
            
        ])
        
        print("+1")
        
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
    
//    func handleRotation(orientation: UIDeviceOrientation) {
//
//        if orientation == .portrait {
//
//            fullscreen = false
//
//        } else {
//
//            if orientation == .landscapeLeft {
//
//                fullscreen = true
//
//            } else if orientation == .landscapeRight {
//
//                fullscreen = true
//
//            }
//
//        }
//
//    }
    
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
                
                ProgressBar(value: $progress, player: $player, isplaying: $isPlaying)
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
        
        player.seek(to: player.currentItem!.duration, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.positiveInfinity)
        progress = 1
        
    }
    
}

struct SegmentedControl: View {

    @Binding var selection: String
    
    var options = ["Video", "Line-up"]
    
    var body: some View {
        
        Picker("Content View", selection: $selection) {
            
            ForEach(options, id: \.self) {
                
                Text($0)
                
            }
            
        }
        .frame(maxWidth: UIScreen.screenWidth)
        .pickerStyle(SegmentedPickerStyle())
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
                
                Spacer()
                
                FavouriteButton(id: nade.id)
                    .padding()
                    .padding(.bottom, 8)
                
            }
            
            VideoInfo(nade: nade)
                .padding(.top, 4)
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
    
    var id: String
    
    @AppStorage("favourites.nades") var favouriteNades: Array = [String()]
    
    var body: some View {
            
        Button {
            
            if favouriteNades.contains(id) {
                
                if let index = favouriteNades.firstIndex(of: id) {
                    
                    favouriteNades.remove(at: index)
                }
                
            } else {
                
                favouriteNades.append(id)
                
            }
            
        } label: {
            
            if favouriteNades.contains(id) {
                
                Image(systemName: "heart.fill")
                    .font(.system(size: 21))
                    .foregroundColor(Color("Heart"))
                
            } else {
                
                Image(systemName: "heart")
                    .font(.system(size: 21))
                
            }
            
        }
        .frame(width: 40, height: 40)
        .background(.regularMaterial)
        .clipShape(Circle())
        
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
                
                VStack(alignment: .leading) {
                    
                    Divider()
                        .frame(minWidth: UIScreen.screenWidth - 32)
                        .padding(.horizontal)
                        .padding(.bottom, 4)
                        .onAppear() {
                            
                            self.complimentsViewModel.fetchData(ref: Firestore.firestore().collection("nades")
                                                                        .whereField("id", in: nade.compliments))

                            
                        }
                        .onChange(of: nade) { _ in
                            
                            self.complimentsViewModel.nades.removeAll()
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
                                player.replaceCurrentItem(with: AVPlayerItem(url: URL(string: comp.video)!))
                                
                            } label: {
                                
                                ComplimentCell(nade: comp)
                                    .padding(.bottom, 18)
                                
                            }
                            .buttonStyle(ComplimentsCellButtonStyle())
                            
                        }
                        
                        Spacer()
                            .frame(width: 8)
                        
                    }
                    
                }
                
            }
            
        }
        
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
