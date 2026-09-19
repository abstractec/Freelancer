//
//  StatusBadge.swift
//  Freelancer
//

import SwiftUI

struct StatusBadge: View {
    let title: String
    let systemImage: String
    let tint: Color
    
    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.caption.weight(.medium))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .foregroundStyle(tint)
            .background(tint.opacity(0.15), in: Capsule())
    }
}

extension StatusBadge {
    static func client(_ status: Client.ClientStatus) -> StatusBadge {
        switch status {
        case .pending:
            return StatusBadge(title: "Pending", systemImage: "clock", tint: .orange)
        case .won:
            return StatusBadge(title: "Won", systemImage: "checkmark.circle", tint: .green)
        case .lost:
            return StatusBadge(title: "Lost", systemImage: "xmark.circle", tint: .red)
        case .expired:
            return StatusBadge(title: "Expired", systemImage: "archivebox", tint: .secondary)
        }
    }
    
    static func project(_ status: Project.ProjectStatus) -> StatusBadge {
        switch status {
        case .pending:
            return StatusBadge(title: "Pending", systemImage: "clock", tint: .orange)
        case .won:
            return StatusBadge(title: "Won", systemImage: "checkmark.circle", tint: .green)
        case .lost:
            return StatusBadge(title: "Lost", systemImage: "xmark.circle", tint: .red)
        case .expired:
            return StatusBadge(title: "Expired", systemImage: "archivebox", tint: .secondary)
        }
    }
    
    static func task(_ status: TaskStatus) -> StatusBadge {
        switch status {
        case .pending:
            return StatusBadge(title: "Pending", systemImage: "clock", tint: .orange)
        case .done:
            return StatusBadge(title: "Done", systemImage: "checkmark.circle", tint: .green)
        case .cancelled:
            return StatusBadge(title: "Cancelled", systemImage: "xmark.circle", tint: .red)
        }
    }
    
    static func billable(_ status: BillableStatus?) -> StatusBadge {
        switch status ?? .new {
        case .new:
            return StatusBadge(title: "New", systemImage: "circle", tint: .blue)
        case .cancelled:
            return StatusBadge(title: "Cancelled", systemImage: "xmark.circle", tint: .red)
        case .invoiced:
            return StatusBadge(title: "Invoiced", systemImage: "doc.text", tint: .purple)
        case .paid:
            return StatusBadge(title: "Paid", systemImage: "checkmark.circle.fill", tint: .green)
        }
    }
    
    static func invoice(_ status: InvoiceStatus) -> StatusBadge {
        switch status {
        case .new:
            return StatusBadge(title: "New", systemImage: "circle", tint: .blue)
        case .cancelled:
            return StatusBadge(title: "Cancelled", systemImage: "xmark.circle", tint: .red)
        case .invoiced:
            return StatusBadge(title: "Invoiced", systemImage: "doc.text", tint: .purple)
        case .paid:
            return StatusBadge(title: "Paid", systemImage: "checkmark.circle.fill", tint: .green)
        }
    }
}
