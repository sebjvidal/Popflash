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

        VStack(alignment: .leading) {
            
            Toggle("News", isOn: $newsNotifications)
                .onChange(of: newsNotifications) { _ in
                    
                    if newsNotifications {
                        
                        subscribe(to: "popflashNews")
                        
                    } else {
                        
                        unsubscribe(from: "popflashNews")
                        
                    }
                    
                }
                .padding(.horizontal)
            
            Text("Receive occasional notifications of new maps, grenade line-ups and features.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.top, -8)
                .padding(.leading)
                .padding(.trailing, 64)
            
            Divider()
                .padding(.leading, 16)
            
            Toggle("Featured", isOn: $featuredNotifications)
                .onChange(of: featuredNotifications) { _ in
                    
                    if featuredNotifications {
                        
                        subscribe(to: "popflashFeatured")
                        
                    } else {
                        
                        unsubscribe(from: "popflashFeatured")
                        
                    }
                    
                }
                .padding(.horizontal)
            
            Text("Receive a daily notification of a featured grenade line-up and map.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.top, -8)
                .padding(.leading)
                .padding(.trailing, 64)
            
        }
        .padding(.vertical, 8)
        .background(Color("Background"))
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        .padding()
        .onAppear(perform: onAppear)
        .onChange(of: notificationsViewModel.notifications) { notifications in
            
            if notifications.contains("popflashNews") { newsNotifications = true }
            if notifications.contains("popflashFeatured") { featuredNotifications = true }
            
        }
        
    }
    
    func onAppear() {
        
        notificationsViewModel.fetchData()
        
    }
    
}
