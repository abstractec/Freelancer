//
//  EditRate.swift
//  Freelancer
//
//  Created by John Haselden on 22/08/2025.
//

import SwiftUI

struct EditTax: View {
    @Environment(\.modelContext) private var modelData
    @Environment(\.dismiss) var dismiss
    
    @Binding var isPresented: Bool?
    
    @State var refresh: Bool = false
    @State var textEditorHeight : CGFloat = 40
    
    func update() {
        refresh.toggle()
    }
    
    @State private var tax: Tax = Tax.emptyTax
    
    @State private var name: String
    @State private var rate: String
        
    init (isPresented: Binding<Bool>, tax: Tax) {
        self.tax = tax
        self.name = tax.name
        self.rate = "\(tax.rate)"
        
        _isPresented = Binding.constant(false)
        self.isPresented = isPresented.wrappedValue
    }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text("Tax").bold()
                TextField(
                    "Name",
                    text: $name).textFieldStyle(.roundedBorder)
                
                HStack {
                    TextField(
                        "Rate",
                        text: $rate).textFieldStyle(.roundedBorder)
                        .onChange(of: rate) { oldValue, newValue in
                            let filtered = newValue.filter { $0.isNumber }
                            if filtered != newValue {
                                rate = filtered
                            }
                        }
                    Text("%")
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
                        tax.name = name
                        if let doubleValue = Double(rate) {
                            tax.rate = doubleValue
                        }
                                                
                        modelData.insert(tax)
                        
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
