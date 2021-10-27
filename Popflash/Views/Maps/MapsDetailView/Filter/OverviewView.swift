//
//  OverviewView.swift
//  Popflash
//
//  Created by Seb Vidal on 04/07/2021.
//

import SwiftUI
import Kingfisher

struct OverviewView: View {
    
    var map: Map
    
    @State var selection = "Upper Level"
    
    @StateObject var overviewViewModel = OverviewViewModel()
    
    var body: some View {
        
        ForEach(overviewViewModel.overviews, id: \.self) { overview in
            
            VStack(spacing: 0) {
                
                Radar(overview: overview, selection: selection)
                    .overlay {
                        
                        RadarOverlay(callouts: overviewViewModel.callouts)
                        
                    }
                
                if overview.lowerRadar != nil {
                    
                    LevelPicker(selection: $selection)
                    
                }
                
                CalloutList(overview: overview, callouts: overviewViewModel.callouts)
                
            }
            
        }
        .preferredColorScheme(.dark)
        .onAppear(perform: onAppear)
        
    }
    
    func onAppear() {
        
        overviewViewModel.fetchOverviews(for: map)
        overviewViewModel.fetchCallouts(for: map)
        
    }
    
}

private struct Radar: View {
    
    var overview: Overview
    
    @State var selection: String
    
    var body: some View {
        
        Group {
            
            if selection == "Upper Level" {
                
                RadarImage(url: overview.upperRadar)
                
            } else {
                
                RadarImage(url: overview.lowerRadar ?? "")
                
            }
            
        }
        
    }
    
}

private struct RadarImage: View {
    
    var url: String
    
    var body: some View {
        
        KFImage(URL(string: url))
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: UIScreen.screenWidth,
                   height: UIScreen.screenWidth)
            .background(.black)
            .zIndex(1)
        
    }
    
}

private struct RadarOverlay: View {
    
    @State var callouts: [Callout]
    
    @AppStorage("settings.tint") var tint = 1
    
    var body: some View {
        
        GeometryReader { geo in
            
            ForEach(callouts, id: \.self) { callout in
                
                Circle()
                    .frame(width: 16, height: 16)
                    .foregroundColor(TintColour.colour(withID: tint))
                    .position(x: (geo.size.width / 100) * callout.posX,
                              y: (geo.size.height / 100) * callout.posY)
                    .shadow(radius: 2)
                
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        
    }
    
}

private struct LevelPicker: View {
    
    @Binding var selection: String
    
    let options = ["Upper Level", "Lower Level"]
    
    var body: some View {
        
        Picker("Radar Level", selection: $selection) {
            
            ForEach(options, id: \.self) { option in
                
                Text(option)
                
            }
            
        }
        .pickerStyle(.segmented)
        .padding(17)
        .padding(.horizontal, 2)
        .background(.background)
        .zIndex(1)
        
    }
    
}

private struct CalloutList: View {
    
    var overview: Overview
    
    @State var callouts: [Callout]
    
    var body: some View {
        
        List {

            ForEach(callouts, id: \.self) { callout in

                Text(callout.name)

            }

        }
        .edgesIgnoringSafeArea(.all)
        .padding(.top, overview.lowerRadar != nil ? -30 : -14)
        
    }
    
}
