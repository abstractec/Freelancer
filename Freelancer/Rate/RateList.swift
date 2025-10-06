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
    @Query private var rates: [Rate]
    
    @Environment(\.dismiss) var dismiss
    @State private var showingEditRate = false
    
    @Binding var isPresented: Bool?
    
    init (isPresented: Binding<Bool>) {
        _isPresented = Binding.constant(false)
        self.isPresented = isPresented.wrappedValue
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Text("Rates").font(.headline)
          
            ForEach(rates) { rate in
                HStack {
                    Text(rate.name).fontWeight(.bold)
                    Text("\(rate.amount)")
                    Text("\(rate.currency)")
                    Text("per")
                    Text(" \(rate.timeUnit) \(rate.timeInterval) (s)")
                    Spacer()
                    Button {
                        modelContext.delete(rate)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
            
            Button {
                showingEditRate.toggle()
            } label: {
                Label("Add", systemImage: "plus")
            }
            .sheet(isPresented: $showingEditRate, content: {
                EditRate(isPresented: $showingEditRate, rate: Rate.emptyRate)
            })
            
            
        }.padding()
    }
}

#Preview {
    RateList(isPresented: .constant(true))
        .modelContainer(ModelData.shared.modelContainer)
}
