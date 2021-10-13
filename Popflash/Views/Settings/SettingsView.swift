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
    
    @State private var statusOpacity: Double = 0
    
    @AppStorage("loggedInStatus") var loggedInStatus = false
    @AppStorage("tabSelection") var tabSelection: Int = 0
    
    var body: some View {
        
        GeometryReader { outerGeo in
            
            NavigationView {
                
                List {
                    
                    Group {
                        
                        StatusBarHelper(outerGeo: outerGeo,
                                        statusOpacity: $statusOpacity)
                        
                        Header()
                        
                        Profile()
                        
                        RecentlyViewed()
                        
                        AppearanceSettings()
                        
                        NotificationsRow()
                        
                        Settings()
                        
                        if loggedInStatus {
                            
                            SignOut()
                            
                        }
                        
                    }
                    .listRowInsets(.some(EdgeInsets()))
                    .listRowSeparator(.hidden)
                    
                }
                .listStyle(.plain)
                .environment(\.defaultMinListRowHeight, 1)
                .onAppear(perform: onAppear)
                .navigationBarTitle("Profile", displayMode: .inline)
                .navigationBarHidden(true)
                .overlay(alignment: .top) {
                    
                    StatusBarBlur(outerGeo: outerGeo, statusOpacity: $statusOpacity)
                    
                }
                
            }
            .navigationViewStyle(.stack)
            
        }
        
    }
    
    func onAppear() {
        
        tabSelection = 3
    }
    
}

private struct Header: View {
    
    var body: some View {
        
        LazyVStack(alignment: .leading, spacing: 0) {

            Spacer()
                .frame(height: 51)

            HStack {

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
    @AppStorage("settings.tint") var tint: Int = 1
    
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

                    Text(signedIn ? String(userViewModel.displayName ?? "Display Name") : "Sign in to Popflash")
                        .foregroundStyle(signedIn ? AnyShapeStyle(.primary) : AnyShapeStyle(TintColour.colour(withID: tint)))
                        .font(.headline)
                    
                    Text(signedIn ? String(userViewModel.skillGroup ?? "Skill Group Unknown") : "Add grenades to favourites, see recently viewed.")
                        .foregroundStyle(.secondary)
                        .font(.callout)
                    
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
                    .padding(.trailing)
                
            }
            .background(Color("Background"))
            
        }
        .buttonStyle(RoundedTableCell())
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        .cellShadow()
        .padding(.vertical, 8)
        .padding(.horizontal)
        .onAppear(perform: onAppear)
        .sheet(isPresented: $showingSignIn) {
            
            LoginSheet()
            
        }
        .sheet(isPresented: $showingProfileEditor) {
            
            EditProfileView(displayName: userViewModel.displayName ?? "",
                            rankSelection: userViewModel.skillGroup ?? "",
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

struct LoginSheet: View {
    
    @AppStorage("loggedInStatus") var loggedInStatus = false
    @AppStorage("settings.tint") var tint: Int = 1
    
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
                                .foregroundStyle(TintColour.colour(withID: tint))
                            
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
            
        VStack(spacing: 8) {
            
            AutoPlayVideoRow()
            
            Divider()
                .padding(.leading, 54)
            
            PlayAudioSilencedRow()
            
            Divider()
                .padding(.leading, 54)
            
            CompactMapsViewRow()
            
        }
        .padding(.vertical, 14)
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
    
    @State private var action: Int? = 0
    @State private var showingLoginAlert = false
    @State private var showingLoginSheet = false
    
    var body: some View {
        
        ZStack {
            
            NavigationLink(destination: RecentlyViewedView(), tag: 1, selection: $action) {
                
                EmptyView()
                
            }
            .hidden()
            .disabled(true)
            
            Button(action: showRecent) {
                
                HStack(spacing: 12) {
                    
                    SettingIcon(color: .orange, icon: Image(systemName: "gobackward"), edges: .bottom, length: 2.5)
                    
                    Text("Recently Viewed")
                        .padding(.vertical, 18)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                        .padding(.trailing)
                    
                }
                .background(Color("Background"))
                
            }
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            .buttonStyle(RoundedTableCell())
            .cellShadow()
            .padding(.top, 8)
            .padding(.horizontal)
            .padding(.bottom, 8)
            
        }
        .sheet(isPresented: $showingLoginSheet) {
            
            LoginSheet()
            
        }
        .alert(isPresented: $showingLoginAlert) {
            
            Alert(title: Text("Sign In"),
                  message: Text("Sign in to Popflash to see recently viewed grenade line-ups."),
                  primaryButton: .default(Text("Sign In"), action: showLogin),
                  secondaryButton: .cancel())
            
        }
        
    }
    
    func showRecent() {
        
        guard let user = Auth.auth().currentUser else {
            
            return
            
        }
        
        if user.isAnonymous {
            
            showingLoginAlert = true
            
        } else {
        
            action = 1
            
        }
        
    }
    
    func showLogin() {
        
        showingLoginSheet = true
        
    }
    
}

private struct AppearanceSettings: View {
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            AppIconRow()
            
            Divider()
                .padding(.leading, 54)
            
            TintColourRow()
            
            Divider()
                .padding(.leading, 54)
            
            AppearanceRow()
            
        }
        .background(Color("Background"))
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        .padding(.top, 8)
        .padding(.horizontal)
        .padding(.bottom, 8)
        .cellShadow()
        
    }
    
}

private struct AppIconRow: View {
    
    var body: some View {
        
        HStack(spacing: 12) {
            
            SettingIcon(color: .purple, icon: Image(systemName: "square.grid.3x3.fill"))

            Text("App Icon")
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
                .padding(.trailing)
            
        }
        .padding(.top, 14)
        .padding(.bottom, 9)
        
    }
    
}

private struct AppearanceRow: View {
    
    @State private var action: Int? = 0
    
    var body: some View {
        
        Button(action: showAppearance) {
            
            ZStack {
                
                NavigationLink(destination: AppearanceView(), tag: 1, selection: $action) {
                    
                    EmptyView()
                    
                }
                .hidden()
                .disabled(true)
                
                HStack(spacing: 12) {
                    
                    ZStack {
                        
                        RoundedRectangle(cornerRadius: 6.5, style: .continuous)
                            .frame(width: 29, height: 29)
                            .foregroundColor(Color("Headline"))
                        
                        Image("Dark_Mode")
                            .resizable()
                            .frame(width: 22, height: 22)
                        
                    }
                    .padding(.leading)

                    Text("Appearance")
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                        .padding(.trailing)
                    
                }
                
            }
            .padding(.top, 9)
            .padding(.bottom, 14)
            .background(Color("Background"))
            
        }
        .buttonStyle(RoundedTableCell())
        
    }
    
    func showAppearance() {
        
        action = 1
        
    }
    
}

private struct TintColourRow: View {
    
    @State private var action: Int? = 0
    
    var body: some View {
        
        Button(action: showTint) {
            
            ZStack {
                
                NavigationLink(destination: TintView(), tag: 1, selection: $action) {
                    
                    EmptyView()
                    
                }
                .hidden()
                .disabled(true)
                
                HStack(spacing: 12) {
                    
                    SettingIcon(color: .blue, icon: Image(systemName: "eyedropper.halffull"))

                    Text("App Tint")
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                        .padding(.trailing)
                    
                }
                .padding(.vertical, 9)
                
            }
            .background(Color("Background"))
            
        }
        .buttonStyle(RoundedTableCell())
        
    }
    
    func showTint() {
        
        action = 1
        
    }
    
}

private struct NotificationsRow: View {
    
    @State private var action: Int? = 0
    @State private var showingLoginAlert = false
    @State private var showingLoginSheet = false
    
    var body: some View {
        
        ZStack {
            
            NavigationLink(destination: NotificationsView(), tag: 1, selection: $action) {
                
                EmptyView()
                
            }
            .hidden()
            .disabled(true)
            
            Button(action: showNotifications) {
                
                HStack(spacing: 12) {
                    
                    SettingIcon(color: .red, icon: Image(systemName: "app.badge"), edges: [.leading, .bottom], length: 1)
                    
                    Text("Notifications")
                        .padding(.vertical, 18)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                        .padding(.trailing)
                    
                }
                .background(Color("Background"))
                
            }
            .buttonStyle(RoundedTableCell())
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            .cellShadow()
            .padding(.top, 8)
            .padding(.horizontal)
            .padding(.bottom, 8)
            
        }
        .sheet(isPresented: $showingLoginSheet) {
            
            LoginSheet()
            
        }
        .alert(isPresented: $showingLoginAlert) {
            
            Alert(title: Text("Sign In"),
                  message: Text("Sign in to Popflash to receive and manage notifications."),
                  primaryButton: .default(Text("Sign In"), action: showLogin),
                  secondaryButton: .cancel())
            
        }
        
    }
    
    func showNotifications() {
        
        guard let user = Auth.auth().currentUser else {
            
            return
            
        }
        
        if user.isAnonymous {
            
            showingLoginAlert = true
            
        } else {
            
            action = 1
            
        }
        
    }
    
    func showLogin() {
        
        showingLoginSheet = true
        
    }
    
}

private struct AutoPlayVideoRow: View {
    
    @AppStorage("settings.autoPlayVideo") var autoPlayVideo = false
    
    var body: some View {
        
        HStack(spacing: 12) {
            
            SettingIcon(color: .cyan, icon: Image(systemName: "play.fill"))

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
        
        HStack(spacing: 12) {
            
            SettingIcon(color: .pink, icon: Image(systemName: "speaker.wave.3.fill"), size: .subheadline)

            Toggle("Auto-Play Audio", isOn: $autoPlayAudio)
                .padding(.trailing)
            
        }
        
    }
    
}

private struct PlayAudioSilencedRow: View {
    
    @AppStorage("settings.playAudioSilenced") var playAudioSilenced = true
    
    var body: some View {
        
        HStack(spacing: 12) {
            
            SettingIcon(color: .pink, icon: Image(systemName: "bell.and.waveform.fill"))

            Toggle("Silenced Audio Playback", isOn: $playAudioSilenced)
                .padding(.trailing)
            
        }
        
    }
    
}

private struct CompactMapsViewRow: View {
    
    @AppStorage("settings.compactMapsView") var compactMapView = false
    
    var body: some View {
        
        HStack(spacing: 12) {

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

            Text("Sign Out")
                .foregroundColor(.red)
                .padding(.vertical, 14)
                .frame(width: UIScreen.screenWidth - 32)
                .background(Color("Background"))
            
        }
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        .buttonStyle(RoundedTableCell())
        .padding(.top, 8)
        .padding([.horizontal, .bottom])
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
