//
//  Billable.swift
//  Freelancer
//
//  Created by John Haselden on 21/08/2025.
//

import Foundation
import SwiftData

@Model
final class Billable: Identifiable {
    var id = UUID()
    var start: Date
    var end: Date
    var details: String
    var project: Project?
    var rate: Rate?
    var status: BillableStatus?
    var invoice: Invoice?
    /// Optional so older store rows with a null value do not crash on materialization.
    var kind: BillableKind?
    var fixedAmount: Double = 0
    var currency: String = ""
    
    /// Safe accessor for UI and calculations; treats missing values as time-based
    /// (or fixed when there is no rate and a fixed amount is present).
    var resolvedKind: BillableKind {
        get {
            if let kind {
                return kind
            }
            if rate == nil && fixedAmount != 0 {
                return .fixed
            }
            return .time
        }
        set {
            kind = newValue
        }
    }
    
    init(
        start: Date,
        end: Date,
        details: String,
        project: Project,
        rate: Rate? = nil,
        kind: BillableKind = .time,
        fixedAmount: Double = 0,
        currency: String = ""
    ) {
        self.start = start
        self.end = end
        self.details = details
        self.project = project
        self.rate = rate
        self.status = .new
        self.kind = kind
        self.fixedAmount = fixedAmount
        self.currency = currency
    }
    
    static var emptyBillable: Billable {
        Billable(start: Date(), end: Date(), details: "", project: .emptyProject)
    }
}


enum BillableStatus: String, CaseIterable, Codable, Identifiable {
    var id: Self {self}
    
    case new = "new"
    case cancelled = "cancelled"
    case invoiced = "invoiced"
    case paid = "paid"
}

enum BillableKind: String, CaseIterable, Codable, Identifiable {
    var id: Self { self }
    
    case time = "time"
    case fixed = "fixed"
    
    var label: String {
        switch self {
        case .time:
            return "Time-based"
        case .fixed:
            return "Fixed cost"
        }
    }
}
