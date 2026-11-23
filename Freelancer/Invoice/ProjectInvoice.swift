//
//  ProjectInvoice.swift
//  Freelancer
//
//  Created by John Haselden on 23/08/2025.
//

import SwiftUI
import SwiftData
#if os(macOS)
import AppKit
#endif

struct ProjectInvoice: View {
    @Environment(\.modelContext) private var modelData
    @Environment(\.dismiss) var dismiss
    @Query private var taxes: [Tax]
    @Query private var allSettings: [UserSettings]
    
    @Binding var isPresented: Bool
    @Bindable var project: Project
    @State private var invoice: Invoice?
    @State private var multiSelection: Set<PersistentIdentifier> = []
    @State private var selectedTax: Tax.ID?
    @State private var total: String = ""
    @State private var sequenceText: String = ""
    @State private var didPrefillSequence = false
    
    init(isPresented: Binding<Bool>, project: Project, invoice: Invoice? = nil) {
        _isPresented = isPresented
        self.project = project
        _invoice = State(initialValue: invoice)
    }
    
    private var selectableBillables: [Billable] {
        project.billables.filter { billable in
            if (billable.status ?? .new) == .new {
                return true
            }
            guard let invoice else { return false }
            return invoice.billables.contains { $0.persistentModelID == billable.persistentModelID }
        }
        .sorted { $0.start < $1.start }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Invoice number", text: $sequenceText)
                    Button("Use next number") {
                        sequenceText = "\(nextSequence)"
                    }
                } header: {
                    Text("Invoice number")
                } footer: {
                    Text("Next number is \(nextSequence). Saving this invoice with a higher number moves the counter past it.")
                }
                
                Section("Billables") {
                    if selectableBillables.isEmpty {
                        Text("No open billables on this project yet.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(selectableBillables, id: \.persistentModelID) { billable in
                            Toggle(isOn: selectionBinding(for: billable)) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(billable.details)
                                    Text(billableSubtitle(billable))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
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
                invoice?.billables.forEach { multiSelection.insert($0.persistentModelID) }
                prefillSequence()
                if let tax = invoice?.tax {
                    selectedTax = tax.id
                }
                calculateTotal()
                resignInvoiceNumberFocus()
            }
            .onChange(of: allSettings.first?.invoiceSequence) { _, _ in
                prefillSequence()
            }
        }
    }
    
    private func selectionBinding(for billable: Billable) -> Binding<Bool> {
        Binding(
            get: { multiSelection.contains(billable.persistentModelID) },
            set: { isSelected in
                if isSelected {
                    multiSelection.insert(billable.persistentModelID)
                } else {
                    multiSelection.remove(billable.persistentModelID)
                }
                calculateTotal()
            }
        )
    }
    
    private func billableSubtitle(_ billable: Billable) -> String {
        let helper = BillableHelper()
        let includeTime = billable.resolvedKind != .fixed
        let start = formatBillableDate(billable.start, includeTime: includeTime)
        let end = formatBillableDate(billable.end, includeTime: includeTime)
        return "\(billable.resolvedKind.label) · \(start) – \(end) · \(helper.formattedAmount(for: billable))"
    }
    
    private func formatBillableDate(_ date: Date, includeTime: Bool) -> String {
        date.formatted(date: .abbreviated, time: includeTime ? .shortened : .omitted)
    }
    
    private func saveInvoice() {
        var selected: [Billable] = []
        var startDate = Date.distantFuture
        var endDate = Date.distantPast
        
        for identifier in multiSelection {
            guard let billable = project.billables.first(where: { $0.persistentModelID == identifier }) else { continue }
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
        
        applySequence()
        
        for billable in selected {
            billable.invoice = invoice
            billable.status = .invoiced
        }
        
        if let taxId = selectedTax, let tax = taxes.first(where: { $0.id == taxId }) {
            invoice?.tax = tax
        }
        
        invoice?.markIssued()
        
        isPresented = false
        dismiss()
    }
    
    private func prefillSequence() {
        if let sequence = invoice?.sequence {
            guard !didPrefillSequence else { return }
            sequenceText = "\(sequence)"
            didPrefillSequence = true
            return
        }
        
        guard invoice == nil, !didPrefillSequence else { return }
        guard allSettings.first != nil else { return }
        sequenceText = "\(nextSequence)"
        didPrefillSequence = true
        resignInvoiceNumberFocus()
    }
    
    private func resignInvoiceNumberFocus() {
        #if os(macOS)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            NSApp.keyWindow?.makeFirstResponder(nil)
        }
        #endif
    }
    
    private var nextSequence: Int {
        allSettings.first?.invoiceSequence ?? 0
    }
    
    /// Writes the typed number onto this invoice. A blank field assigns the next number only when this invoice has none.
    private func applySequence() {
        let settings = UserSettingsStore.shared(in: modelData)
        let typed = Int(sequenceText.filter(\.isNumber))
        if let typed {
            invoice?.sequence = typed
            if typed >= settings.invoiceSequence {
                settings.invoiceSequence = typed + 1
            }
        } else if invoice?.sequence == nil {
            invoice?.sequence = settings.nextInvoiceSequence()
        }
    }
    
    private func calculateTotal() {
        let billableHelper = BillableHelper()
        var amount = 0.0
        var selectedBillables: [Billable] = []
        
        for identifier in multiSelection {
            if let billable = project.billables.first(where: { $0.persistentModelID == identifier }) {
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
