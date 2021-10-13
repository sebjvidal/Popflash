//
//  WelcomeView.swift
//  Popflash
//
//  Created by Seb Vidal on 23/02/2021.
//

import SwiftUI
import CryptoKit
import AuthenticationServices

struct WelcomeView: View {
    
    @State var selection = 0
    
    @AppStorage("loggedInStatus") var loggedInStatus = false
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            TabView(selection: $selection) {
                
                FeaturesPage(selection: $selection)
                    .tag(0)
                
                LoginPage(popflash: false,
                          notNow: true,
                          presentationMode: presentationMode)
                    .tag(1)
                
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.15), value: selection)
            
            Text("Popflash")
                .font(.system(size: 50))
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .padding(.top, 94)
            
        }
        .onChange(of: loggedInStatus) { status in
            
            if status { dismiss() }
            
        }
        
    }
    
}

private struct FeaturesPage: View {
    
    @Binding var selection: Int
    
    var body: some View {
        
        VStack(alignment: .center) {
            
            Text("Welcome to")
                .font(.system(size: 25))
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .padding(.top, 64)
            
            Text("Popflash")
                .font(.system(size: 50))
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .hidden()
            
            Spacer()
            
            Features()
            
            Spacer()
            
            GetStarted(selection: $selection)
                .padding(.bottom, 58)
                .onTapGesture {
                    
                    standard.setValue(true, forKey: "hasLaunchedBefore")
                    
                }
            
        }
        
    }
    
}

private struct Features: View {
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            Spacer()
            
            Spacer()
            
            Featured()
            
            Spacer()
            
            Maps()
            
            Spacer()
            
            Favourites()
            
            Spacer()
            
            Spacer()
            
            Spacer()
            
        }
        .padding(.horizontal, 32)
        
    }
    
}

private struct Featured: View {
    
    var body: some View {
        
        HStack {
            
            Image(systemName: "star.fill")
                .foregroundColor(.yellow)
                .font(.system(size: 38))
            
            VStack(alignment: .leading) {
                
                Text("Featured")
                    .fontWeight(.bold)
                    .font(.system(size: 15))
                    .foregroundColor(.primary)
                
                Text("Discover new grenade line-ups to give you a competitive advantage in-game.")
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
                
            }
            
        }
        
    }
    
}

private struct Maps: View {
    
    var body: some View {
        
        HStack {
            
            Image(systemName: "map.fill")
                .foregroundColor(.green)
                .font(.system(size: 38))
            
            VStack(alignment: .leading) {
                
                Text("Maps")
                    .fontWeight(.bold)
                    .font(.system(size: 15))
                    .foregroundColor(.primary)
                
                Text("Search for grenade line-ups by map, from Active Duty and Reserves Groups.")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                
            }
            
        }
        
    }
    
}

private struct Favourites: View {
    
    var body: some View {
        
        HStack {
            
            Image(systemName: "heart.fill")
                .foregroundColor(Color("Heart"))
                .font(.system(size: 38))
            
            VStack(alignment: .leading) {
                
                Text("Favourite")
                    .fontWeight(.bold)
                    .font(.system(size: 15))
                    .foregroundColor(.primary)
                
                
                Text("Save your favourite maps and line-ups for quick access during your next match.")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                
            }
            
        }
        
    }
    
}

private struct GetStarted: View {
    
    @Binding var selection: Int
    
    @AppStorage("settings.tint") var tint: Int = 1
    
    var body: some View {
        
        Button {
            
            selection = 1
            
        } label: {
            
            Text("Get Started")
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
        }
        .frame(width: UIScreen.screenWidth - 90, height: 52)
        .background(TintColour.colour(withID: tint))
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        
    }
    
}

struct LoginPage: View {
    
    var popflash: Bool
    var notNow: Bool
    
    @Binding var presentationMode: PresentationMode
    
    var body: some View {
        
        VStack(alignment: .center) {
            
            Text("Sign in to")
                .font(.system(size: 25))
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .padding(.top, 64)
            
            Text("Popflash")
                .font(.system(size: 50))
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .opacity(popflash ? 1 : 0)
            
            Spacer()
            
            AccountFeatures()
            
            Spacer()
            
            AccountPrivacy()
            
            Spacer()
            Spacer()
            
            SignInWithApple()
                .padding(.bottom, notNow ? 19 : 58)
            
            if notNow {
                
                NotNow(presentationMode: $presentationMode)
                    .padding(.bottom, 7)
                
            }
            
        }
        
    }
    
}

private struct AccountFeatures: View {
    
    @AppStorage("settings.tint") var tint: Int = 1
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            Image(systemName: "person.fill")
                .foregroundStyle(TintColour.colour(withID: tint))
                .font(.system(size: 44))
                .padding()
            
            VStack(alignment: .leading) {
                
                Text("Create a Popflash account to:")
                
                HStack(alignment: .top) {
                    
                    Text("    •")
                    
                    Text("Add maps and grenades to favourites.")
                    
                }
                
                HStack(alignment: .top) {
                    
                    Text("    •")
                    
                    Text("See recently viewed grenades.")
                    
                }
                
                HStack(alignment: .top) {
                    
                    Text("    •")
                    
                    Text("Enable and manage push notifications.")
                    
                }
                
            }
            .foregroundStyle(.secondary)
            .font(.callout)
            
        }
        .padding(.horizontal, 32)
        
    }
    
}

private struct AccountPrivacy: View {
    
    @AppStorage("settings.tint") var tint: Int = 1
    
    var body: some View {
        
        VStack {
            
            Image(systemName: "hand.raised.fill")
                .foregroundStyle(TintColour.colour(withID: tint))
                .font(.system(size: 44))
                .padding()
            
            VStack(alignment: .leading, spacing: 0) {
                
                Text("Your data remains private:")
                
                HStack(alignment: .top) {
                    
                    Text("    •")
                    
                    Text("Sign In with Apple ensures you are authenticated securely.")
                    
                }
                
                HStack(alignment: .top) {
                    
                    Text("    •")
                    
                    Text("Your data is kept private and not distributed to third parties.")
                    
                }
                
                HStack(alignment: .top) {

                    Text("    •")

                    Text("Popflash does not track you across apps and websites.")

                }
                
            }
            .foregroundStyle(.secondary)
            .font(.callout)

        }
        .padding(.horizontal, 32)
        
    }
    
}

private struct SignInWithApple: View {
    
    @StateObject var loginData = LoginViewModel()
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        SignInWithAppleButton { (request) in
            
            loginData.nonce = randomNonceString()
            
            request.requestedScopes = [.fullName]
            request.nonce = sha256(loginData.nonce)
            
        } onCompletion: { (result) in
            
            handleCompletion(result: result)
            
        }
        .signInWithAppleButtonStyle(colorScheme == .light ? .black : .white)
        .frame(width: UIScreen.screenWidth - 90, height: 52)
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        
    }
    
    func handleCompletion(result: Result<ASAuthorization, Error>) {
        
        switch result {
            
        case .success(let user):
            
            guard let credential = user.credential as? ASAuthorizationAppleIDCredential else {
                
                print("Firebase error.")
                
                return
                
            }
            
            loginData.authenticate(credential: credential)
            
        case .failure(let error):
            
            print("Failed to sign in with Apple:\n\(error.localizedDescription).")
            
        }
        
    }
    
}

private struct NotNow: View {
    
    @Binding var presentationMode: PresentationMode
    
    @AppStorage("settings.tint") var tint: Int = 1
    
    var body: some View {
        
        Button(action: notNow) {
            
            Text("Not Now")
                .foregroundColor(TintColour.colour(withID: tint))
            
        }
        
    }
    
    func notNow() {
        
        $presentationMode.wrappedValue.dismiss()
        
    }

}
