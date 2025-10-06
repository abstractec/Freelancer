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

    @State var invoice: Invoice
    @State var project: Project
    
    init(invoice: Invoice, project: Project) {
        self.invoice = invoice
        self.project = project
    }
    
    
    var body: some View {
        HStack {
            Text("\(invoice.billables.count) Billable(s) \(invoice.start) to \(invoice.end)")
            Spacer()
            Button {
                showingPDF.toggle()
            } label: {
                Label("PDF", systemImage: "document")
            }.padding(.trailing, 8)
                .sheet(isPresented: $showingPDF, content: {
                    InvoicePDF(invoice: self.invoice, project: self.project)
                })
            Button {
                showingEditInvoice.toggle()
            } label: {
                Label("Edit", systemImage: "pencil")
            }.padding(.trailing, 8)
                .sheet(isPresented: $showingEditInvoice, content: {
                    ProjectInvoice(isPresented: $showingEditInvoice, project: self.project, invoice: self.invoice)
                })
            Button {
                modelData.delete(invoice)
            } label: {
                Label("Delete", systemImage: "trash")
            }.padding(.trailing, 8)

        }
    }
}

#Preview {
    InvoiceRow(invoice: Invoice.emptyInvoice, project: Project.emptyProject)
}
