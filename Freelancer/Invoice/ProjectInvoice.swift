//
//  ProjectInvoice.swift
//  Freelancer
//
//  Created by John Haselden on 23/08/2025.
//

import SwiftUI
import SwiftData

struct ProjectInvoice: View {
    @Environment(\.defaultMinListRowHeight) var minRowHeight
    @Environment(\.modelContext) private var modelData
    @Environment(\.dismiss) var dismiss
    @Query private var taxes: [Tax]
    
    @Binding var isPresented: Bool
    @State private var project: Project
    @State private var invoice: Invoice?
    @State private var multiSelection: Set<UUID> = []
    @State private var selectedTax: Tax.ID?
    @State private var total: String = ""
    @State private var billables: [Billable] = []
    
    init(isPresented: Binding<Bool>, project: Project, invoice: Invoice? = nil) {
        _isPresented = isPresented
        _project = State(initialValue: project)
        _invoice = State(initialValue: invoice)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Billables") {
                    List(billables, selection: $multiSelection) { billable in
                        Text(billable.details)
                    }
                    .frame(minHeight: minRowHeight * CGFloat(max(billables.count, 4)))
                    .onChange(of: multiSelection.count) { _, _ in
                        calculateTotal()
                    }
                    
                    Text("\(multiSelection.count) selected")
                        .foregroundStyle(.secondary)
                }
                
                Section("Tax") {
                    Picker("Tax", selection: $selectedTax) {
                        Text("None").tag(Tax.ID?.none)
                        ForEach(taxes) { tax in
                            Text("\(tax.name) @ \(String(format: "%.2f", tax.rate))%").tag(Optional(tax.id))
                        }
                    }
                    .onChange(of: selectedTax) { _, _ in
                        calculateTotal()
                    }
                }
                
                if !total.isEmpty {
                    Section("Total") {
                        Text(total)
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle(invoice == nil ? "New Invoice" : "Edit Invoice")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        modelData.rollback()
                        isPresented = false
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveInvoice()
                    }
                    .disabled(multiSelection.isEmpty)
                }
            }
            .frame(minWidth: 520, minHeight: 560)
            .onAppear {
                if invoice == nil {
                    billables = project.billables.filter { $0.status == .new }
                } else {
                    billables = project.billables
                }
                invoice?.billables.forEach { multiSelection.insert($0.id) }
                if let tax = invoice?.tax {
                    selectedTax = tax.id
                }
                calculateTotal()
            }
        }
    }
    
    private func saveInvoice() {
        var selected: [Billable] = []
        var startDate = Date.distantFuture
        var endDate = Date.distantPast
        
        for uuid in multiSelection {
            guard let billable = project.billables.first(where: { $0.id == uuid }) else { continue }
            startDate = min(startDate, billable.start)
            endDate = max(endDate, billable.end)
            selected.append(billable)
        }
        
        if startDate == Date.distantFuture {
            startDate = Date()
        }
        if endDate == Date.distantPast {
            endDate = Date()
        }
        
        if invoice == nil {
            let created = Invoice(start: startDate, end: endDate, details: "", project: project)
            modelData.insert(created)
            project.invoices.append(created)
            invoice = created
        } else {
            invoice?.start = startDate
            invoice?.end = endDate
            invoice?.billables.removeAll()
        }
        
        if invoice?.sequence == nil, let sequence = Int(UserDefaults.standard.string(forKey: "sequence") ?? "") {
            invoice?.sequence = sequence
            UserDefaults.standard.set("\(sequence + 1)", forKey: "sequence")
        }
        
        for billable in selected {
            billable.invoice = invoice
            billable.status = .invoiced
        }
        
        if let taxId = selectedTax, let tax = taxes.first(where: { $0.id == taxId }) {
            invoice?.tax = tax
        }
        
        isPresented = false
        dismiss()
    }
    
    private func calculateTotal() {
        let billableHelper = BillableHelper()
        var amount = 0.0
        var selectedBillables: [Billable] = []
        
        for uuid in multiSelection {
            if let billable = project.billables.first(where: { $0.id == uuid }) {
                selectedBillables.append(billable)
                amount += billableHelper.amount(for: billable)
            }
        }
        
        let currency = billableHelper.currency(for: selectedBillables)
        var taxAmount = 0.0
        if let tax = taxes.first(where: { $0.id == selectedTax }) {
            taxAmount = (amount * tax.rate) / 100
        }
        let totalValue = amount + taxAmount
        total = "\(currency)\(String(format: "%.2f", amount)) + tax \(currency)\(String(format: "%.2f", taxAmount)) = \(currency)\(String(format: "%.2f", totalValue))"
    }
}

#Preview {
    ProjectInvoice(isPresented: .constant(true), project: Project.emptyProject)
}
