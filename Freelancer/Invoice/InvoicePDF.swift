//
//  InvoicePDF.swift
//  Freelancer
//
//  Created by John Haselden on 24/08/2025.
//

import SwiftUI
import UniformTypeIdentifiers

struct InvoicePDF: View {
    @Environment(\.defaultMinListRowHeight) var minRowHeight
    
    let pageWidth: CGFloat = 800
    
    @State private var invoice: Invoice
    @State private var project: Project
    
    @State private var companyName: String
    @State private var companyAddress: String
    @State private var bankDetails: String
    @State private var clientAddress: String

    @State private var showingExporter = false
    @State private var documentToExport: PDFDocument?
    @State private var pdfFileURL: URL?
    
    init(invoice: Invoice, project: Project, companyName: String = "", companyAddress: String = "", bankDetails: String = "") {
        self.invoice = invoice
        self.project = project
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
                
                Table(invoice.billables) {
                    TableColumn("Details", value: \.details)
                    TableColumn("Start") { billable in
                        Text(formatDate(billable.start))
                    }
                    
                    TableColumn("End") { billable in
                        Text(formatDate(billable.end))
                    }
                    
                    TableColumn("Rate") { billable in
                        Text(billable.rate.name)
                    }
                    TableColumn("Total") { billable in
                        Text("\(billable.rate.currency) \(String(format: "%.2f", calculateBillable(billable: billable)))")
                    }
                    TableColumn("Status") { billable in
                        Text(billable.status?.rawValue ?? "new")
                    }
                    
                    
                }
                .frame(minHeight: (minRowHeight * 1.3)+(minRowHeight * CGFloat(max(invoice.billables.count, 5))))
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
            
            ShareLink(item: render(invoice: invoice)) {
                Label("Export to PDF", systemImage: "document.fill")
            }
            
            Button("Save to Disk") {
                if let url = pdfFileURL, let data = try? Data(contentsOf: url) {
                    documentToExport = PDFDocument(pdfData: data)
                    showingExporter = true
                } else {
                    // Handle error if PDF file not found or data cannot be loaded
                    print("Error: Could not load PDF data from file system.")
                }
            }
        }.padding(32)
            .frame(minWidth: pageWidth, minHeight: pageWidth * sqrt(2))
            .fileExporter(
                isPresented: $showingExporter,
                document: documentToExport, //getInvoicePDFDocument(url: URL.documentsDirectory.appending(path: "Invoice.pdf")),
                contentType: .pdf,
                defaultFilename: "Invoice.pdf"
            ) { result in
                // Handle the result of the export
                if case .success = result {
                    print("Successfully saved image.")
                } else {
                    print("Failed to save image.")
                }
            }
            .onAppear {
                pdfFileURL = URL.documentsDirectory.appending(path: "Invoice.pdf")
            }
    }
    
    func render(invoice: Invoice) -> URL {
        // 1: Render Hello World with some modifiers
        let renderer = ImageRenderer(content:
                                        RenderedInvoicePDF(invoice: invoice, project: project)
        )
        
        renderer.proposedSize = ProposedViewSize(width: pageWidth, height: pageWidth * sqrt(2))
        
        // 2: Save it to our documents directory
        let url = URL.documentsDirectory.appending(path: "Invoice.pdf")
        
        print(url)
        
        // 3: Start the rendering process
        renderer.render { size, context in
            // 4: Tell SwiftUI our PDF should be the same size as the views we're rendering
            var box = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            
            // 5: Create the CGContext for our PDF pages
            guard let pdf = CGContext(url as CFURL, mediaBox: &box, nil) else {
                return
            }
            
            // 6: Start a new PDF page
            pdf.beginPDFPage(nil)
            
            // 7: Render the SwiftUI view data onto the page
            context(pdf)
            
            // 8: End the page and close the file
            pdf.endPDFPage()
            pdf.closePDF()
        }
        
        return url
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
    var project = Project(timestamp: Date(),
                         name: "Test Project One",
                         status: .won,
                         client: nil,
                         details: "It's a test project",
                         tasks: [],
                         billables: [])
    var rate = Rate(name: "Hourly Rate", amount: 100, currency: "£", timeInterval: Rate.TimeInterval.hour, timeUnit: 1, project: project)
    var invoice = Invoice(start: Date(), end: Date(), details: "This is a test Invoice",
                          project: project,
                          billables: [
                            Billable(start: Date(), end: Date(), details: "It's a billable", project: project, rate: rate)
                          ])
    
    
    
    return InvoicePDF(invoice: invoice,
                      project: Project(timestamp: Date(),
                                       name: "test project",
                                       status: .won,
                                       client: Client(timestamp: Date(),
                                                      name: "Test Client",
                                                      details: "The details",
                                                      status: .won,
                                                      address: "This is the client address",
                                                      projects: [],
                                                      tasks: []),
                                       details: "Project Details",
                                       tasks: [],
                                       billables: []),
               companyName: "SwiftCorp",
               companyAddress: "This is my company address\nIn a place\nIn another place",
               bankDetails: "Pay me here\n00-0000-00\n0000000000")
}

struct PDFDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.pdf] }
    var pdfData: Data

    init(pdfData: Data) {
        self.pdfData = pdfData
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.pdfData = data
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: pdfData)
    }
}
