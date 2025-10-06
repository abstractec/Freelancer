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
    
    @Binding var isPresented: Bool?
    
    @State var refresh: Bool = false
    @State var textEditorHeight : CGFloat = 40
    
    func update() {
        refresh.toggle()
    }
    
    @State private var rate: Rate = Rate.emptyRate
    
    @State private var name: String
    @State private var amount: String
    @State private var currency: String
    @State private var timeInterval: Rate.TimeInterval
    @State private var timeUnit: String
        
    init (isPresented: Binding<Bool>, rate: Rate) {
        self.rate = rate
        self.name = rate.name
        
        if (rate.amount > 0) {
            self.amount = "\(rate.amount)"
        } else {
            self.amount = ""
        }
        
        self.currency = rate.currency
        self.timeInterval = rate.timeInterval

        if (rate.timeUnit > 0) {
            self.timeUnit = "\(rate.timeUnit)"
        } else {
            self.timeUnit = ""
        }
        
        _isPresented = Binding.constant(false)
        self.isPresented = isPresented.wrappedValue
    }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text("Billable Rate").bold()
                TextField(
                    "Name",
                    text: $name).textFieldStyle(.roundedBorder)
                
                TextField(
                    "Amount",
                    text: $amount).textFieldStyle(.roundedBorder)
                    .onChange(of: amount) { oldValue, newValue in
                        let filtered = newValue.filter { $0.isNumber }
                        if filtered != newValue {
                            amount = filtered
                        }
                    }

                TextField(
                    "Currency",
                    text: $currency).textFieldStyle(.roundedBorder)
                  
                Text("Per").padding(8)
                
                HStack {
                    TextField(
                        "Time Unit",
                        text: $timeUnit).textFieldStyle(.roundedBorder)
                        .onChange(of: timeUnit) { oldValue, newValue in
                            let filtered = newValue.filter { $0.isNumber }
                            if filtered != newValue {
                                timeUnit = filtered
                            }
                        }
                    
                    Picker("Time Interval", selection: $timeInterval) {
                        ForEach(Rate.TimeInterval.allCases) { option in
                            Text(String(describing: option).capitalized)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Text("(s)")
                }
            }
            .padding()
        }
        .safeAreaInset(edge: .bottom) {
            VStack(alignment: .trailing, content: {
                HStack {
                    Button(action: {
                        modelData.rollback()
                        isPresented = false
                        dismiss()
                    }, label: {
                        Text("Cancel")
                    })
                    
                    Button(action: {                       
                        rate.name = name
                        rate.amount = Int(amount) ?? 0
                        rate.currency = currency
                        rate.timeUnit = Int(timeUnit) ?? 0
                        rate.timeInterval = timeInterval
                        
                        print("inserting??")
                                                
                        modelData.insert(rate)
                        
                        isPresented = false
                        
                        dismiss()
                    }, label: {
                        Text("Save")
                    })

                }
            }).padding(.bottom, 16)

        }
    }
}

#Preview {
    EditRate(isPresented: .constant(true), rate: Rate.emptyRate)
}
