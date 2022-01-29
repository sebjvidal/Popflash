//
//  AppIconView.swift
//  Popflash
//
//  Created by Seb Vidal on 22/11/2021.
//

import SwiftUI

struct AppIconView: View {
    @State private var selection: String? = UIApplication.shared.alternateIconName
    
    var body: some View {
        List {
            Group {
                Divider()
                    .padding(.horizontal)
                
                DefaultCustomIcons(selected: $selection)
                
                CsgoCustomIcons(selected: $selection)
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

private struct DefaultCustomIcons: View {
    @Binding var selected: String?
    
    var icons = [
        AppIcon(name: "Default", asset: nil),
        AppIcon(name: "Blueprint", asset: "AppIconDev")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Popflash Collection")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.top, 16)
                .padding(.leading, 20)
                .padding(.bottom, 6)
            
            CustomAppIcons(icons: icons, selected: $selected)
        }
    }
}

private struct CsgoCustomIcons: View {
    @Binding var selected: String?
    
    var icons = [
        AppIcon(name: "Inferno", asset: "InfernoIcon", premium: true),
        AppIcon(name: "Nuke", asset: "NukeIcon", premium: true),
        AppIcon(name: "Dust II", asset: "Dust IIIcon", premium: true),
        AppIcon(name: "Cobblestone", asset: "CobblestoneIcon", premium: true),
        AppIcon(name: "Cache", asset: "CacheIcon", premium: true),
        AppIcon(name: "Mirage", asset: "MirageIcon", premium: true),
        AppIcon(name: "Train", asset: "TrainIcon", premium: true),
        AppIcon(name: "Overpass", asset: "OverpassIcon", premium: true),
        AppIcon(name: "Vertigo", asset: "VertigoIcon", premium: true),
        AppIcon(name: "Ancient", asset: "AncientIcon", premium: true)
    ]
        .sorted { $0.name < $1.name }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("CS:GO Collection")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.top)
                .padding(.leading, 20)
                .padding(.bottom, 6)
            
            CustomAppIcons(icons: icons, selected: $selected)
        }
        .padding(.bottom)
    }
}

private struct CustomAppIcons: View {
    var icons: [AppIcon]
    @Binding var selected: String?
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(icons) { icon in
                DefaultIconRow(icon: icon, selected: $selected, position: pos(icon))
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
        .padding(.horizontal)
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
    @State var icon: AppIcon
    @Binding var selected: String?
    @State var position: ListPosition?
    
    @AppStorage("settings.tint") var tintID = 1
    
    var body: some View {
        Button(action: setIcon) {
            HStack {
                Image(iconPreviewName())
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                
                Text(icon.name)
                    .padding(.leading, 8)
                
                Spacer()
                
                disclosureIndicator
                    .padding(.top, position == .first ? 0 : 6)
                    .padding(.bottom, position == .last ? 0: 6)
            }
            .padding(.top, position == .first ? 15 : 8)
            .padding(.horizontal)
            .padding(.bottom, position == .last ? 15: 8)
            .background(Color("Background"))
        }
    }
    
    var disclosureIndicator: some View {
        ZStack {
            if icon.premium {
                Image(systemName: "lock.fill")
                    .foregroundStyle(.secondary)
            } else {
                Image(systemName: "checkmark")
                    .foregroundColor(TintColour.colour(withID: 1))
                    .opacity(selected == icon.asset ? 1 : 0)
            }
        }
    }
    
    func iconPreviewName() -> String {
        if let name = icon.asset {
            return "\(name)Preview"
        } else {
            return "AppIconPreview"
        }
    }
    
    func setIcon() {
        UIApplication.shared.setAlternateIconName(icon.asset)
        selected = icon.asset
    }
}

struct AppIconView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AppIconView()
        }
    }
}
