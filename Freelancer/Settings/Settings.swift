//
//  Settings.swift
//  Freelancer
//
//  Created by John Haselden on 23/08/2025.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct AppSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allSettings: [UserSettings]
    
    @State private var showingRateList = false
    @State private var showingTaxesList = false
    @State private var showingLogoPicker = false
    @State private var logoRevision = 0
    @State private var sequenceDraft = ""
    
    private var settings: UserSettings {
        if let existing = allSettings.first {
            return existing
        }
        return UserSettingsStore.shared(in: modelContext)
    }
    
    var body: some View {
        Form {
            Section {
                TextField("Company Name", text: binding(\.companyName))
                TextField("Address", text: binding(\.address), axis: .vertical)
                    .lineLimit(3...6)
                TextField("Bank Details", text: binding(\.bankDetails), axis: .vertical)
                    .lineLimit(3...6)
                TextField("Next invoice number", text: $sequenceDraft)
                    .onChange(of: sequenceDraft) { _, newValue in
                        let filtered = newValue.filter(\.isNumber)
                        if filtered != newValue {
                            sequenceDraft = filtered
                            return
                        }
                        if let value = Int(filtered) {
                            settings.invoiceSequence = value
                        }
                    }
            } header: {
                Text("Company")
            } footer: {
                Text("Next invoice number is assigned to a new invoice. To put a number on an invoice you already saved, edit that invoice and use Use next number.")
            }
            
            Section {
                HStack(alignment: .center, spacing: 16) {
                    InvoiceLogoView(size: 72, showsPlaceholder: true, settings: settings)
                        .id(logoRevision)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Button(settings.hasLogo ? "Replace Logo…" : "Upload Logo…") {
                            showingLogoPicker = true
                        }
                        if settings.hasLogo {
                            Button("Remove Logo", role: .destructive) {
                                CompanyLogoStore.remove(from: settings)
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
            
            Section {
                Text("Data is stored on this device. Mac ↔ iPhone sync needs a paid Apple Developer Program membership and CloudKit (see README).")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        #if os(macOS)
        .padding()
        .frame(minWidth: 480, minHeight: 420)
        #endif
        .navigationTitle("Settings")
        .fileImporter(
            isPresented: $showingLogoPicker,
            allowedContentTypes: [.png, .jpeg, .webP],
            allowsMultipleSelection: false
        ) { result in
            if case .success(let urls) = result, let url = urls.first {
                do {
                    try CompanyLogoStore.save(from: url, into: settings)
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
        .onAppear {
            let stored = UserSettingsStore.shared(in: modelContext)
            sequenceDraft = "\(stored.invoiceSequence)"
        }
    }
    
    private func binding(_ keyPath: ReferenceWritableKeyPath<UserSettings, String>) -> Binding<String> {
        Binding(
            get: { settings[keyPath: keyPath] },
            set: { settings[keyPath: keyPath] = $0 }
        )
    }
    
}

#Preview {
    AppSettingsView()
        .modelContainer(ModelData.shared.modelContainer)
}
