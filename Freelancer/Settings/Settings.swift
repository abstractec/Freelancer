//
//  Settings.swift
//  Freelancer
//
//  Created by John Haselden on 23/08/2025.
//

import SwiftUI
import UniformTypeIdentifiers

struct AppSettingsView: View {
    @State private var showingRateList = false
    @State private var showingTaxesList = false
    @State private var showingLogoPicker = false
    @State private var logoRevision = 0
    
    @State private var companyName: String = UserDefaults.standard.string(forKey: "companyName") ?? ""
    @State private var address: String = UserDefaults.standard.string(forKey: "address") ?? ""
    @State private var bankDetails: String = UserDefaults.standard.string(forKey: "bankDetails") ?? ""
    @State private var sequence: String = UserDefaults.standard.string(forKey: "sequence") ?? "0"
    
    var body: some View {
        Form {
            Section("Company") {
                TextField("Company Name", text: $companyName)
                    .onChange(of: companyName) { _, newValue in
                        UserDefaults.standard.set(newValue, forKey: "companyName")
                    }
                
                TextField("Address", text: $address, axis: .vertical)
                    .lineLimit(3...6)
                    .onChange(of: address) { _, newValue in
                        UserDefaults.standard.set(newValue, forKey: "address")
                    }
                
                TextField("Bank Details", text: $bankDetails, axis: .vertical)
                    .lineLimit(3...6)
                    .onChange(of: bankDetails) { _, newValue in
                        UserDefaults.standard.set(newValue, forKey: "bankDetails")
                    }
                
                TextField("Invoice Sequence", text: $sequence)
                    .onChange(of: sequence) { _, newValue in
                        let filtered = newValue.filter(\.isNumber)
                        sequence = filtered
                        UserDefaults.standard.set(filtered, forKey: "sequence")
                    }
            }
            
            Section {
                HStack(alignment: .center, spacing: 16) {
                    InvoiceLogoView(size: 72, showsPlaceholder: true)
                        .id(logoRevision)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Button(CompanyLogoStore.hasLogo ? "Replace Logo…" : "Upload Logo…") {
                            showingLogoPicker = true
                        }
                        if CompanyLogoStore.hasLogo {
                            Button("Remove Logo", role: .destructive) {
                                CompanyLogoStore.remove()
                                logoRevision += 1
                            }
                        }
                    }
                }
            } header: {
                Text("Invoice Logo")
            } footer: {
                Text("Shown in the top-right of invoices and exported PDFs.")
            }
            
            Section("Catalog") {
                Button {
                    showingRateList = true
                } label: {
                    Label("Rates", systemImage: "dollarsign.circle")
                }
                Button {
                    showingTaxesList = true
                } label: {
                    Label("Taxes", systemImage: "percent")
                }
            }
        }
        .formStyle(.grouped)
        .padding()
        .frame(minWidth: 480, minHeight: 420)
        .fileImporter(
            isPresented: $showingLogoPicker,
            allowedContentTypes: [.png, .jpeg, .webP],
            allowsMultipleSelection: false
        ) { result in
            if case .success(let urls) = result, let url = urls.first {
                do {
                    try CompanyLogoStore.save(from: url)
                    logoRevision += 1
                } catch {
                    print("Could not save logo: \(error)")
                }
            }
        }
        .sheet(isPresented: $showingRateList) {
            RateList()
        }
        .sheet(isPresented: $showingTaxesList) {
            TaxesList()
        }
    }
}

#Preview {
    AppSettingsView()
        .modelContainer(ModelData.shared.modelContainer)
}
