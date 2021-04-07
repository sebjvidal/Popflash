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
    
    @State var rotation = 0.0
    
    @State var player = AVPlayer()
    @State var isPlaying = false
    @State var progress: Float = 0
    
    @State var showControls = false
    @State var fullscreen = false
    
    @State var isShowingVideo = true
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            VStack {
                
                ZStack(alignment: .top) {
                    
                    VideoPlayer(player: player)
                        .frame(width: UIScreen.screenWidth,
                               alignment: .top)
                    
                    VisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
                    
                }
                .frame(height: 47)
                
                Rectangle()
                    .frame(height: UIScreen.screenWidth / 1.6)
                    .foregroundColor(.clear)
                    .padding(.top, -8)
                
                ScrollView(axes: .vertical, showsIndicators: true) {
                    
                    Details(nade: nade)
                        .frame(width: UIScreen.screenWidth)
                    
                    if !nade.compliments.isEmpty {
                        
                        Compliments(nade: $nade, player: $player)
                        
                    }
                    
                }
                .padding(.top, -8)
                
            }
            .edgesIgnoringSafeArea(.top)
            
            if isShowingVideo {
                
                VideoView(nade: nade, player: player, fullscreen: $fullscreen)
                    .edgesIgnoringSafeArea(.all)
                
            }
            
            HStack {
                
                ToggleButton(videoSelected: $isShowingVideo)
                    .padding([.leading, .top])
                
                Spacer()
                
                CloseButton(player: player)
                    .padding([.trailing, .top])
                
            }
            
        }
        
    }
    
}

private struct ToggleButton: View {
    
    @Binding var videoSelected: Bool
    
    var body: some View {
        
        ZStack(alignment: .leading) {
            
            VisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
                .frame(width: 75.5, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: 35, style: .continuous))
            
            Circle()
                .frame(width: 35, height: 35)
                .padding(.leading, 2.5)
                .foregroundColor(Color("Blur_Overlay"))
                .opacity(0.5)
                .offset(x: videoSelected ? 0 : 35)
                .animation(.easeInOut(duration: 0.25))
            
            HStack {

                Button {
                    
                    videoSelected = true
                    
                } label: {
                    
                    Image(systemName: "play.rectangle.fill")
                        .frame(width: 35, height: 35)
                    
                }
                .padding(.leading, 2.5)
                
                Button {
                    
                    videoSelected = false
                    
                } label: {
                    
                    Image(systemName: "photo")
                        .frame(width: 35, height: 35)
                    
                }
                .padding(.leading, -7.5)
                  
            }
            
        }
        .buttonStyle(PlainButtonStyle())
        
    }
    
}

private struct CloseButton: View {
    
    @State var player: AVPlayer
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        
        Button {
            
            player.pause()
            presentationMode.wrappedValue.dismiss()
            
        } label: {
            
            ZStack {
                
                VisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
                    .frame(width: 35, height: 35)
                
                Image(systemName: "multiply")
                    .font(.system(size: 20, weight: .semibold))
                
            }
            .cornerRadius(25)
            
        }
        .buttonStyle(PlainButtonStyle())
        
    }
    
}

private struct VideoView: View {
    
    @State var nade: Nade
    @State var player: AVPlayer
    
    @State var rotation = 0.0
    @State var isPlaying = false
    @State var progress: Float = 0
    @State var showControls = false
    @Binding var fullscreen: Bool
    
    var body: some View {
        
        ZStack(alignment: fullscreen ? .center : .top) {
            
            Rectangle()
                .foregroundColor(.black)
                .edgesIgnoringSafeArea(.all)
                .opacity(fullscreen ? 1 : 0)
                .animation(.easeInOut(duration: 0.25))
            
            ZStack(alignment: .center) {
                
                VideoPlayer(player: player)
                    .onTapGesture {
                        
                        showControls.toggle()
                        
                    }
                    .onAppear() {
                        
                        player.replaceCurrentItem(with: AVPlayerItem(url: URL(string: nade.video)!))
                        
                        self.player.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 100), queue: .main) { (_) in
                            
                            self.progress = self.getSliderValue()
                            
                            if self.progress == 1.0 {
                                
                                self.isPlaying = false
                                
                            }
                        }
                        
                    }
                
                Rectangle()
                    .foregroundColor(.black)
                    .opacity(showControls ? 0.4 : 0)
                
                VideoControls(player: $player, isPlaying: self.$isPlaying, progress: self.$progress, fullscreen: self.$fullscreen)
                    .opacity(showControls ? 1 : 0)
                
            }
            .frame(width: fullscreen ? UIScreen.screenWidth * 1.777 : UIScreen.screenWidth,
                   height: fullscreen ? UIScreen.screenWidth : (UIScreen.screenWidth) / 1.6)
            .rotationEffect(.degrees(rotation))
            .offset(y: fullscreen ? 0 : 47)
            .animation(.easeInOut(duration: 0.25))
            .onRotate { orientation in
                
                if orientation == .portrait {
                    
                    fullscreen = false
                    rotation = 0.0
                    
                } else if orientation == .landscapeLeft {
                    
                    fullscreen = true
                    rotation = 90.0
                    
                } else if orientation == .landscapeRight {
                    
                    fullscreen = true
                    rotation = -90.0
                    
                }
                
            }
            
        }
        
    }
    
    func getSliderValue() -> Float{
        
        return Float(self.player.currentTime().seconds / (self.player.currentItem?.duration.seconds)!)
    }
    
    func getSeconds() -> Double{
        
        return Double(Double(self.progress) * (self.player.currentItem?.duration.seconds)!)
    }
    
}

private struct Details: View {
    
    var nade: Nade
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            HStack {
                
                VStack(alignment: .leading) {
                    
                    Text(nade.map)
                        .foregroundColor(.gray)
                        .fontWeight(.semibold)
                        .padding(.top, 3)
                        .padding(.horizontal)
                    
                    Text(nade.name)
                        .font(.system(size: 22))
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    Text(nade.shortDescription)
                        .padding(.top, 4)
                        .padding(.horizontal)
                    
                }
                
                Spacer()
                
                FavouriteButton(id: nade.id)
                    .padding()
                
            }
            
            VideoInfo(nade: nade)
                .padding(.top, -8)
            
            Text(nade.longDescription.replacingOccurrences(of: "\\n", with: "\n"))
                .padding(.horizontal)
            
        }
        
    }
    
}

private struct FavouriteButton: View {
    
    var id: String
    
    @AppStorage("favourites.nades") var favouriteNades: Array = [String()]
    
    var body: some View {
        
        ZStack {
            
            VisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            
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
            .offset(y: 0.5)
            
        }
        
    }
    
}

public struct VideoInfo: View {
    
    var nade: Nade
    
    public var body: some View {
        
        ScrollView(axes: .horizontal, showsIndicators: false) {
            
            VStack {
                
                Divider()
                    .background(Color.clear)
                    .padding(.horizontal)
                
                HStack {
                    
                    Spacer()
                        .frame(width: 24)
                    
                    VideoInfoDetails(nade: nade)
                    
                    Spacer()
                        .frame(width: 23.9)
                    
                }

                Divider()
                    .padding(.horizontal)
                
            }
            
        }
        
    }
    
}

private struct VideoInfoDetails: View {
    
    var nade: Nade
    
    var body: some View {
        
        HStack {
            
            VideoBox(title: "VIEWS",
                     symbol: "eye.fill",
                     value: String(nade.views))
            
            BoxDivider()
            
            VideoBox(title: "FAVOURITES",
                     symbol: "heart.fill",
                     value: String(nade.favourites))
            
            BoxDivider()
            
            VideoBox(title: "TICK RATE",
                     symbol: "clock.fill",
                     value: nade.tick)
            
            BoxDivider()
            
            VideoBox(title: "JUMP BIND",
                     symbol: "keyboard",
                     value: nade.bind)
            
            BoxDivider()
            
            VideoBox(title: "SIDE",
                     symbol: "terrorist.fill",
                     value: nade.side)
            
            
        }
        
    }
    
}

private struct BoxDivider: View {
    
    var body: some View {
        
        Divider()
            .padding(.vertical)
            .frame(height: 70)
        
    }
    
}

private struct VideoBox: View {
    
    var title: String
    var symbol: String
    var value: String
    
    let cellPadding = 32.0
    let boxWidth = UIScreen.screenWidth / 4 - 32
    
    var body: some View {
        
        ZStack {
            
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 80, height: 60)
                .padding(0)
            
            if symbol == "keyboard" {
                
                Image("keyboard.fill")
                    .padding(.bottom, 2)
                    .foregroundColor(.gray)
                
            } else if symbol == "terrorist.fill" {
                
                Image("terrorist.fill")
                    .padding(.bottom, 2)
                    .font(.system(size: 22))
                    .foregroundColor(.gray)
                
            } else {
                
                Image(systemName: symbol)
                    .padding(.bottom, 2)
                    .foregroundColor(.gray)
                
            }
            
            VStack {
                
                Text(title)
                    .font(.system(size: 11))
                    .fontWeight(.semibold)
                    .padding(.bottom, 2)
                    .frame(width: boxWidth + 8, height: 8)
                    .foregroundColor(.gray)
                
                Spacer()
                    .frame(height: 36)
                
                Text(value)
                    .font(.system(size: 12))
                    .fontWeight(.semibold)
                    .padding(.top, 2)
                    .frame(width: boxWidth, height: 8)
                    .foregroundColor(.gray)
            }
            
        }
        
    }
    
}

private struct Compliments: View {
    
    @StateObject private var complimentsViewModel = NadesViewModel()
    
    @Binding var nade: Nade
    @Binding var player: AVPlayer
    
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
                            player.replaceCurrentItem(with: AVPlayerItem(url: URL(string: comp.video)!))
                            
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

private struct VideoPlayer: UIViewControllerRepresentable {
    
    var player: AVPlayer
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<VideoPlayer>) -> AVPlayerViewController {
        
        let controller = AVPlayerViewController()
        
        controller.player = player
        controller.showsPlaybackControls = false
        controller.videoGravity = .resizeAspectFill
        
        return controller
        
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: UIViewControllerRepresentableContext<VideoPlayer>) {
        
        // Do nothing
        
    }
    
}

private struct VideoControls: View {
    
    @Binding var player: AVPlayer
    @Binding var isPlaying: Bool
    @Binding var progress: Float
    @Binding var fullscreen: Bool
    
    var body: some View {
        
        ZStack {
            
            VStack {
                
                HStack {
                    
                    Spacer()
                    
                    Button {
                        
                        player.seek(to: CMTime(seconds: 0, preferredTimescale: 1))
                        
                    } label: {
                        
                        Image(systemName: "backward.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 26))
                        
                    }
                    
                    Spacer()
                    
                    Button {
                        
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
                        
                    } label: {
                        
                        if progress == 1 {
                            
                            Image(systemName: "gobackward")
                                .foregroundColor(.white)
                                .font(.system(size: 36, weight: .bold))
                            
                        } else {
                            
                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 42))
                            
                        }
                        
                    }
                    .frame(width: 45)
                    
                    Spacer()
                    
                    Button {
                        
                        player.seek(to: player.currentItem!.duration)
                        
                    } label: {
                        
                        Image(systemName: "forward.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 26))
                        
                    }
                    
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
        
    }
    
}

struct NadeView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        let test_nade = Nade(id: "nuke_outside_smoke",
                             name: "Outside Smoke",
                             map: "Nuke",
                             type: "Smoke",
                             side: "Terrorist",
                             thumbnail: "https://firebasestorage.googleapis.com/v0/b/popflash-3e8b8.appspot.com/o/Thumbnails%2Fnuke_outside_smoke.jpg?alt=media&token=31f12683-fadc-4169-813f-de5f34da7f1d",
                             video: "https://firebasestorage.googleapis.com/v0/b/popflash-3e8b8.appspot.com/o/Videos%2FDust%20II%2Fdust2_xbox_smoke.mp4?alt=media&token=8c07faf8-969d-40b2-92d1-683536e630aa",
                             shortDescription: "Block vision of T Red to Secret.",
                             longDescription: "Use this smoke during a B push to block a CT's vision of the bomb site from CT Spawn. Use this smoke in conjunction with a Coffins smoke and a New Box molotov to eliminate common CT positions and increase your chances of a successful B take.\n\nCTs can also deploy this smoke in a retake scenario when approaching the Bomb Site from Banana.",
                             views: 420,
                             favourites: 69,
                             bind: "No",
                             tick: "64 & 128",
                             tags: [],
                             compliments: [])
        
        NadeView(nade: test_nade)
        
    }
    
}
