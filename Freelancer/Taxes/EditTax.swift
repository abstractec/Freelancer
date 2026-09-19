//
//  EditTax.swift
//  Freelancer
//
//  Created by John Haselden on 22/08/2025.
//

import SwiftUI

struct EditTax: View {
    @Environment(\.modelContext) private var modelData
    @Environment(\.dismiss) var dismiss
    
    @Binding var isPresented: Bool
    
    @State private var tax: Tax
    @State private var name: String
    @State private var rate: String
    
    init(isPresented: Binding<Bool>, tax: Tax) {
        _isPresented = isPresented
        _tax = State(initialValue: tax)
        _name = State(initialValue: tax.name)
        _rate = State(initialValue: tax.rate == 0 ? "" : String(format: "%g", tax.rate))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                HStack {
                    TextField("Rate", text: $rate)
                        .onChange(of: rate) { _, newValue in
                            rate = sanitizedDecimal(newValue)
                        }
                    Text("%")
                        .foregroundStyle(.secondary)
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Tax")
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
                        tax.name = name
                        if let doubleValue = Double(rate) {
                            tax.rate = doubleValue
                        }
                        modelData.insert(tax)
                        isPresented = false
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .frame(minWidth: 360, minHeight: 240)
        }
    }
    
    private func sanitizedDecimal(_ value: String) -> String {
        var result = ""
        var seenDecimal = false
        for character in value {
            if character.isNumber {
                result.append(character)
            } else if character == ".", !seenDecimal {
                result.append(character)
                seenDecimal = true
            }
        }
        return result
    }
}

#Preview {
    EditTax(isPresented: .constant(true), tax: Tax.emptyTax)
}
