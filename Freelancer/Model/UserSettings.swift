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
    var address: String?
     
    init(id: UUID = UUID(), address: String? = nil) {
        self.id = id
        self.address = address
    }
    
}
