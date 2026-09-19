//
//  RateList.swift
//  Freelancer
//
//  Created by John Haselden on 22/08/2025.
//

import SwiftUI
import SwiftData

struct RateList: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var rates: [Rate]
    @State private var showingEditRate = false
    
    var body: some View {
        NavigationStack {
            List {
                if rates.isEmpty {
                    ContentUnavailableView(
                        "No Rates",
                        systemImage: "dollarsign.circle",
                        description: Text("Add hourly or daily rates for time-based billables.")
                    )
                } else {
                    ForEach(rates) { rate in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(rate.name)
                                    .font(.headline)
                                Text("\(rate.amount) \(rate.currency) per \(rate.timeUnit) \(rate.timeInterval.rawValue)(s)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Button(role: .destructive) {
                                modelContext.delete(rate)
                            } label: {
                                Image(systemName: "trash")
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                }
            }
            .navigationTitle("Rates")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingEditRate = true
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingEditRate) {
                EditRate(isPresented: $showingEditRate, rate: Rate.emptyRate)
            }
            .frame(minWidth: 420, minHeight: 360)
        }
    }
}

#Preview {
    RateList()
        .modelContainer(ModelData.shared.modelContainer)
}
