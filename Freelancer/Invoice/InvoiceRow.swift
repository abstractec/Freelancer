//
//  InvoiceRow.swift
//  Freelancer
//
//  Created by John Haselden on 24/08/2025.
//

import SwiftUI

struct InvoiceRow: View {
    @Environment(\.modelContext) private var modelData
    @State private var showingEditInvoice = false
    @State private var showingPDF = false
    
    var invoice: Invoice
    var project: Project
    var showsProjectContext: Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    if let sequence = invoice.sequence {
                        Text("Invoice #\(String(format: "%08d", sequence))")
                            .font(.headline)
                    } else {
                        Text("\(invoice.billables.count) billable(s)")
                            .font(.headline)
                    }
                }
                
                if showsProjectContext {
                    Text(projectContextLabel)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Text(dateRange)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                if let dueLine = dueLine {
                    Text(dueLine)
                        .font(.caption)
                        .foregroundStyle(invoice.isPastDue ? Color.red : Color.secondary)
                }
            }
            
            Spacer()
            
            StatusBadge.invoice(invoice)
            
            if invoice.isOutstanding {
                Button {
                    invoice.markPaid()
                } label: {
                    Image(systemName: "checkmark.circle")
                }
                .buttonStyle(.borderless)
                .help("Mark as paid")
            } else if invoice.status == .paid {
                Button {
                    invoice.markUnpaid()
                } label: {
                    Image(systemName: "arrow.uturn.backward.circle")
                }
                .buttonStyle(.borderless)
                .help("Mark as unpaid")
            }
            
            Button {
                showingPDF = true
            } label: {
                Image(systemName: "doc")
            }
            .buttonStyle(.borderless)
            .help("Open PDF")
            
            Button {
                showingEditInvoice = true
            } label: {
                Image(systemName: "pencil")
            }
            .buttonStyle(.borderless)
            .help("Edit invoice")
            
            Button(role: .destructive) {
                modelData.delete(invoice)
            } label: {
                Image(systemName: "trash")
            }
            .buttonStyle(.borderless)
            .help("Delete invoice")
        }
        .sheet(isPresented: $showingPDF) {
            InvoicePDF(invoice: invoice, project: project)
        }
        .sheet(isPresented: $showingEditInvoice) {
            ProjectInvoice(isPresented: $showingEditInvoice, project: project, invoice: invoice)
        }
    }
    
    private var projectContextLabel: String {
        let client = project.client?.name ?? "No client"
        return "\(client) · \(project.name)"
    }
    
    private var dateRange: String {
        let start = invoice.start.formatted(date: .abbreviated, time: .omitted)
        let end = invoice.end.formatted(date: .abbreviated, time: .omitted)
        
        if Calendar.current.isDate(invoice.start, inSameDayAs: invoice.end) {
            return "Period \(start)"
        }
        
        return "Period \(start) – \(end)"
    }
    
    private var dueLine: String? {
        if invoice.status == .paid, let paidAt = invoice.paidAt {
            return "Paid \(paidAt.formatted(date: .abbreviated, time: .omitted))"
        }
        
        guard let dueDate = invoice.dueDate else { return nil }
        let dueText = dueDate.formatted(date: .abbreviated, time: .omitted)
        if invoice.isPastDue {
            return "Due \(dueText) · Net \(invoice.paymentTermsDays)"
        }
        return "Due \(dueText) · Net \(invoice.paymentTermsDays)"
    }
}

#Preview {
    InvoiceRow(invoice: Invoice.emptyInvoice, project: Project.emptyProject)
        .padding()
}
