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

    @Binding var isPresented: Bool?

    @State private var project: Project = Project.emptyProject
    @State private var billable: Billable = Billable.emptyBillable

    @State private var name: String
    @State private var startDate: Date = Date.now
    @State private var endDate: Date = Date.now
    @State private var kind: BillableKind = .time
    @State private var fixedAmountText: String = ""
    @State private var currency: String = ""
    
    @State private var selectedRate: Rate.ID?
    
    @State private var lineItem: String = ""

    init(isPresented: Binding<Bool>, project: Project, billable: Billable) {
        self.project = project
        self.billable = billable
        
        self.name = billable.details
        self.startDate = billable.start
        self.endDate = billable.end
        self.kind = billable.kind
        self.selectedRate = billable.rate?.id
        self.currency = billable.currency
        if billable.kind == .fixed, billable.fixedAmount != 0 {
            self.fixedAmountText = String(format: "%g", billable.fixedAmount)
        }
        
        _isPresented = Binding.constant(false)
        self.isPresented = isPresented.wrappedValue        
    }
    
    private var canSave: Bool {
        switch kind {
        case .time:
            return selectedRate != nil
        case .fixed:
            return Double(fixedAmountText) != nil
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Billable for \(self.project.name)")
                .font(.headline)
            
            Picker("Type", selection: $kind) {
                ForEach(BillableKind.allCases) { option in
                    Text(option.label).tag(option)
                }
            }
            .pickerStyle(.segmented)
            .padding(.vertical, 8)
            .onChange(of: kind) {
                calculateBillable()
            }
            
            TextField(
                "Details",
                text: $name)
            .textFieldStyle(.roundedBorder)
            .onChange(of: name) {
                calculateBillable()
            }
            
            if kind == .fixed {
                DatePicker(
                    "Date",
                    selection: $startDate,
                    displayedComponents: [.date]
                )
                .onChange(of: startDate) {
                    calculateBillable()
                }
                
                HStack {
                    TextField(
                        "Amount",
                        text: $fixedAmountText
                    )
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: fixedAmountText) { _, newValue in
                        let filtered = sanitizedDecimal(newValue)
                        if filtered != newValue {
                            fixedAmountText = filtered
                        }
                        calculateBillable()
                    }
                    
                    TextField(
                        "Currency",
                        text: $currency
                    )
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 120)
                    .onChange(of: currency) {
                        calculateBillable()
                    }
                }
            } else {
                DatePicker(
                    "Start Date",
                    selection: $startDate,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .onChange(of: startDate) {
                    calculateBillable()
                }
                
                DatePicker(
                    "End Date",
                    selection: $endDate,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .onChange(of: endDate) {
                    calculateBillable()
                }
                
                Text("Rate").font(.headline)

                List(rates, selection: $selectedRate) { rate in
                    HStack {
                        Text(rate.name)
                        if (rate.id == selectedRate) {
                            Label("Selected", systemImage: "checkmark.diamond.fill")
                        }
                    }
                }
                .navigationTitle("Single Selection List")
                .frame(minHeight: minRowHeight * 3)
                .onChange(of: selectedRate) {
                    calculateBillable()
                }
            }
            
            Text("Here we do the maths").font(.subheadline)
            Text(lineItem)

            HStack {
                Spacer()
                Button(action: {
                    isPresented = false
                    dismiss()
                }, label: {
                    Text("Cancel")
                }).padding(.trailing, 8)
                
                Button(action: {
                    saveBillable()
                }, label: {
                    Text("Save")
                })
                .disabled(!canSave)
                .padding(.trailing, 8)
                Spacer()

            }

        }.padding()
            .onAppear {
                if currency.isEmpty, let firstRate = rates.first {
                    currency = firstRate.currency
                }
                calculateBillable()
            }
    }
    
    func calculateBillable() {
        if kind == .fixed {
            let amount = Double(fixedAmountText) ?? 0
            let currencyLabel = currency.isEmpty ? "" : "\(currency) "
            lineItem = "--- Fixed cost: \(currencyLabel)\(String(format: "%.2f", amount))"
            return
        }
        
        if let selectedID = $selectedRate.wrappedValue, let rate = rates.first(where: { $0.id == selectedID }) {
            let billableHelper = BillableHelper()
            
            let interval = billableHelper.numberOfSegments(for: rate.timeInterval, between: self.startDate, and: self.endDate)

            var units = 0;

            if (rate.timeUnit == 0) {
                units = (interval * rate.amount)
            } else {
                units = ((interval * rate.amount) / rate.timeUnit)
            }
            
            lineItem = "--- \(interval) \(rate.timeInterval.rawValue)s at \(rate.amount) \(rate.currency) = \(units)"
        }
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
    ProjectBillables(isPresented: .constant(false), project: Project.emptyProject, billable: Billable.emptyBillable)
}
