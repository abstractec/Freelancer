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

    @Binding var isPresented: Bool?
    @State private var project: Project = Project.emptyProject
    @State private var invoice: Invoice?

    @State private var multiSelection:Set<UUID> = []
    @State private var selectedTax: Tax.ID?
    
    @State private var total: String = ""
    
    @State private var billables: [Billable] = []
    
    init(isPresented: Binding<Bool>, project: Project, invoice: Invoice? = nil) {
        self.project = project
        self.invoice = invoice
        
        _isPresented = Binding.constant(false)
        self.isPresented = isPresented.wrappedValue
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Text("Billables").font(.headline).padding(.top)
            Text("Multiple Select").font(.subheadline)
            List(billables, selection: $multiSelection) { billable in
                Text(billable.details)
            }
            .frame(minHeight: (minRowHeight * 1.3)+(minRowHeight * CGFloat(15)))
            .onAppear() {
                if (invoice == nil) {
                    billables = project.billables.filter { billable in
                        billable.status == .new
                    }
                } else {
                    billables = project.billables
                }
                
                invoice?.billables.forEach { billable in
                    self.multiSelection.insert(billable.id)
                }
            }
            .onChange(of: multiSelection.count) {
                calculateTotal()
            }

            Text("Tax").font(.headline).padding(.top)
            Text("Single Select").font(.subheadline)
            List(taxes, selection: $selectedTax) { tax in
                Text("\(tax.name) @ \(String(format: "%.2f", tax.rate))%")
            }
            .frame(minHeight: (minRowHeight * 1.3)+(minRowHeight * CGFloat(15)))
            .onAppear() {
                if let tax = invoice?.tax {
                    selectedTax = tax.id
                }
            }
            .onChange(of: selectedTax) {
                calculateTotal()
            }

            Text("\(multiSelection.count) selections")
            Text("\(total)")
            
            HStack {
                Button(action: {
                    modelData.rollback()
                    isPresented = false
                    dismiss()
                }, label: {
                    Text("Cancel")
                }).padding(.trailing, 8)
                
                
                Button(action: {
                    var billables: [Billable] = []
                    var startDate = Date()
                    var endDate = Date()
                    
                    multiSelection.forEach { uuid in
                        if let billable = project.billables.first(where: { $0.id == uuid }) {
                            if (billable.start < startDate) {
                                startDate = billable.start
                            }
                            
                            if (billable.end > endDate) {
                                endDate = billable.end
                            }
                            
                            billables.append(billable)
                        }
                    }
                    
                    if invoice == nil {
                        invoice = Invoice(start: startDate, end: endDate, details: "", project: self.project)
                        
                        if let invoice = invoice {
                            modelData.insert(invoice)
                            project.invoices.append(invoice)
                        }
                    } else {
                        invoice?.start = startDate
                        invoice?.end = endDate
                        
                        invoice?.billables.removeAll()
                    }
                    
                    if invoice?.sequence == nil, let sequence = Int(UserDefaults.standard.string(forKey: "sequence") ?? "no") {
                        invoice?.sequence = sequence
                        UserDefaults.standard.set("\(sequence + 1)", forKey: "sequence")
                        
                    }
                                       
                    billables.forEach { billable in
                        billable.invoice = invoice
                        billable.status = .invoiced
                    }
                    
                    if let taxId = selectedTax, let tax = taxes.first(where: { $0.id == taxId}) {
                        invoice?.tax = tax
                    }
                                        
                    isPresented = false
                    dismiss()
                }, label: {
                    Text("Save")
                }).padding(.trailing, 8)
            }.padding()
        }
        .navigationTitle("Invoice")
        .padding()
        .onAppear() {
            calculateTotal()
        }
    }
    
    private func calculateTotal() {
        let billableHelper = BillableHelper()
        var amount = 0.0
        var taxAmount = 0.0
        var totalValue = 0.0
        let currency = project.billables.first?.rate.currency ?? ""
        
        multiSelection.forEach { uuid in
            if let billable = project.billables.first(where: { $0.id == uuid }) {
                let interval = billableHelper.numberOfSegments(for: billable.rate.timeInterval, between: billable.start, and: billable.end)
                amount += Double((interval * billable.rate.amount) / billable.rate.timeUnit)
            }
        }

        if let tax = taxes.first(where: { $0.id == selectedTax }) {
            let rate = tax.rate
            taxAmount = (amount * rate) / 100
            totalValue = amount + taxAmount
        }
        
        total = "\(currency)\(amount) + TAX \(currency)\(taxAmount) = \(currency)\(totalValue)"
    }
}

#Preview {
    ProjectInvoice(isPresented: .constant(false), project: Project.emptyProject)
}
