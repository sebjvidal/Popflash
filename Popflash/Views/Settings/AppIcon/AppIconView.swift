//
//  AppIconView.swift
//  Popflash
//
//  Created by Seb Vidal on 22/11/2021.
//

import SwiftUI

struct AppIconView: View {
    var body: some View {
        List {
            Group {
                Divider()
                    .padding(.horizontal)
                CustomAppIcons()
            }
            .listRowInsets(.some(EdgeInsets()))
            .listRowSeparator(.hidden)
        }
        .navigationBarTitleDisplayMode(.large)
        .navigationTitle("App Icon")
        .listStyle(.plain)
        .environment(\.defaultMinListRowHeight, 1)
    }
}

private struct CustomAppIcons: View {
    @State var selected: String? = UIApplication.shared.alternateIconName
    
    var icons = [AppIcon(name: "Default", asset: nil),
                 AppIcon(name: "Blueprint", asset: "AppIconDev"),
                 AppIcon(name: "Blueprint", asset: "AppIconDev")]
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(icons, id: \.self) { icon in
                DefaultIconRow(name: icon.name, asset: icon.asset, selected: $selected, position: pos(icon))
                    .buttonStyle(RoundedTableCell())
                if pos(icon) != .last {
                    Divider()
                        .padding(.leading, 82)
                }
            }
        }
        .background(Color("Background"))
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        .cellShadow()
        .padding()
    }
    
    func pos(_ icon: AppIcon) -> ListPosition? {
        guard let index = icons.firstIndex(of: icon) else {
            return nil
        }
        
        if index == 0 {
            return .first
        }
        
        if index == icons.count - 1 {
            return .last
        }
        
        return nil
    }
}

private struct DefaultIconRow: View {
    @State var name: String
    @State var asset: String?
    @Binding var selected: String?
    @State var position: ListPosition?
    
    @AppStorage("settings.tint") var tintID = 1
    
    var body: some View {
        Button(action: setIcon) {
            HStack {
                Image(uiImage: UIImage(named: asset ?? "AppIcon")!)
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
                Text(name)
                    .padding(.leading, 8)
                Spacer()
                Image(systemName: "checkmark")
                    .foregroundColor(TintColour.colour(withID: 1))
                    .opacity(selected == asset ? 1 : 0)
                    .padding(.top, position == .first ? 0 : 6)
                    .padding(.bottom, position == .last ? 0: 6)
            }
            .padding(.top, position == .first ? 15 : 8)
            .padding(.horizontal)
            .padding(.bottom, position == .last ? 15: 8)
            .background(Color("Background"))
        }
    }
    
    func setIcon() {
        UIApplication.shared.setAlternateIconName(asset)
        selected = asset
    }
}

struct AppIconView_Previews: PreviewProvider {
    static var previews: some View {
        AppIconView()
            .preferredColorScheme(.dark)
    }
}
