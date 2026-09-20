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
    /// When the invoice was issued (saved as outstanding).
    var issuedAt: Date?
    /// When the invoice was marked paid.
    var paidAt: Date?
    
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
    
    /// Payment window from the client, falling back to 30 days.
    var paymentTermsDays: Int {
        max(project?.client?.paymentTermsDays ?? 30, 0)
    }
    
    var dueDate: Date? {
        let issued = issuedAt ?? (isOutstanding || status == .paid ? start : nil)
        guard let issued else { return nil }
        return Calendar.current.date(byAdding: .day, value: paymentTermsDays, to: issued)
    }
    
    var isOutstanding: Bool {
        status == .new || status == .invoiced
    }
    
    var isPastDue: Bool {
        guard isOutstanding, let dueDate else { return false }
        let today = Calendar.current.startOfDay(for: Date())
        let dueDay = Calendar.current.startOfDay(for: dueDate)
        return today > dueDay
    }
    
    func markIssued(at date: Date = Date()) {
        if issuedAt == nil {
            issuedAt = date
        }
        if status == .new {
            status = .invoiced
        }
    }
    
    func markPaid(at date: Date = Date()) {
        status = .paid
        paidAt = date
        // Touch only status so older billable rows with null `kind` can still update.
        for billable in billables {
            billable.status = .paid
            if billable.kind == nil {
                billable.kind = billable.resolvedKind
            }
        }
    }
    
    func markUnpaid() {
        status = .invoiced
        paidAt = nil
        for billable in billables {
            billable.status = .invoiced
            if billable.kind == nil {
                billable.kind = billable.resolvedKind
            }
        }
    }
}

enum InvoiceStatus: String, CaseIterable, Codable, Identifiable {
    var id: Self { self }
    
    case new = "new"
    case cancelled = "cancelled"
    case invoiced = "invoiced"
    case paid = "paid"
}
