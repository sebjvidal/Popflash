//
//  SettingsView.swift
//  Popflash
//
//  Created by Seb Vidal on 13/02/2021.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("settings.compactMapsView") var compactMapView = false
    @AppStorage("tabSelection") var tabSelection: Int = 0
    
    var body: some View {
        ScrollView {
            Header()
            
            VStack(alignment: .leading) {
                Toggle("Compact Maps View", isOn: $compactMapView)
                    .padding(.horizontal)
                Divider()
                    .padding(.leading)
            }
        }
        .onAppear {
            
            tabSelection = 3
            
        }
    }
}

private struct Header: View {
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 48)
            
            HStack {
                Text("Settings")
                    .font(.system(size: 32))
                    .fontWeight(.bold)
                    .padding(.leading)
                Spacer()
            }
            Divider()
                .padding(.leading)
                .padding(.top, 2)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
