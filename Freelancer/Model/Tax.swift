//
//  Tax.swift
//  Freelancer
//
//  Created by John Haselden on 23/08/2025.
//

import Foundation
import SwiftData

@Model
final class Tax: Identifiable {
    var id = UUID()
    var name: String
    var rate: Double
    
    init(id: UUID = UUID(), name: String, rate: Double) {
        self.id = id
        self.name = name
        self.rate = rate
    }
    
    static var emptyTax: Tax {
        Tax(id: UUID(), name: "", rate: 0)
    }

}
