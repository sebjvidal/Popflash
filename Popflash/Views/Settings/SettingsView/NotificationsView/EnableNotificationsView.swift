//
//  EnableNotificationsView.swift
//  EnableNotificationsView
//
//  Created by Seb Vidal on 21/08/2021.
//

import SwiftUI

struct EnableNotificationsView: View {
    
    var body: some View {

        SettingsIconRow()
        
        NotificationsRow()
        
        EnableNotificationsRow()
        
    }
    
}

private struct SettingsIconRow: View {
    
    var body: some View {
        
        Button(action: openSettings) {
            
            ZStack {
                
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .foregroundColor(Color("Background"))
                    .cellShadow()
                
                HStack {
                    
                    Image("Settings_Icon")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 12.5, style: .continuous))
                    
                    Text("Open Settings")
                        .foregroundColor(.blue)
                        .padding(.leading, 8)
                    
                    Spacer()
                    
                    Image(systemName: "square.on.square")
                        .foregroundStyle(.tertiary)
                    
                }
                .padding()
                
            }
            
        }
        .padding()
        .buttonStyle(RoundedTableCell())
        
    }
    
    func openSettings() {
        
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            
            return
            
        }
        
        if UIApplication.shared.canOpenURL(settingsURL) {
        
            UIApplication.shared.open(settingsURL)
            
        }
        
    }
    
}

private struct NotificationsRow: View {
    
    var body: some View {
        
        ZStack {
            
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .foregroundColor(Color("Background"))
                .cellShadow()
            
            VStack(spacing: 0) {
                
                Divider()
                
                HStack {
                    
                    ZStack {
                        
                        RoundedRectangle(cornerRadius: 6.5, style: .continuous)
                            .frame(width: 29, height: 29)
                            .foregroundColor(.red)
                        
                        Image(systemName: "bell.badge.fill")
                            .font(.system(size: 17))
                            .foregroundColor(.white)
                        
                    }
                    .padding(.vertical, 10)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        
                        Text("Notifications")
                            .font(.callout)
                        
                        Text("Off")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                    }

                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.tertiary)
                        .font(.callout)
                        .padding(.trailing)
                    
                }
                
                Divider()
                
            }
            .padding([.top, .leading, .bottom])
            
        }
        .padding([.horizontal, .bottom])
        
    }
    
}

private struct EnableNotificationsRow: View {
    
    @State var isOn = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        
        ZStack {
            
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .foregroundColor(Color("Background"))
                .cellShadow()
            
            VStack(spacing: 0) {
                
                Divider()
                
                HStack {
                    
                    Text("Enable Notifications")

                    Spacer()
                    
                    Toggle("Enable Notifications", isOn: $isOn)
                        .labelsHidden()
                        .padding(.vertical, 8)
                        .onReceive(timer) { input in
                            
                            withAnimation {
                                
                                isOn.toggle()
                                
                            }
                            
                        }
                    
                }
                
                Divider()
                
            }
            .padding([.top, .leading, .bottom])
            
        }
        .padding([.horizontal, .bottom])
        
    }
    
}
