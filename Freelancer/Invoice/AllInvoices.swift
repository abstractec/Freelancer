//
//  AllInvoices.swift
//  Freelancer
//

import SwiftUI
import SwiftData

enum InvoiceListFilter: String, CaseIterable, Identifiable {
    case all
    case unpaid
    case pastDue
    case paid
    
    var id: Self { self }
    
    var title: String {
        switch self {
        case .all: return "All"
        case .unpaid: return "Unpaid"
        case .pastDue: return "Past Due"
        case .paid: return "Paid"
        }
    }
}

struct AllInvoices: View {
    @Query private var invoices: [Invoice]
    @State private var filter: InvoiceListFilter = .all
    
    private var filteredInvoices: [Invoice] {
        let sorted = invoices.sorted { lhs, rhs in
            let left = lhs.issuedAt ?? lhs.start
            let right = rhs.issuedAt ?? rhs.start
            return left > right
        }
        
        switch filter {
        case .all:
            return sorted
        case .unpaid:
            return sorted.filter(\.isOutstanding)
        case .pastDue:
            return sorted.filter(\.isPastDue)
        case .paid:
            return sorted.filter { $0.status == .paid }
        }
    }
    
    private var pastDueCount: Int {
        invoices.filter(\.isPastDue).count
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Picker("Filter", selection: $filter) {
                ForEach(InvoiceListFilter.allCases) { option in
                    Text(option.title).tag(option)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            if filteredInvoices.isEmpty {
                ContentUnavailableView(
                    emptyTitle,
                    systemImage: emptySymbol,
                    description: Text(emptyDescription)
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(filteredInvoices) { invoice in
                        if let project = invoice.project {
                            InvoiceRow(invoice: invoice, project: project, showsProjectContext: true)
                        }
                    }
                }
            }
        }
        .navigationTitle("Invoices")
        .toolbar {
            if pastDueCount > 0 {
                ToolbarItem(placement: .status) {
                    Text("\(pastDueCount) past due")
                        .foregroundStyle(.red)
                        .font(.caption.weight(.semibold))
                }
            }
        }
    }
    
    private var emptyTitle: String {
        switch filter {
        case .all: return "No Invoices"
        case .unpaid: return "No Unpaid Invoices"
        case .pastDue: return "No Past Due Invoices"
        case .paid: return "No Paid Invoices"
        }
    }
    
    private var emptySymbol: String {
        switch filter {
        case .pastDue: return "exclamationmark.triangle"
        case .paid: return "checkmark.circle"
        default: return "doc.text"
        }
    }
    
    private var emptyDescription: String {
        switch filter {
        case .all:
            return "Create an invoice from a project to track payment."
        case .unpaid:
            return "Outstanding invoices will appear here."
        case .pastDue:
            return "Invoices past their client payment terms will appear here."
        case .paid:
            return "Mark invoices as paid to see them here."
        }
    }
}

#Preview {
    NavigationStack {
        AllInvoices()
    }
}
