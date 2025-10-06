//
//  FreelancerApp.swift
//  Freelancer
//
//  Created by John Haselden on 30/06/2024.
//

import SwiftUI
import SwiftData

@main
struct FreelancerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Client.self,
            Project.self,
            Task.self,
            Billable.self,
            Rate.self,
            Tax.self,
            UserSettings.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
