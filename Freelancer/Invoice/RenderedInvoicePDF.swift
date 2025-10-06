//
//  RenderedInvoicePDF.swift
//  Freelancer
//
//  Created by John Haselden on 24/08/2025.
//

import SwiftUI

struct RenderedInvoicePDF: View {
    @Environment(\.defaultMinListRowHeight) var minRowHeight
    
    let pageWidth: CGFloat = 800
    
    @State private var invoice: Invoice
    @State private var companyName: String
    @State private var companyAddress: String
    @State private var bankDetails: String
    @State private var clientAddress: String

    init(invoice: Invoice, project: Project, companyName: String = "", companyAddress: String = "", bankDetails: String = "") {
        self.invoice = invoice
        self.companyAddress = UserDefaults.standard.string(forKey: "address") ?? ""
        self.bankDetails = UserDefaults.standard.string(forKey: "bankDetails") ?? ""
        self.companyName = UserDefaults.standard.string(forKey: "companyName") ?? ""
        self.clientAddress = project.client?.address ?? ""
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                Text(companyName)
                    .font(.title)
                Text("Invoice").font(.title)
                Spacer()
            }
            
            HStack {
                Spacer()
                Text("Ref: \(String(format: "%08d", (invoice.sequence ?? 0)))")
                Spacer()
            }.padding(.bottom, 16)
            
            HStack {
                Text("From:\n\(companyAddress)")
                Spacer()
                Text("To:\n\(clientAddress)")
            }.padding(.bottom, 16)

            
            VStack(alignment: .leading) {
                Text("Items")
                    .font(.headline)
                

                Grid {
                    GridRow {
                        Text("Details").gridCellAnchor(.leading)
                        Text("Start").gridCellAnchor(.leading)
                        Text("End").gridCellAnchor(.leading)
                        Text("Amount").gridCellAnchor(.leading)
                    }
                    Divider()
                    ForEach(invoice.billables) { billable in
                        GridRow {
                            Text(billable.details).gridCellAnchor(.leading)
                            Text(formatDate(billable.start)).gridCellAnchor(.leading)
                            Text(formatDate(billable.end)).gridCellAnchor(.leading)
                            Text("\(billable.rate.currency) \(String(format: "%.2f", calculateBillable(billable: billable)))").gridCellAnchor(.leading)
                        }
                    }
                }
                

            }
            
            Spacer()
            
            Text("Totals")
                .font(.headline)
            
            HStack {
                Spacer()
                VStack(alignment: .trailing) {
                    VStack {
                        HStack {
                            Text("Total (Excluding Tax)")
                            Text("\(invoice.billables.first?.rate.currency ?? "") \(String(format: "%.2f", calculateTotalWithoutTax(invoice: invoice)))")
                        }
                    }
                    VStack {
                        HStack {
                            Text("Tax")
                            Text("\(invoice.billables.first?.rate.currency ?? "") \(String(format: "%.2f", calculateTax(invoice: invoice)))")
                        }
                    }
                    VStack {
                        HStack {
                            Text("Total (Including Tax)")
                            Text("\(invoice.billables.first?.rate.currency ?? "") \(String(format: "%.2f", calculateTotal(invoice: invoice)))")
                        }
                    }
                }
            }
            
            Text("Payment Details")
                .font(.headline)
            
            HStack {
                Text("\(bankDetails)")
                Spacer()
            }.padding(.bottom, 16)
        }.padding()
        
    }
    func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: date)
    }
    
    private func calculateBillable(billable : Billable) -> Double {
        let billableHelper = BillableHelper()
        var amount = 0.0
        let interval = billableHelper.numberOfSegments(for: billable.rate.timeInterval, between: billable.start, and: billable.end)
        amount = Double((interval * billable.rate.amount) / billable.rate.timeUnit)
        
        return amount
    }
    
    private func calculateTotalWithoutTax(invoice: Invoice) -> Double {
        let billableHelper = BillableHelper()
        var amount = 0.0
        
        invoice.billables.forEach { billable in
            let interval = billableHelper.numberOfSegments(for: billable.rate.timeInterval, between: billable.start, and: billable.end)
            amount += Double((interval * billable.rate.amount) / billable.rate.timeUnit)
        }
        
        return amount
    }
    
    private func calculateTax(invoice: Invoice) -> Double {
        let amount = calculateTotalWithoutTax(invoice: invoice)
        var taxAmount = 0.0
        
        if let tax = invoice.tax {
            let rate = tax.rate
            taxAmount = (amount * rate) / 100
        }
        
        return taxAmount
    }
    
    private func calculateTotal(invoice: Invoice) -> Double {
        return calculateTotalWithoutTax(invoice: invoice) + calculateTax(invoice: invoice)
    }
}

#Preview {
//    RenderedInvoicePDF()
}
