//
//  RenderedInvoicePDF.swift
//  Freelancer
//
//  Created by John Haselden on 24/08/2025.
//

import SwiftUI
import SwiftData

struct RenderedInvoicePDF: View {
    @Environment(\.defaultMinListRowHeight) var minRowHeight
    @Environment(\.modelContext) private var modelContext
    @Query private var allSettings: [UserSettings]
    
    let pageWidth: CGFloat = 800
    
    @State private var invoice: Invoice
    @State private var clientAddress: String
    @State private var clientName: String
    
    private var settings: UserSettings {
        allSettings.first ?? UserSettingsStore.shared(in: modelContext)
    }

    init(invoice: Invoice, project: Project, companyName: String = "", companyAddress: String = "", bankDetails: String = "") {
        self.invoice = invoice
        self.clientAddress = project.client?.address ?? ""
        self.clientName = project.client?.name ?? ""
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(settings.companyName)
                            .font(.title)
                        Text("Invoice").font(.title)
                    }
                    
                    Text("Ref: \(String(format: "%08d", (invoice.sequence ?? 0)))")
                }
                
                Spacer()
                
                InvoiceLogoView(size: 120, settings: settings)
            }
            .padding(.bottom, 16)
            
            HStack {
                Text("From:\n\(settings.address)")
                Spacer()
                Text("To:\n\(clientName)\n\(clientAddress)")
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
                    ForEach(invoice.billables.sorted{$0.start < $1.start }) { billable in
                        GridRow {
                            Text(billable.details).gridCellAnchor(.leading)
                            Text(formatDate(billable.start, includeTime: billable.resolvedKind != .fixed)).gridCellAnchor(.leading)
                            Text(billable.resolvedKind == .fixed ? "—" : formatDate(billable.end)).gridCellAnchor(.leading)
                            Text(BillableHelper().formattedAmount(for: billable)).gridCellAnchor(.leading)
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
                            Text("\(invoiceCurrency(invoice)) \(String(format: "%.2f", calculateTotalWithoutTax(invoice: invoice)))")
                        }
                    }
                    VStack {
                        HStack {
                            Text("Tax")
                            Text("\(invoiceCurrency(invoice)) \(String(format: "%.2f", calculateTax(invoice: invoice)))")
                        }
                    }
                    VStack {
                        HStack {
                            Text("Total (Including Tax)")
                            Text("\(invoiceCurrency(invoice)) \(String(format: "%.2f", calculateTotal(invoice: invoice)))")
                        }
                    }
                }
            }
            
            Text("Payment Details")
                .font(.headline)
            
            HStack {
                Text("\(settings.bankDetails)")
                Spacer()
            }.padding(.bottom, 16)
        }.padding()
        
    }
    func formatDate(_ date: Date, includeTime: Bool = true) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = includeTime ? .short : .none
        return dateFormatter.string(from: date)
    }
    
    private func invoiceCurrency(_ invoice: Invoice) -> String {
        BillableHelper().currency(for: invoice.billables)
    }
    
    private func calculateTotalWithoutTax(invoice: Invoice) -> Double {
        let billableHelper = BillableHelper()
        return invoice.billables.reduce(0) { $0 + billableHelper.amount(for: $1) }
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
