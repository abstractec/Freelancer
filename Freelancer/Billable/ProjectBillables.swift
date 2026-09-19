//
//  ProjectBillables.swift
//  Freelancer
//
//  Created by John Haselden on 22/08/2025.
//

import SwiftUI
import SwiftData

struct ProjectBillables: View {
    @Environment(\.defaultMinListRowHeight) var minRowHeight
    @Environment(\.modelContext) private var modelData
    @Environment(\.dismiss) var dismiss
    @Query(sort: \Rate.name) private var rates: [Rate]
    
    @Binding var isPresented: Bool
    
    @State private var project: Project
    @State private var name: String
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var kind: BillableKind
    @State private var fixedAmountText: String
    @State private var currency: String
    @State private var selectedRate: Rate.ID?
    @State private var lineItem: String = ""
    
    init(isPresented: Binding<Bool>, project: Project, billable: Billable) {
        _isPresented = isPresented
        _project = State(initialValue: project)
        _name = State(initialValue: billable.details)
        _startDate = State(initialValue: billable.start)
        _endDate = State(initialValue: billable.end)
        _kind = State(initialValue: billable.kind)
        _selectedRate = State(initialValue: billable.rate?.id)
        _currency = State(initialValue: billable.currency)
        if billable.kind == .fixed, billable.fixedAmount != 0 {
            _fixedAmountText = State(initialValue: String(format: "%g", billable.fixedAmount))
        } else {
            _fixedAmountText = State(initialValue: "")
        }
    }
    
    private var canSave: Bool {
        switch kind {
        case .time:
            return selectedRate != nil && !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .fixed:
            return Double(fixedAmountText) != nil && !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Type", selection: $kind) {
                        ForEach(BillableKind.allCases) { option in
                            Text(option.label).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: kind) { _, _ in
                        calculateBillable()
                    }
                    
                    TextField("Details", text: $name)
                        .onChange(of: name) { _, _ in
                            calculateBillable()
                        }
                }
                
                if kind == .fixed {
                    Section("Fixed cost") {
                        DatePicker("Date", selection: $startDate, displayedComponents: [.date])
                            .onChange(of: startDate) { _, _ in
                                calculateBillable()
                            }
                        TextField("Amount", text: $fixedAmountText)
                            .onChange(of: fixedAmountText) { _, newValue in
                                fixedAmountText = sanitizedDecimal(newValue)
                                calculateBillable()
                            }
                        TextField("Currency", text: $currency)
                            .onChange(of: currency) { _, _ in
                                calculateBillable()
                            }
                    }
                } else {
                    Section("Time") {
                        DatePicker("Start", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                            .onChange(of: startDate) { _, _ in
                                calculateBillable()
                            }
                        DatePicker("End", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
                            .onChange(of: endDate) { _, _ in
                                calculateBillable()
                            }
                        
                        Picker("Rate", selection: $selectedRate) {
                            Text("Select a rate").tag(Rate.ID?.none)
                            ForEach(rates) { rate in
                                Text("\(rate.name) — \(rate.amount) \(rate.currency)").tag(Optional(rate.id))
                            }
                        }
                        .onChange(of: selectedRate) { _, _ in
                            calculateBillable()
                        }
                    }
                }
                
                if !lineItem.isEmpty {
                    Section("Preview") {
                        Text(lineItem)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Billable")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveBillable()
                    }
                    .disabled(!canSave)
                }
            }
            .frame(minWidth: 480, minHeight: 480)
            .onAppear {
                if currency.isEmpty, let firstRate = rates.first {
                    currency = firstRate.currency
                }
                calculateBillable()
            }
        }
    }
    
    private func calculateBillable() {
        if kind == .fixed {
            let amount = Double(fixedAmountText) ?? 0
            let currencyLabel = currency.isEmpty ? "" : "\(currency) "
            lineItem = "Fixed cost: \(currencyLabel)\(String(format: "%.2f", amount))"
            return
        }
        
        guard let selectedID = selectedRate,
              let rate = rates.first(where: { $0.id == selectedID }) else {
            lineItem = ""
            return
        }
        
        let billableHelper = BillableHelper()
        let interval = billableHelper.numberOfSegments(for: rate.timeInterval, between: startDate, and: endDate)
        let units: Int
        if rate.timeUnit == 0 {
            units = interval * rate.amount
        } else {
            units = (interval * rate.amount) / rate.timeUnit
        }
        lineItem = "\(interval) \(rate.timeInterval.rawValue)s at \(rate.amount) \(rate.currency) = \(units)"
    }
    
    private func saveBillable() {
        switch kind {
        case .fixed:
            let amount = Double(fixedAmountText) ?? 0
            let billable = Billable(
                start: startDate,
                end: startDate,
                details: name,
                project: project,
                kind: .fixed,
                fixedAmount: amount,
                currency: currency
            )
            modelData.insert(billable)
        case .time:
            guard let selectedID = selectedRate, let rate = rates.first(where: { $0.id == selectedID }) else {
                return
            }
            let billable = Billable(
                start: startDate,
                end: endDate,
                details: name,
                project: project,
                rate: rate,
                kind: .time
            )
            modelData.insert(billable)
        }
        
        isPresented = false
        dismiss()
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
    ProjectBillables(isPresented: .constant(true), project: Project.emptyProject, billable: Billable.emptyBillable)
}
