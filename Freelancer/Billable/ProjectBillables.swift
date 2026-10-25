//
//  ProjectBillables.swift
//  Freelancer
//
//  Created by John Haselden on 22/08/2025.
//

import SwiftUI
import SwiftData

struct ProjectBillables: View {
    @Environment(\.modelContext) private var modelData
    @Environment(\.dismiss) var dismiss
    
    @Binding var isPresented: Bool
    
    private let project: Project
    private let editingBillable: Billable?
    
    @State private var rates: [Rate] = []
    @State private var name: String
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var kind: BillableKind
    @State private var fixedAmountText: String
    @State private var currency: String
    @State private var selectedRate: Rate.ID?
    @State private var lineItem: String = ""
    
    init(isPresented: Binding<Bool>, project: Project, billable: Billable?) {
        _isPresented = isPresented
        self.project = project
        self.editingBillable = billable
        _name = State(initialValue: billable?.details ?? "")
        let start = billable?.start ?? Date()
        var end = billable?.end ?? Date()
        if end < start {
            end = start
        }
        _startDate = State(initialValue: start)
        _endDate = State(initialValue: end)
        _kind = State(initialValue: billable?.resolvedKind ?? .time)
        _selectedRate = State(initialValue: billable?.rate?.id)
        _currency = State(initialValue: billable?.currency ?? "")
        if let billable, billable.resolvedKind == .fixed, billable.fixedAmount != 0 {
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
                        DatePicker("Start", selection: $startDate, displayedComponents: [.date])
                            .onChange(of: startDate) { _, newValue in
                                if endDate < newValue {
                                    endDate = newValue
                                }
                                calculateBillable()
                            }
                        DatePicker("End", selection: $endDate, in: startDate..., displayedComponents: [.date])
                            .onChange(of: endDate) { _, _ in
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
                modelData.autosaveEnabled = false
                let descriptor = FetchDescriptor<Rate>(sortBy: [SortDescriptor(\Rate.name)])
                rates = (try? modelData.fetch(descriptor)) ?? []
                if currency.isEmpty, let firstRate = rates.first {
                    currency = firstRate.currency
                }
                calculateBillable()
            }
            .onDisappear {
                modelData.autosaveEnabled = true
            }
        }
    }
    
    private func calculateBillable() {
        if kind == .fixed {
            let amount = Double(fixedAmountText) ?? 0
            let currencyLabel = currency.isEmpty ? "" : "\(currency) "
            let startText = startDate.formatted(date: .abbreviated, time: .omitted)
            let endText = endDate.formatted(date: .abbreviated, time: .omitted)
            lineItem = "Fixed cost: \(currencyLabel)\(String(format: "%.2f", amount)) · \(startText) – \(endText)"
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
        let selectedTimeRate: Rate?
        if kind == .time {
            guard let selectedID = selectedRate, let rate = rates.first(where: { $0.id == selectedID }) else {
                return
            }
            selectedTimeRate = rate
        } else {
            selectedTimeRate = nil
        }
        
        let billable: Billable
        if let editingBillable {
            billable = editingBillable
        } else {
            billable = Billable(
                start: startDate,
                end: endDate,
                details: name,
                project: project
            )
            modelData.insert(billable)
        }
        
        billable.start = startDate
        billable.end = endDate
        billable.details = name
        billable.project = project
        billable.resolvedKind = kind
        if billable.status == nil {
            billable.status = .new
        }
        
        switch kind {
        case .fixed:
            billable.fixedAmount = Double(fixedAmountText) ?? 0
            billable.currency = currency
            billable.rate = nil
        case .time:
            billable.fixedAmount = 0
            billable.rate = selectedTimeRate
            billable.currency = selectedTimeRate?.currency ?? currency
        }
        
        if !project.billables.contains(where: { $0.persistentModelID == billable.persistentModelID }) {
            project.billables.append(billable)
        }
        
        try? modelData.save()
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
    ProjectBillables(isPresented: .constant(true), project: Project.emptyProject, billable: nil)
}
