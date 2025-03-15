//
//  SupercoldApp.swift
//  Supercold
//
//  Created by Oumar Ka on 13/03/2025.
//

import SwiftUI

@main
struct SupercoldApp: App {
    @StateObject private var calendarData = CalendarData()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(calendarData)
                .onOpenURL { url in
                    // Handle URL scheme from widgets
                    if url.scheme == "supercold" {
                        print("App opened from widget")
                        // You can add specific navigation logic here if needed
                    }
                }
        }
    }
}
