//
//  EditRate.swift
//  Freelancer
//
//  Created by John Haselden on 22/08/2025.
//

import SwiftUI

struct EditRate: View {
    @Environment(\.modelContext) private var modelData
    @Environment(\.dismiss) var dismiss
    
    @Binding var isPresented: Bool
    
    @State private var rate: Rate
    @State private var name: String
    @State private var amount: String
    @State private var currency: String
    @State private var timeInterval: Rate.TimeInterval
    @State private var timeUnit: String
    
    init(isPresented: Binding<Bool>, rate: Rate) {
        _isPresented = isPresented
        _rate = State(initialValue: rate)
        _name = State(initialValue: rate.name)
        _amount = State(initialValue: rate.amount > 0 ? "\(rate.amount)" : "")
        _currency = State(initialValue: rate.currency)
        _timeInterval = State(initialValue: rate.timeInterval)
        _timeUnit = State(initialValue: rate.timeUnit > 0 ? "\(rate.timeUnit)" : "")
    }
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                TextField("Amount", text: $amount)
                    .onChange(of: amount) { _, newValue in
                        amount = newValue.filter(\.isNumber)
                    }
                TextField("Currency", text: $currency)
                TextField("Time Unit", text: $timeUnit)
                    .onChange(of: timeUnit) { _, newValue in
                        timeUnit = newValue.filter(\.isNumber)
                    }
                Picker("Time Interval", selection: $timeInterval) {
                    ForEach(Rate.TimeInterval.allCases) { option in
                        Text(String(describing: option).capitalized).tag(option)
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Billable Rate")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        modelData.rollback()
                        isPresented = false
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        rate.name = name
                        rate.amount = Int(amount) ?? 0
                        rate.currency = currency
                        rate.timeUnit = Int(timeUnit) ?? 0
                        rate.timeInterval = timeInterval
                        modelData.insert(rate)
                        isPresented = false
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .frame(minWidth: 420, minHeight: 360)
        }
    }
}

#Preview {
    EditRate(isPresented: .constant(true), rate: Rate.emptyRate)
}
