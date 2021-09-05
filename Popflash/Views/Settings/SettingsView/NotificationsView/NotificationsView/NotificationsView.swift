//
//  NotificationsView.swift
//  NotificationsView
//
//  Created by Seb Vidal on 20/08/2021.
//

import SwiftUI
import FirebaseAuth
import FirebaseMessaging

struct NotificationsView: View {
    
    @State var notificationsEnabled = false
    
    var body: some View {
        
        List {
            
            Group {
                
                Header()
                
                if notificationsEnabled {
                    
                    NotificationsSettingsView()
                    
                } else {
                    
                    EnableNotificationsView()
                    
                }
                
            }
            .listRowSeparator(.hidden)
            .listRowInsets(.some(EdgeInsets()))
            
        }
        .listStyle(.plain)
        .onAppear(perform: onAppear)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            
            checkPushNotification()
            
        }
        
    }
    
    func onAppear() {
        
        checkPushNotification()
        
    }
    
    func checkPushNotification(){
        
        UNUserNotificationCenter.current().getNotificationSettings() { (setttings) in
            
            switch setttings.authorizationStatus{
                
            case .authorized:
                notificationsEnabled = true
                
            case .denied, .notDetermined, .provisional, .ephemeral:
                notificationsEnabled = false
                
            @unknown default:
                notificationsEnabled = false
                
            }
            
        }
        
    }
    
}

private struct Header: View {
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            Spacer()
                .frame(height: 8)
            
            HStack() {
                
                Text("Notifications")
                    .font(.system(size: 32))
                    .fontWeight(.bold)
                    .padding(.leading, 16)
                
                Spacer()
                
            }
            
            Divider()
                .padding(.top, 6)
                .padding(.horizontal, 16)

        }
        
    }
    
}

private struct NotificationsSettingsView: View {
    
    @StateObject var notificationsViewModel = NotificationsViewModel()
    
    @State var newsNotifications = false
    @State var featuredNotifications = false
    
    var body: some View {

        VStack {
            
            HStack(alignment: .top) {
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    Text("News")
                        .padding(.top, 2)
                    
                    Text("Receive occasional notifications when new maps, grenade line-ups and features are added.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                }
                
                Spacer()
                
                Toggle("News", isOn: $newsNotifications)
                    .labelsHidden()
                    .padding(.top, 8)
                    .onChange(of: newsNotifications) { _ in
                        
                        if newsNotifications {
                            
                            subscribe(to: "popflashNews")
                            
                        } else {
                            
                            unsubscribe(from: "popflashNews")
                            
                        }
                        
                    }
                
            }
            .padding(.horizontal)

            Divider()
                .padding(.leading, 16)
            
            HStack(alignment: .top) {
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    Text("Featured")
                        .padding(.top, 2)
                    
                    Text("Receive a daily notification of the featured grenade line-up and map. ")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                }
                
                Spacer()
                
                Toggle("Featured", isOn: $featuredNotifications)
                    .labelsHidden()
                    .padding(.top, 8)
                    .onChange(of: featuredNotifications) { _ in
                        
                        if featuredNotifications {
                            
                            subscribe(to: "popflashFeatured")
                            
                        } else {
                            
                            unsubscribe(from: "popflashFeatured")
                            
                        }
                        
                    }
                
            }
            .padding(.horizontal)
            
        }
        .padding(.top, 8)
        .padding(.bottom, 14)
        .background(Color("Background"))
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        .cellShadow()
        .padding()
        .onAppear(perform: onAppear)
        .onChange(of: notificationsViewModel.topics) { topics in
            
            if topics.contains("popflashNews") { newsNotifications = true }
            if topics.contains("popflashFeatured") { featuredNotifications = true }
            
        }
        
    }
    
    func onAppear() {
        
        notificationsViewModel.fetchData()
        
    }
    
}
