//
//  EnableNotificationsView.swift
//  EnableNotificationsView
//
//  Created by Seb Vidal on 21/08/2021.
//

import SwiftUI

struct EnableNotificationsView: View {
    
    @State private var selected = 0
    @State private var isOn = false
    @State var lockScreen = false
    @State var notificationCentre = false
    @State var banners = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {

        Group {
            
            SettingsIconRow()
                .scaleEffect(selected == 1 ? 1.05 : 1)
            
            PopflashRow()
                .scaleEffect(selected == 2 ? 1.05 : 1)
            
            NotificationsRow()
                .scaleEffect(selected == 3 ? 1.05 : 1)
            
            EnableNotificationsRow(isOn: $isOn)
                .scaleEffect(selected == 4 ? 1.05 : 1)
            
            NotificationsSettingsView(lockScreen: $lockScreen,
                                      notificationCentre: $notificationCentre,
                                      banners: $banners)
                .scaleEffect([5, 6, 7].contains(selected) ? 1.05 : 1)
            
        }
        .animation(.easeInOut(duration: 0.25), value: selected)
        .onReceive(timer) { input in
            
            selected += 1
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                
                withAnimation {
                    
                    isOn = selected >= 4
                    
                }
                
                lockScreen = selected > 4
                notificationCentre = selected > 5
                banners = selected > 6
                
            }
            
            if selected > 7 {
                
                timer.upstream.connect().cancel()
                
            }

        }
        
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
        .padding([.top, .horizontal])
        .padding(.bottom, 8)
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

private struct PopflashRow: View {
    
    var body: some View {
        
        ZStack {
            
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .foregroundColor(Color("Background"))
                .cellShadow()
            
            VStack(spacing: 0) {
                
                Divider()
                
                HStack {

                    Image("Icon")
                        .resizable()
                        .frame(width: 29, height: 29)
                        .clipShape(RoundedRectangle(cornerRadius: 6.5, style: .continuous))
                        .overlay {
                            
                            RoundedRectangle(cornerRadius: 6.5, style: .continuous)
                                .stroke(.tertiary, lineWidth: 0.2)
                            
                        }
                        .padding(.vertical, 10)
                    
                    Text("Popflash")

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
        .padding(.vertical, 8)
        .padding(.horizontal)
        
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
        .padding(.vertical, 8)
        .padding(.horizontal)
        
    }
    
}

private struct EnableNotificationsRow: View {
    
    @Binding var isOn: Bool
    
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
                    
                    Toggle("Allow Notifications", isOn: $isOn)
                        .labelsHidden()
                        .padding(.vertical, 8)
                        .padding(.trailing)
                        .overlay(.black.opacity(0.001))
                    
                }
                
                Divider()
                
            }
            .padding([.top, .leading, .bottom])
            
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
        
    }
    
}

private struct NotificationsSettingsView: View {
    
    @Binding var lockScreen: Bool
    @Binding var notificationCentre: Bool
    @Binding var banners: Bool
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        
        ZStack {
            
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .foregroundColor(Color("Background"))
                .cellShadow()
            
            LazyVGrid(columns: columns) {
                
                VStack {
                    
                    Image("Lock_Screen")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 40)
                    
                    Text("Lock Screen")
                    
                    Check(checked: $lockScreen)
                        .padding(.top, 4)
                    
                }
                
                VStack {
                    
                    Image("Notification_Centre")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 40)
                    
                    Text("Notification Centre")
                        .fixedSize()
                    
                    Check(checked: $notificationCentre)
                        .padding(.top, 4)
                    
                }
                
                VStack {
                    
                    Image("Banners")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 40)
                    
                    Text("Banners")
                    
                    Check(checked: $banners)
                        .padding(.top, 4)
                    
                }
                
            }
            .padding(.vertical, 8)
            .padding()
            
        }
        .font(.system(.footnote))
        .padding(.vertical, 8)
        .padding(.horizontal)
        
    }
    
}

private struct Check: View {
    
    @Binding var checked: Bool
    
    var body: some View {
        
        ZStack {
            
            Image("Uncheck")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 21)
            
            if checked {
                
                Image("Check")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 21)
                    .transition(.scale)
                
            }
            
        }
        .animation(.easeInOut(duration: 0.1), value: checked)
        
    }
    
}
