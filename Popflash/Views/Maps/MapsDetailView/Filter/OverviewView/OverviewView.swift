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
    @State var calloutSelection = ""
    @State var calloutPreview: Callout?
    
    @State var showingShade = false
    @State var showingPreview = false
    
    @State var originX: CGFloat = 0.0
    @State var originY: CGFloat = 0.0
    @State var posX: CGFloat = 0.0
    @State var posY: CGFloat = 0.0
    @State var width: CGFloat = 30.0
    @State var height: CGFloat = 30.0
    
    @StateObject var overviewViewModel = OverviewViewModel()
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            if let overview = overviewViewModel.overview {

                Radar(overview: overview, selection: $selection)
                    .overlay {
                        
                        RadarOverlay(callouts: sortedCallouts(for: overview.callouts),
                                     calloutSelection: $calloutSelection)
                        
                    }
                
                LevelPicker(overview: overview,
                            selection: $selection)
                
                CalloutsList(overview: overview,
                             selection: $selection,
                             calloutSelection: $calloutSelection,
                             calloutPreview: $calloutPreview,
                             originX: $originX, originY: $originY,
                             posX: $posX, posY: $posY,
                             width: $width, height: $height)

            }
            
        }
        .preferredColorScheme(.dark)
        .onAppear(perform: onAppear)
        .onChange(of: calloutPreview) { callout in
            
            if let _ = callout {
                
                showingShade = true
                showingPreview = true
                
            }
            
        }
        .overlay {
            
            OverviewOverlay(calloutPreview: $calloutPreview,
                            showingShade: $showingShade, showingPreview: $showingPreview,
                            originX: $originY, originY: $originY,
                            posX: $posX, posY: $posY,
                            width: $width, height: $height)
            
        }
        
    }
    
    func onAppear() {
        
        overviewViewModel.fetchData(for: map)
        
    }
    
    func sortedCallouts(for callouts: [Callout]) -> [Callout] {
        
        let calls = callouts.sorted(by: {
            
            $0.name < $1.name
            
        }).filter { callout in
            
            if selection == "Upper Level"  {
                
                return callout.level == "Upper"
                
            } else {
                
                return callout.level == "Lower"
                
            }
            
        }
        
        return calls
        
    }
    
}

private struct OverviewOverlay: View {
    
    @Binding var calloutPreview: Callout?
    
    @Binding var showingShade: Bool
    @Binding var showingPreview: Bool
    
    @Binding var originX: CGFloat
    @Binding var originY: CGFloat
    @Binding var posX: CGFloat
    @Binding var posY: CGFloat
    @Binding var width: CGFloat
    @Binding var height: CGFloat
    
    @State var offset = 0.0
    @State var lineWidth = 2.0
    
    var body: some View {
        
        if let callout = calloutPreview {
            
            GeometryReader { geo in
                
                ZStack {
                    
                    Color.black
                        .opacity(showingShade ? 0.75 : 0)
                        .animation(.default)
                        .onTapGesture(perform: reset)
                    
                    if showingPreview {
                        
                        KFImage(URL(string: callout.thumbnail))
                            .resizable()
                            .aspectRatio(16/9, contentMode: .fill)
                            .frame(width: width, height: height)
                            .clipShape(Circle())
                            .overlay {
                                
                                Circle()
                                    .strokeBorder(.white, lineWidth: lineWidth)
                                    .background(.clear)
                                
                            }
                            .position(x: posX, y: posY  - offset)
                            .animation(.default, value: showingPreview)
                            .onAppear {
                                
                                offset =  geo.frame(in: .global).minY
                                onAppear()
                                
                            }
                            .contentShape(Circle())
                        
                    }
                    
                }
                .ignoresSafeArea()
                
            }
            
        }
        
    }
    
    func onAppear() {
        
        withAnimation(.easeInOut(duration: 0.2)) {
            
            lineWidth = 8.0
            posX = UIScreen.screenWidth / 2
            posY = (UIScreen.screenHeight / 2) + (offset / 4)
            width = UIScreen.screenWidth - 32
            height = UIScreen.screenWidth - 32
            
        }
        
    }
    
    func reset() {
        
        withAnimation(.easeInOut(duration: 0.2)) {
            
            lineWidth = 2.0
            width = 30
            height = 30
            posX = UIScreen.screenWidth - 43
            posY = originY
            showingShade = false
            
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {

            showingPreview = false
            calloutPreview = nil

        }
        
    }
    
}

private struct Radar: View {
    
    var overview: Overview
    
    @Binding var selection: String
    
    var body: some View {
        
        if selection == "Upper Level" {
            
            RadarImage(url: overview.upperRadar)
            
        } else {
            
            RadarImage(url: overview.lowerRadar ?? "")
            
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
    
    @Binding var calloutSelection: String
    
    @AppStorage("settings.tint") var tint = 1
    
    var body: some View {
        
        GeometryReader { geo in
            
            ForEach(callouts, id: \.self) { callout in
                
                Button { selectCallout(callout) } label: {
                    
                    if callout.name != "CT Spawn" && callout.name != "T Spawn" {
                        
                        CircleOverlay()
                        
                    } else {
                        
                        ImageOverlay(callout: callout)
                    
                    }
                    
                }
                .tint(calloutSelection == callout.name ? TintColour.colour(withID: tint) : .white)
                .opacity(calloutSelection == callout.name ? 1 : 0.75)
                .scaleEffect(calloutSelection == callout.name ? 2 : 1)
                .animation(.easeInOut(duration: 0.15), value: calloutSelection)
                .position(x: (geo.size.width / 100) * callout.posX,
                          y: (geo.size.height / 100) * callout.posY)
                .shadow(radius: 2)
                .zIndex(calloutSelection == callout.name ? 1 : 0)
                
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        
    }
    
    func selectCallout(_ callout: Callout) {
        
        if callout.name == calloutSelection {
            
            calloutSelection = ""
            
        } else {
            
            calloutSelection = callout.name
            
        }
        
    }
    
}

private struct CircleOverlay: View {
    
    var body: some View {
        
        Circle()
            .frame(width: 12, height: 12)
        
    }
    
}

private struct ImageOverlay: View {
    
    var callout: Callout
    
    var body: some View {
        
        Image(callout.name == "CT Spawn" ? "CT_Team_Logo" : "T_Team_Logo")
            .resizable()
            .frame(width: 20, height: 20)
        
    }
    
}

private struct LevelPicker: View {
    
    @State var overview: Overview
    
    @Binding var selection: String
    
    let options = ["Upper Level", "Lower Level"]
    
    var body: some View {
        
        if overview.lowerRadar != nil {
            
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
    
}

private struct CalloutList: View {
    
    @State var overview: Overview
    @Binding var selection: String
    @Binding var calloutSelection: String
    
    var body: some View {
        
        Group {
            
            if selection == "Upper Level" {
                
                OverviewTableView(callouts: overview.upperCallouts(), selection: $selection, calloutSelection: $calloutSelection)
                
            } else {
                
                OverviewTableView(callouts: overview.lowerCallouts(), selection: $selection, calloutSelection: $calloutSelection)
                
            }
            
        }
        .padding(.top, overview.lowerRadar != nil ? -24 : -4)
        .onChange(of: selection) { _ in
            
            calloutSelection = ""
            
        }

    }
    
}

private struct CalloutsList: View {
    
    var overview: Overview
    
//    @State var callouts: [Callout]
    
    @Binding var selection: String
    @Binding var calloutSelection: String
    @Binding var calloutPreview: Callout?
    
    @Binding var originX: CGFloat
    @Binding var originY: CGFloat
    @Binding var posX: CGFloat
    @Binding var posY: CGFloat
    @Binding var width: CGFloat
    @Binding var height: CGFloat
    
    var body: some View {
        
        ScrollViewReader { reader in
            
            List {
                
                ForEach(sortedCallouts(), id: \.self) { callout in
                    
                    CalloutCell(callout: callout, selectedCallout: $calloutSelection, calloutPreview: $calloutPreview,
                                originX: $originX, originY: $originY,
                                posX: $posX, posY: $posY,
                                width: $width, height: $height)
                        .id(sortedCallouts().firstIndex(of: callout))
                        .onChange(of: calloutSelection) { call in
                            
                            withAnimation {
                            
                                reader.scrollTo(sortedCallouts().firstIndex(where: { $0.name == call }), anchor: .center)
                                
                            }
                            
                        }
                    
                }
                .listRowInsets(.some(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)))
                
            }
            .padding(.top, overview.lowerRadar != nil ? -32 : -14)
            
        }
        
    }
    
    func sortedCallouts() -> [Callout] {
        
        let calls = overview.callouts.sorted(by: {
            
            $0.name < $1.name
            
        }).filter { callout in
            
            if selection == "Upper Level"  {
                
                return callout.level == "Upper"
                
            } else {
                
                return callout.level == "Lower"
                
            }
            
        }
        
        return calls
        
    }
    
}

private struct CalloutCell: View {
    
    @State var callout: Callout
    
    @Binding var selectedCallout: String
    @Binding var calloutPreview: Callout?
    
    @Binding var originX: CGFloat
    @Binding var originY: CGFloat
    @Binding var posX: CGFloat
    @Binding var posY: CGFloat
    @Binding var width: CGFloat
    @Binding var height: CGFloat
    
    var body: some View {
        
        Button(action: selectCallout) {
            
            ZStack {
                
                Color("Selected_Row")
                    .opacity(callout.name == selectedCallout ? 1 : 0)
                
                HStack {
                    
                    Text(callout.name)
                        .padding(.leading, 20)
                    
                    Spacer()
                    
                    if callout.thumbnail != "" {
                        
                        GeometryReader { geo in
                            
                            Button {
                                
                                selectPreview(geometry: geo)
                            
                            } label: {
                                
                                KFImage(URL(string: callout.thumbnail))
                                    .resizable()
                                    .aspectRatio(16/9, contentMode: .fill)
                                    .frame(width: 30, height: 30)
                                    .clipShape(Circle())
                                    .overlay {
                                        
                                        Circle()
                                            .strokeBorder(.white, lineWidth: 2)
                                            .background(.clear)
                                        
                                    }
                                    .opacity(calloutPreview == callout ? 0 : 1)

                            }
                            
                        }
                        .frame(width: 30, height: 30)
                        
                    }
                    
                }
                .padding(.trailing, 8)
                
            }
            
        }
        .tint(.white)
        
    }
    
    func selectCallout() {
        
        selectedCallout = selectedCallout == callout.name ? "" : callout.name
        
    }
    
    func selectPreview(geometry: GeometryProxy) {
        
        calloutPreview = callout
        
        originX = geometry.frame(in: .global).midX
        originY = geometry.frame(in: .global).midY
        posX = originX
        posY = originY
        
    }
    
}
