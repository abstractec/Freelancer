//
//  Item.swift
//  Freelancer
//
//  Created by John Haselden on 30/06/2024.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
