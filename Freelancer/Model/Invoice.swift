//
//  Invoice.swift
//  Freelancer
//
//  Created by John Haselden on 23/08/2025.
//

import Foundation
import SwiftData

@Model
final class Invoice: Identifiable {
    var id = UUID()
    var start: Date
    var end: Date
    var project: Project?
    var status: InvoiceStatus
    var sequence: Int?
    
    @Relationship(deleteRule: .nullify, inverse: \Billable.invoice) var billables: [Billable]
    @Relationship var tax: Tax?

    init(start: Date, end: Date, details: String, project: Project, billables: [Billable] = []) {
        self.start = start
        self.end = end
        self.project = project
        self.status = .new
        self.billables = billables
    }
    
    static var emptyInvoice: Invoice {
        Invoice(start: Date(), end: Date(), details: "", project: .emptyProject)
    }
}

enum InvoiceStatus: String, CaseIterable, Codable, Identifiable {
    var id: Self {self}
    
    case new = "new"
    case cancelled = "cancelled"
    case invoiced = "invoiced"
    case paid = "paid"
}
