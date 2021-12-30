//
//  PopflashApp.swift
//  PopflashApp
//
//  Created by Seb Vidal on 04/10/2021.
//

import SwiftUI

@main
struct PopflashApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
