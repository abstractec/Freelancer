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
    
    @State private var selectedRate: Rate.ID?
    
    @State private var lineItem: String = ""

    init(isPresented: Binding<Bool>, project: Project, billable: Billable) {
        self.project = project
        self.billable = billable
        
        self.name = billable.details
        self.startDate = billable.start
        self.endDate = billable.end
        self.selectedRate = billable.rate.id
        
        _isPresented = Binding.constant(false)
        self.isPresented = isPresented.wrappedValue        
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Billable for \(self.project.name)")
                .font(.headline)
            
            TextField(
                "Details",
                text: $name)
            .textFieldStyle(.roundedBorder)
            .onChange(of: name) {
                calculateBillable()
            }
            
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
                    // make the billable
                    if let selectedID = $selectedRate.wrappedValue, let rate = rates.first(where: { $0.id == selectedID }) {
                        let billable = Billable(start: startDate, end: endDate, details: name, project: project, rate: rate)
                        modelData.insert(billable)
                        
                        dismiss()
                    }
                    
                    isPresented = false
                }, label: {
                    Text("Save")
                }).padding(.trailing, 8)
                Spacer()

            }

        }.padding()
            .onAppear {
                calculateBillable()
            }
    }
    
    func calculateBillable() {
        if let selectedID = $selectedRate.wrappedValue, let rate = rates.first(where: { $0.id == selectedID }) {
            let billableHelper = BillableHelper()
            
            let interval = billableHelper.numberOfSegments(for: rate.timeInterval, between: self.startDate, and: self.endDate)
            
            let units = ((interval * rate.amount) / rate.timeUnit)

            lineItem = "\(interval) \(rate.timeInterval.rawValue)s at \(rate.amount) \(rate.currency) = \(units)"
        }
    }
}

#Preview {
    ProjectBillables(isPresented: .constant(false), project: Project.emptyProject, billable: Billable.emptyBillable)
}
