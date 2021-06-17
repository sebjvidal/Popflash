//
//  SettingsView.swift
//  Popflash
//
//  Created by Seb Vidal on 13/02/2021.
//

import SwiftUI

struct SettingsView: View {
    
    @AppStorage("tabSelection") var tabSelection: Int = 0
    
    var body: some View {
        
        ScrollView {
            
            Header()

            MainSettings()
            
        }
        .onAppear {
            
            UITableView.appearance().separatorStyle = .none
            
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
                .padding(.horizontal)
                .padding(.top, 2)
                .padding(.bottom, 8)
            
        }
        
    }
    
}

private struct SettingIcon: View {
    
    var color: Color
    var icon: String
    
    var body: some View {
        
        ZStack {
            
            RoundedRectangle(cornerRadius: 6.5, style: .continuous)
                .frame(width: 29, height: 29)
                .foregroundColor(color)
            
            Image(systemName: icon)
                .foregroundColor(.white)
            
        }
        .padding(.leading)
        
    }
    
}

private struct MainSettings: View {
    
    @AppStorage("settings.compactMapsView") var compactMapView = false
    
    var body: some View {
        
        ZStack {
            
            VStack {
                
                HStack {
                    
                    SettingIcon(color: .red, icon: "app.badge")
                    
                    Button {
                        
                    } label: {
                        
                        HStack {
                            
                            Text("Notifications")
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .padding(.trailing)
                            
                        }
                        
                    }
                    
                }
                
                Divider()
                    .padding(.leading, 54)
                
                HStack {
                    
                    SettingIcon(color: .green, icon: "rectangle.arrowtriangle.2.inward")
                    
                    Toggle("Compact Maps View", isOn: $compactMapView)
                        .padding(.trailing)
                    
                }
                
            }
            .padding(.vertical, 12)
            
        }
        .background(Color("Background"))
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        .padding(.horizontal, 16)
        .shadow(radius: 6, y: 5)
        
    }
    
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
