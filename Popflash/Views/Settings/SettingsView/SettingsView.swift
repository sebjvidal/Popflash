//
//  SettingsView.swift
//  Popflash
//
//  Created by Seb Vidal on 13/02/2021.
//

import SwiftUI
import FirebaseAuth
import Kingfisher

struct SettingsView: View {
    
    @AppStorage("loggedInStatus") var loggedInStatus = false
    @AppStorage("tabSelection") var tabSelection: Int = 0
    
    var body: some View {
        
        List {
            
            Group {
                
                Header()
                
                Profile()
                
                RecentlyViewed()

                Settings()
                
                if loggedInStatus {
                    
                    SignOut()
                    
                }
                
            }
            .listRowInsets(.some(EdgeInsets()))
            .listRowSeparator(.hidden)
            
        }
        .listStyle(.plain)
        .onAppear {

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
                .padding(.bottom, 8)

        }
        
    }
    
}

private struct Profile: View {
    
    @StateObject var userViewModel = UserViewModel()
    
    @State var showingSignIn = false
    @State var showingProfileEditor = false
    
    @AppStorage("loggedInStatus") var signedIn = false
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        
        Button(action: profileAction) {
            
            HStack(spacing: 8) {
                
                ZStack {
                    
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 65))
                        .foregroundColor(.gray)
                    
                    if userViewModel.avatar != "" && signedIn {
                        
                        KFImage(URL(string: userViewModel.avatar))
                            .resizable()
                            .frame(width: 65, height: 65)
                            .clipShape(Circle())
                        
                    }
                    
                }
                .padding([.top, .leading, .bottom], 10)
                
                VStack(alignment: .leading) {

                    Text(signedIn ? userViewModel.displayName : "Sign in to Popflash")
                        .foregroundStyle(signedIn ? AnyShapeStyle(.primary) : AnyShapeStyle(.blue))
                        .font(.headline)
                    
                    Text(signedIn ? userViewModel.skillGroup : "Add grenades to favourites, see recently viewed.")
                        .foregroundStyle(.secondary)
                        .font(.callout)
                    
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
                    .padding(.trailing)
                
            }
            .background(Color("Background"))
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            
        }
        .cellShadow()
        .buttonStyle(.plain)
        .padding(.vertical, 8)
        .padding(.horizontal)
        .onAppear(perform: onAppear)
        .sheet(isPresented: $showingSignIn) {
            
            LoginSheet()
            
        }
        .sheet(isPresented: $showingProfileEditor) {
            
            EditProfile(displayName: userViewModel.displayName,
                        rankSelection: userViewModel.skillGroup,
                        profilePicture: userViewModel.avatar)
            
        }
        
    }
    
    func onAppear() {
        
        initStateDidChangeListener()
        
    }
    
    func profileAction() {
        
        if signedIn {
            
            showingProfileEditor = true
            
        } else {
            
            showingSignIn = true
            
        }
        
    }
    
    func initStateDidChangeListener() {
        
        Auth.auth().addStateDidChangeListener { auth, user in
            
            guard let user = user else {
                
                return
                
            }
            
            if !user.isAnonymous {
                
                signedIn = true
                userViewModel.fetchData(forUser: user.uid)
                
            } else {
                
                signedIn = false
                userViewModel.clearData()
                
            }
            
        }
        
    }
    
}

private struct LoginSheet: View {
    
    @AppStorage("loggedInStatus") var loggedInStatus = false
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        NavigationView {
            
            LoginPage(popflash: true,
                      notNow: false,
                      presentationMode: presentationMode)
                .navigationBarTitle("", displayMode: .inline)
                .navigationBarItems(
                    leading:
                        Button(action: {

                            presentationMode.wrappedValue.dismiss()
                            
                        }) {
                            
                            Text("Cancel")
                                .foregroundStyle(.blue)
                            
                        }
                        
                )
                .edgesIgnoringSafeArea(.top)
                .interactiveDismissDisabled()
            
        }
        .onChange(of: loggedInStatus) { loggedIn in
            
            if loggedIn {
                
                presentationMode.wrappedValue.dismiss()
                
            }
            
        }
        
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
        .padding(.top, 8)
        .padding(.horizontal)
        .padding(.bottom, 8)
        .cellShadow()
        
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
        .padding(.top, 8)
        .padding(.horizontal)
        .padding(.bottom, 8)
        .cellShadow()
        
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

private struct SignOut: View {
    
    @State private var showingActionSheet = false
    
    @AppStorage("loggedInStatus") var loggedInStatus = false
    
    var body: some View {
        
        Button(action: signOutAction) {
            
            HStack {
                
                Spacer()
                
                Text("Sign Out")
                    .foregroundColor(.red)
                
                Spacer()
                
            }
            .padding(.vertical, 14)
            
        }
        .background(Color("Background"))
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        .padding(.vertical, 8)
        .padding(.horizontal)
        .buttonStyle(.borderless)
        .cellShadow()
        .actionSheet(isPresented: $showingActionSheet) {
            
            ActionSheet(title: Text("Sign Out"), message: Text("Are you sure you want to sign out of Popflash?"), buttons: [
                .destructive(Text("Sign Out")) { signOut() },
                .cancel()
            ])
            
        }
        
    }
    
    func signOutAction() {
        
        showingActionSheet = true
        
    }
    
    func signOut() {
        
        DispatchQueue.global(qos: .background).async {
            
            try? Auth.auth().signOut()
            
        }
        
        loggedInStatus = false
        
        authenticateAnonymously()
        
    }
        
}
