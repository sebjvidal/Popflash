//
//  SettingsView.swift
//  Popflash
//
//  Created by Seb Vidal on 13/02/2021.
//

import SwiftUI

struct SettingsView: View {
    
    @AppStorage("tabSelection") var tabSelection: Int = 0
    
    var body: some View {
        
        List {
            
            Group {
                
                Header()
                
                Profile()
                
                RecentlyViewed()

                Settings()
                
            }
            .listRowInsets(.some(EdgeInsets()))
            .listRowSeparator(.hidden)
            
        }
        .listStyle(.plain)
        .onAppear {
            
            UITableView.appearance().separatorStyle = .none
            
            tabSelection = 3
            
        }
        
    }
    
}

private struct Header: View {
    
    var body: some View {
        
        LazyVStack(alignment: .leading, spacing: 0) {

            Spacer()
                .frame(height: 52)

            HStack() {

                Text("Profile")
                    .font(.system(size: 32))
                    .fontWeight(.bold)
                    .padding(.leading, 16)

            }

            Divider()
                .padding(.top, 6)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)

        }
        
    }
    
}

private struct Profile: View {
    
    var body: some View {
        
        Button {
            
            print("Test")
            
        } label: {
            
            HStack(spacing: 16) {
                
                Color.gray
                    .frame(width: 65, height: 65)
                    .clipShape(Circle())
                
                VStack(alignment: .leading) {
                    
                    Text("Forename Surname")
                        .foregroundStyle(.primary)
                        .font(.headline)
                    
                    Text("Skill Group")
                        .foregroundStyle(.secondary)
                    
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
                
            }
            .padding()
            .background(Color("Background"))
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            
        }
        .buttonStyle(.plain)
        .shadow(radius: 6, y: 5)
        .padding([.horizontal, .bottom])
        
    }
    
}

private struct AltProfile: View {
    
    var body: some View {
        
        Button {
            
            print("Test")
            
        } label: {
            
            LazyVStack(spacing: 16) {
                
                Color.gray
                    .frame(width: 65, height: 65)
                    .clipShape(Circle())
                
                Image("Skill_Group_0")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 95)
                    
                Text("Forename Surname")
                    .foregroundStyle(.primary)
                    .font(.headline)
                
//                Text("Skill Group")
//                    .foregroundStyle(.secondary)

                
            }
            .padding()
            .background(Color("Background"))
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            
//            HStack(spacing: 16) {
//
//                Color.gray
//                    .frame(width: 65, height: 65)
//                    .clipShape(Circle())
//
//
//
//                Spacer()
//
//                Image(systemName: "chevron.right")
//                    .foregroundStyle(.secondary)
//
//            }

            
        }
        .buttonStyle(.plain)
        .shadow(radius: 6, y: 5)
        .padding([.horizontal, .bottom])
        
    }
    
}

private struct Settings: View {
    
    var body: some View {
            
        VStack {
            
            AutoPlayVideoRow()
            
            Divider()
                .padding(.leading, 54)
            
            PlayAudioSilencedRow()
            
            Divider()
                .padding(.leading, 54)
            
            NotificationsRow()
            
            Divider()
                .padding(.leading, 54)
            
            CompactMapsViewRow()
            
        }
        .padding(.vertical, 12)
        .background(Color("Background"))
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        .padding(.horizontal, 16)
        .shadow(radius: 6, y: 5)
        
    }
    
}

private struct SettingIcon: View {
    
    var color: Color
    var icon: Image
    var size: Font? = .body
    var edges: Edge.Set? = .all
    var length: CGFloat? = 0
    
    var body: some View {
        
        ZStack {
            
            RoundedRectangle(cornerRadius: 6.5, style: .continuous)
                .frame(width: 29, height: 29)
                .foregroundColor(color)
            
            icon
                .font(size)
                .foregroundColor(.white)
                .padding(edges!, length)
            
        }
        .padding(.leading)
        
    }
    
}

private struct RecentlyViewed: View {
    
    var body: some View {
        
        HStack {
            
            SettingIcon(color: .orange, icon: Image(systemName: "gobackward"), edges: .bottom, length: 2.5)
            
            Text("Recently Viewed")
                .frame(height: 43)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
                .padding(.trailing)
            
        }
        .padding(.vertical, 6)
        .background(Color("Background"))
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        .padding([.horizontal, .bottom], 16)
        .shadow(radius: 6, y: 5)
        
    }
    
}

private struct AutoPlayVideoRow: View {
    
    @AppStorage("settings.autoPlayVideo") var autoPlayVideo = false
    
    var body: some View {
        
        HStack {
            
            SettingIcon(color: Color("Light_Blue"), icon: Image(systemName: "play.fill"))

            Toggle("Auto-Play Videos", isOn: $autoPlayVideo)
                .padding(.trailing)
            
        }
        
        if autoPlayVideo {
            
            Divider()
                .padding(.leading, 54)
            
            AutoPlayAudioRow()
            
        }
        
    }
    
}

private struct AutoPlayAudioRow: View {
    
    @AppStorage("settings.autoPlayAudio") var autoPlayAudio = true
    
    var body: some View {
        
        HStack {
            
            SettingIcon(color: Color("Fuscia_Pink"), icon: Image(systemName: "speaker.wave.3.fill"), size: .subheadline)

            Toggle("Auto-Play Audio", isOn: $autoPlayAudio)
                .padding(.trailing)
            
        }
        
    }
    
}

private struct PlayAudioSilencedRow: View {
    
    @AppStorage("settings.playAudioSilenced") var playAudioSilenced = true
    
    var body: some View {
        
        HStack {
            
            SettingIcon(color: Color("Fuscia_Pink"), icon: Image(systemName: "bell.and.waveform.fill"))

            Toggle("Silenced Audio Playback", isOn: $playAudioSilenced)
                .padding(.trailing)
            
        }
        
    }
    
}

private struct NotificationsRow: View {
    
    var body: some View {
        
        HStack {
            
            SettingIcon(color: .red, icon: Image(systemName: "app.badge"), edges: [.leading, .bottom], length: 1)
            
            Text("Notifications")
                .frame(height: 43)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
                .padding(.trailing)
            
        }
        
    }
    
}

private struct CompactMapsViewRow: View {
    
    @AppStorage("settings.compactMapsView") var compactMapView = false
    
    var body: some View {
        
        HStack {

            SettingIcon(color: .green, icon: Image(systemName: "rectangle.arrowtriangle.2.inward"))

            Toggle("Compact Maps View", isOn: $compactMapView)
                .padding(.trailing)

        }
        
    }
    
}

//private struct Reset: View {
//
//    var body: some View {
//
//
//
//    }
//
//}
