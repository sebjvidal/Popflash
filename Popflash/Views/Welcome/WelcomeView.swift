//
//  WelcomeView.swift
//  Popflash
//
//  Created by Seb Vidal on 23/02/2021.
//

import SwiftUI

struct WelcomeView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
            
            PlayerView()
                .edgesIgnoringSafeArea(.all)
            
//            Rectangle()
//                .foregroundColor(.black)
//                .edgesIgnoringSafeArea(.all)
//                .opacity(0.2)
            
            VStack(alignment: .center) {
                
                Text("Welcome to")
                    .foregroundColor(Color("Description"))
                    .font(.system(size: 25))
                    .fontWeight(.semibold)
                    .shadow(radius: 3)
                    .padding(.top, 64)
                
                Text("Popflash")
                    .foregroundColor(.white)
                    .font(.system(size: 50))
                    .fontWeight(.bold)
                    .shadow(radius: 5)
                
//                Features()
//                    .padding(.top, 46)
//                    .shadow(radius: 3)
                
                Spacer()
                
                GetStarted()
                    .padding(.bottom, 58)
                    .onTapGesture {
                        
                        standard.setValue(true, forKey: "hasLaunchedBefore")
                        
                    }
                
            }
            
        }
    }
}

private struct Features: View {
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            HStack {
                
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.system(size: 38))
                
                VStack(alignment: .leading) {
                    
                    Text("Featured")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                        .font(.system(size: 15))
                        .shadow(radius: 3)
                    
                    Text("Discover new grenade line-ups to give\nyou a competitiveadvantage in-game.")
                        .foregroundColor(Color("Description"))
                        .font(.system(size: 15))
                        .shadow(radius: 3)
                    
                }
                
            }
            
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 1, height: 32)
            
            HStack {
                
                Image(systemName: "map.fill")
                    .foregroundColor(.green)
                    .font(.system(size: 38))
                
                VStack(alignment: .leading) {
                    
                    Text("Maps")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                        .font(.system(size: 15))
                        .shadow(radius: 3)
                    
                    Text("Search for grenade line-ups by map,\nfrom Active Duty and Reserves Groups.")
                        .foregroundColor(Color("Description"))
                        .font(.system(size: 15))
                        .shadow(radius: 3)
                    
                }
                
            }
            
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 1, height: 32)
            
            HStack {
                
                Image(systemName: "heart.fill")
                    .foregroundColor(Color("Heart"))
                    .font(.system(size: 38))
                
                VStack(alignment: .leading) {
                    
                    Text("Favourite")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                        .font(.system(size: 15))
                        .shadow(radius: 3)
                    
                    Text("Save your favourite maps and line-ups\nfor quick access during your next match.")
                        .foregroundColor(Color("Description"))
                        .font(.system(size: 15))
                        .shadow(radius: 3)
                    
                }
                
            }
            
        }
        
    }
    
}

private struct GetStarted: View {
    
    @AppStorage("hasLaunchedBefore") var hasLaunchedBefore: Bool = false
    
    var body: some View {
        
        Button {
            
            print("Tapped")
            hasLaunchedBefore = true
            
        } label: {
            
            Text("Get Started")
                .fontWeight(.semibold)
                .frame(width: UIScreen.screenWidth - 90, height: 52)
            
        }
        .background(
            
            Rectangle()
                .background(.regularMaterial)
            
        )
        .clipShape(
        
            RoundedRectangle(cornerRadius: 15, style: .continuous)
            
        )
        
    }
    
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
