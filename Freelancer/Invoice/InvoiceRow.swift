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
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(invoice.billables.count) billable(s)")
                    .font(.headline)
                Text(dateRange)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            StatusBadge.invoice(invoice.status)
            
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
    
    private var dateRange: String {
        let start = invoice.start.formatted(date: .abbreviated, time: .omitted)
        let end = invoice.end.formatted(date: .abbreviated, time: .omitted)
        
        if Calendar.current.isDate(invoice.start, inSameDayAs: invoice.end) {
            return start
        }
        
        return "\(start) – \(end)"
    }
}

#Preview {
    InvoiceRow(invoice: Invoice.emptyInvoice, project: Project.emptyProject)
        .padding()
}
