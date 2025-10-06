//
//  ProjectBillableRate.swift
//  Freelancer
//
//  Created by John Haselden on 21/08/2025.
//

import Foundation
import SwiftData

@Model
final class Rate: Identifiable {
    var id = UUID()
    var name: String
    var amount: Int
    var currency: String
    var timeInterval: TimeInterval
    var timeUnit: Int
    
    init(name: String, amount: Int, currency: String, timeInterval: TimeInterval, timeUnit: Int, project: Project) {
        self.name = name
        self.amount = amount
        self.currency = currency
        self.timeInterval = timeInterval
        self.timeUnit = timeUnit
    }
    
    static var emptyRate: Rate {
        Rate(name: "", amount: 0, currency: "", timeInterval: TimeInterval.minute, timeUnit: 0, project: Project.emptyProject)
    }

    enum TimeInterval: String, CaseIterable, Codable, Identifiable  {
        var id: Self { self }
        
        case minute = "minute"
        case hour = "hour"
        case day = "day"
    }

}
