//
//  RenderedInvoicePDF.swift
//  Freelancer
//
//  Created by John Haselden on 24/08/2025.
//

import SwiftUI

/// Printable invoice. Values are passed in because ImageRenderer does not
/// inherit the app's SwiftData container, so @Query would come back empty.
struct RenderedInvoicePDF: View {
    let pageWidth: CGFloat = 800
    
    let companyName: String
    let companyAddress: String
    let bankDetails: String
    let clientName: String
    let clientAddress: String
    let reference: String
    let dateRange: String
    let lines: [InvoicePDFLine]
    let totalExcludingTax: String
    let tax: String
    let totalIncludingTax: String
    let logo: PlatformImage?
    
    private let pageHeight: CGFloat
    
    init(
        companyName: String,
        companyAddress: String,
        bankDetails: String,
        clientName: String,
        clientAddress: String,
        reference: String,
        dateRange: String,
        lines: [InvoicePDFLine],
        totalExcludingTax: String,
        tax: String,
        totalIncludingTax: String,
        logo: PlatformImage?
    ) {
        self.companyName = companyName
        self.companyAddress = companyAddress
        self.bankDetails = bankDetails
        self.clientName = clientName
        self.clientAddress = clientAddress
        self.reference = reference
        self.dateRange = dateRange
        self.lines = lines
        self.totalExcludingTax = totalExcludingTax
        self.tax = tax
        self.totalIncludingTax = totalIncludingTax
        self.logo = logo
        self.pageHeight = pageWidth * sqrt(2)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            
            HStack(alignment: .top, spacing: 24) {
                InvoicePartyBlock(title: "From", text: companyAddress)
                InvoicePartyBlock(title: "To", text: toText)
            }
            
            items
            
            Spacer(minLength: 16)
            
            totals
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Payment Details")
                    .font(.headline)
                Text(bankDetails)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(32)
        .frame(width: pageWidth, height: pageHeight, alignment: .top)
        .background(.white)
    }
    
    private var toText: String {
        if clientAddress.isEmpty {
            return clientName
        }
        if clientName.isEmpty {
            return clientAddress
        }
        return "\(clientName)\n\(clientAddress)"
    }
    
    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline) {
                    Text(companyName)
                        .font(.title)
                    Text("Invoice")
                        .font(.title)
                }
                
                Text("Ref: \(reference)")
                Text(dateRange)
            }
            
            Spacer()
            
            InvoiceLogoView(size: 120, image: logo)
        }
    }
    
    private var items: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Items")
                .font(.headline)
            
            Grid(alignment: .leading, horizontalSpacing: 8, verticalSpacing: 6) {
                GridRow {
                    columnTitle("Details", width: 200)
                    columnTitle("Start", width: 110)
                    columnTitle("End", width: 110)
                    columnTitle("Rate", width: 80)
                    columnTitle("Total", width: 90)
                    columnTitle("Status", width: 70)
                }
                
                Divider()
                    .gridCellColumns(6)
                
                ForEach(lines) { line in
                    GridRow(alignment: .top) {
                        wrapping(line.details, width: 200)
                        wrapping(line.start, width: 110)
                        wrapping(line.end, width: 110)
                        wrapping(line.rate, width: 80)
                        wrapping(line.total, width: 90)
                        wrapping(line.status, width: 70)
                    }
                }
            }
        }
    }
    
    private var totals: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Totals")
                .font(.headline)
            
            HStack {
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    totalRow("Total (Excluding Tax)", totalExcludingTax)
                    totalRow("Tax", tax)
                    totalRow("Total (Including Tax)", totalIncludingTax)
                }
            }
        }
    }
    
    private func columnTitle(_ title: String, width: CGFloat) -> some View {
        Text(title)
            .font(.headline)
            .frame(width: width, alignment: .leading)
    }
    
    private func wrapping(_ text: String, width: CGFloat) -> some View {
        Text(text)
            .fixedSize(horizontal: false, vertical: true)
            .frame(width: width, alignment: .leading)
    }
    
    private func totalRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
            Text(value)
        }
    }
}

struct InvoicePartyBlock: View {
    let title: String
    let text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
            Text(text)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct InvoicePDFLine: Identifiable {
    let id = UUID()
    let details: String
    let start: String
    let end: String
    let rate: String
    let total: String
    let status: String
}
