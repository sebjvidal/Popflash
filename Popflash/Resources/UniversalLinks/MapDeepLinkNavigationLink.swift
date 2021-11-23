//
//  MapDeepLinkNavigationLink.swift
//  Popflash
//
//  Created by Seb Vidal on 19/11/2021.
//

import SwiftUI

struct MapNavigationLink: View {
    @Binding var selectedMap: Map?
    
    var body: some View {
        Group {
            if let linkedMap = selectedMap {
                NavigationLink(destination: MapsDetailView(map: linkedMap), tag: linkedMap, selection: $selectedMap) {
                    EmptyView()
                }
                .hidden()
                .disabled(true)
            }
        }
    }
}
