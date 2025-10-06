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
    @Query private var taxes: [Tax]
    
    @Environment(\.dismiss) var dismiss
    @State private var showingEditTax = false
    
    @Binding var isPresented: Bool?
    
    init (isPresented: Binding<Bool>) {
        _isPresented = Binding.constant(false)
        self.isPresented = isPresented.wrappedValue
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Text("Taxes").font(.headline)
          
            ForEach(taxes) { tax in
                HStack {
                    Text(tax.name).fontWeight(.bold)
                    Text("\(tax.rate) %")
                    Spacer()
                    Button {
                        modelContext.delete(tax)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
            
            Button {
                showingEditTax.toggle()
            } label: {
                Label("Add", systemImage: "plus")
            }
            .sheet(isPresented: $showingEditTax, content: {
                EditTax(isPresented: $showingEditTax, tax: Tax.emptyTax)
            })
            
            
        }.padding()
    }}

#Preview {
    TaxesList(isPresented: .constant(true))
        .modelContainer(ModelData.shared.modelContainer)
}
