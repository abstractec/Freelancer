//
//  UserSettings.swift
//  Freelancer
//
//  Created by John Haselden on 23/08/2025.
//

import Foundation
import SwiftData

@Model
final class UserSettings: Identifiable {
    var id = UUID()
    var companyName: String = ""
    var address: String = ""
    var bankDetails: String = ""
    var invoiceSequence: Int = 0
    var logoData: Data?
    var logoFilename: String?
    
    init(
        id: UUID = UUID(),
        companyName: String = "",
        address: String = "",
        bankDetails: String = "",
        invoiceSequence: Int = 0,
        logoData: Data? = nil,
        logoFilename: String? = nil
    ) {
        self.id = id
        self.companyName = companyName
        self.address = address
        self.bankDetails = bankDetails
        self.invoiceSequence = invoiceSequence
        self.logoData = logoData
        self.logoFilename = logoFilename
    }
    
    var hasLogo: Bool {
        guard let logoData else { return false }
        return !logoData.isEmpty
    }
    
    /// Allocate the next invoice number and persist the bump.
    func nextInvoiceSequence() -> Int {
        let value = invoiceSequence
        invoiceSequence = value + 1
        return value
    }
}

enum UserSettingsStore {
    private static let didMigrateDefaultsKey = "didMigrateUserSettingsFromDefaults"
    
    @MainActor
    static func shared(in context: ModelContext) -> UserSettings {
        var descriptor = FetchDescriptor<UserSettings>()
        descriptor.fetchLimit = 1
        
        if let existing = try? context.fetch(descriptor).first {
            return existing
        }
        
        let settings = UserSettings()
        migrateFromUserDefaultsIfNeeded(into: settings)
        context.insert(settings)
        try? context.save()
        return settings
    }
    
    @MainActor
    static func migrateFromUserDefaultsIfNeeded(into settings: UserSettings) {
        guard !UserDefaults.standard.bool(forKey: didMigrateDefaultsKey) else { return }
        
        if let name = UserDefaults.standard.string(forKey: "companyName"), !name.isEmpty {
            settings.companyName = name
        }
        if let address = UserDefaults.standard.string(forKey: "address"), !address.isEmpty {
            settings.address = address
        }
        if let bankDetails = UserDefaults.standard.string(forKey: "bankDetails"), !bankDetails.isEmpty {
            settings.bankDetails = bankDetails
        }
        if let sequenceString = UserDefaults.standard.string(forKey: "sequence"),
           let sequence = Int(sequenceString) {
            settings.invoiceSequence = sequence
        }
        
        if let filename = UserDefaults.standard.string(forKey: "companyLogoFilename") {
            let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("Freelancer", isDirectory: true)
            let url = dir.appendingPathComponent(filename)
            if let data = try? Data(contentsOf: url) {
                settings.logoData = data
                settings.logoFilename = filename
            }
        }
        
        UserDefaults.standard.set(true, forKey: didMigrateDefaultsKey)
    }
}
