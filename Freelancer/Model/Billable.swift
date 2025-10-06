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
    var rate: Rate
    var status: BillableStatus?
    var invoice: Invoice?
    
    init(start: Date, end: Date, details: String, project: Project, rate: Rate) {
        self.start = start
        self.end = end
        self.details = details
        self.project = project
        self.rate = rate
        self.status = .new
    }
    
    static var emptyBillable: Billable {
        Billable(start: Date(), end: Date(), details: "", project: .emptyProject, rate: .emptyRate)
    }
}


enum BillableStatus: String, CaseIterable, Codable, Identifiable {
    var id: Self {self}
    
    case new = "new"
    case cancelled = "cancelled"
    case invoiced = "invoiced"
    case paid = "paid"
}
