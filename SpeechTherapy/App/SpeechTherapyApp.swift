//
//  SpeechTherapyApp.swift
//  SpeechTherapy
//
//  Created by Art Arriaga on 4/24/25.
//


import SwiftUI

@main
struct SpeechTherapyApp: App {
    // Create the shared user preferences instance
    @StateObject private var userPreferences = UserPreferences()
    
    init() {
        // Initialize StoreManager early
        // This ensures the singleton is created before the views
        _ = StoreManager.shared
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(userPreferences)
                .task {
                    // Load products and check subscription status when app becomes active
                    await StoreManager.shared.loadProducts()
                    await StoreManager.shared.updateSubscriptionStatus()
                }
        }
    }
}
