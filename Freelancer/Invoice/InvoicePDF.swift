//
//  InvoicePDF.swift
//  Freelancer
//
//  Created by John Haselden on 24/08/2025.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct InvoicePDF: View {
    @Environment(\.defaultMinListRowHeight) var minRowHeight
    @Environment(\.modelContext) private var modelContext
    @Query private var allSettings: [UserSettings]
    
    let pageWidth: CGFloat = 800
    
    @State private var invoice: Invoice
    @State private var project: Project
    
    @State private var clientName: String
    @State private var clientAddress: String
    @State private var dateRange: String

    @State private var showingExporter = false
    @State private var documentToExport: PDFDocument?
    @State private var pdfFileURL: URL?
    
    @State private var invoiceBillables: [Billable] = []
    
    private var settings: UserSettings {
        allSettings.first ?? UserSettingsStore.shared(in: modelContext)
    }
    
    init(invoice: Invoice, project: Project, companyName: String = "", companyAddress: String = "", bankDetails: String = "") {
        let orderedBillables = invoice.billables.sorted { $0.start < $1.start }
        let dateRange: String
        if let first = orderedBillables.first, let last = orderedBillables.last {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            dateRange = "Date Range: \(dateFormatter.string(from: first.start)) to \(dateFormatter.string(from: last.end))"
        } else {
            dateRange = "wango"
        }

        self._invoice = State(initialValue: invoice)
        self._project = State(initialValue: project)
        self._clientAddress = State(initialValue: project.client?.address ?? "")
        self._clientName = State(initialValue: project.client?.name ?? "")
        self._dateRange = State(initialValue: dateRange)
        self._invoiceBillables = State(initialValue: orderedBillables)
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
                    Text("\(self.dateRange)")
                }
                
                Spacer()
                
                InvoiceLogoView(size: 120, settings: settings)
            }
            .padding(.bottom, 16)


            
            HStack(alignment: .top, spacing: 24) {
                InvoicePartyBlock(title: "From", text: settings.address)
                InvoicePartyBlock(title: "To", text: toText)
            }
            .padding(.bottom, 16)
            
            
            VStack(alignment: .leading) {
                Text("Items")
                    .font(.headline)
                
                Table(self.invoiceBillables) {
                    TableColumn("Details", value: \.details)
                    TableColumn("Start") { billable in
                        Text(formatDate(billable.start, includeTime: billable.resolvedKind != .fixed))
                    }
                    
                    TableColumn("End") { billable in
                        Text(formatDate(billable.end, includeTime: billable.resolvedKind != .fixed))
                    }
                    
                    TableColumn("Rate") { billable in
                        Text(BillableHelper().rateLabel(for: billable))
                    }
                    TableColumn("Total") { billable in
                        Text(BillableHelper().formattedAmount(for: billable))
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
            
            Text(settings.bankDetails)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 16)
            
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
    
    private var toText: String {
        if clientAddress.isEmpty {
            return clientName
        }
        if clientName.isEmpty {
            return clientAddress
        }
        return "\(clientName)\n\(clientAddress)"
    }
    
    func render(invoice: Invoice) -> URL {
        let renderer = ImageRenderer(content: renderedPage(for: invoice))
        
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
    
    private func renderedPage(for invoice: Invoice) -> RenderedInvoicePDF {
        let helper = BillableHelper()
        let ordered = invoice.billables.sorted { $0.start < $1.start }
        let lines = ordered.map { billable in
            InvoicePDFLine(
                details: billable.details,
                start: formatDate(billable.start, includeTime: billable.resolvedKind != .fixed),
                end: formatDate(billable.end, includeTime: billable.resolvedKind != .fixed),
                rate: helper.rateLabel(for: billable),
                total: helper.formattedAmount(for: billable),
                status: billable.status?.rawValue ?? "new"
            )
        }
        
        let currency = invoiceCurrency(invoice)
        let excluding = calculateTotalWithoutTax(invoice: invoice)
        let taxAmount = calculateTax(invoice: invoice)
        
        return RenderedInvoicePDF(
            companyName: settings.companyName,
            companyAddress: settings.address,
            bankDetails: settings.bankDetails,
            clientName: clientName,
            clientAddress: clientAddress,
            reference: String(format: "%08d", invoice.sequence ?? 0),
            dateRange: dateRange,
            lines: lines,
            totalExcludingTax: "\(currency) \(String(format: "%.2f", excluding))",
            tax: "\(currency) \(String(format: "%.2f", taxAmount))",
            totalIncludingTax: "\(currency) \(String(format: "%.2f", excluding + taxAmount))",
            logo: CompanyLogoStore.loadImage(from: settings)
        )
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
