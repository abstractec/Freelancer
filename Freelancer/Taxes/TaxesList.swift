//
//  TaxesList.swift
//  Freelancer
//
//  Created by John Haselden on 23/08/2025.
//

import SwiftUI
import SwiftData

struct TaxesList: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var taxes: [Tax]
    @State private var showingEditTax = false
    
    var body: some View {
        NavigationStack {
            List {
                if taxes.isEmpty {
                    ContentUnavailableView(
                        "No Taxes",
                        systemImage: "percent",
                        description: Text("Add tax rates to apply on invoices.")
                    )
                } else {
                    ForEach(taxes) { tax in
                        HStack {
                            Text(tax.name)
                                .font(.headline)
                            Spacer()
                            Text("\(String(format: "%.2f", tax.rate))%")
                                .foregroundStyle(.secondary)
                            Button(role: .destructive) {
                                modelContext.delete(tax)
                            } label: {
                                Image(systemName: "trash")
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                }
            }
            .navigationTitle("Taxes")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingEditTax = true
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingEditTax) {
                EditTax(isPresented: $showingEditTax, tax: Tax.emptyTax)
            }
            .frame(minWidth: 420, minHeight: 360)
        }
    }
}

#Preview {
    TaxesList()
        .modelContainer(ModelData.shared.modelContainer)
}
