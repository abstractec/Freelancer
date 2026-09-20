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
    /// Set to `true` only with a paid Apple Developer Program team and iCloud/CloudKit
    /// entitlements (personal teams cannot use iCloud). Container should match the bundle id,
    /// e.g. `iCloud.com.abstractec.Freelancer`.
    private static let cloudKitSyncEnabled = false
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Client.self,
            Project.self,
            Task.self,
            Billable.self,
            Rate.self,
            Tax.self,
            UserSettings.self,
            Invoice.self,
        ])
        
        if cloudKitSyncEnabled {
            let cloudConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .automatic
            )
            
            do {
                return try ModelContainer(for: schema, configurations: [cloudConfiguration])
            } catch {
                print("CloudKit ModelContainer failed (\(error)). Falling back to local store.")
            }
        }
        
        let localConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .none
        )
        
        do {
            return try ModelContainer(for: schema, configurations: [localConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    _ = UserSettingsStore.shared(in: sharedModelContainer.mainContext)
                }
        }
        .modelContainer(sharedModelContainer)
        
        #if os(macOS)
        Settings {
            AppSettingsView()
                .modelContainer(sharedModelContainer)
        }
        #endif
    }
}
