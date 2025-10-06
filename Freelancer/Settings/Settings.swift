//
//  Settings.swift
//  Freelancer
//
//  Created by John Haselden on 23/08/2025.
//

import SwiftUI

struct Settings: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    @State var textEditorHeight : CGFloat = 60

    @Binding var isPresented: Bool?

    @State private var showingRateList = false
    @State private var showingTaxesList = false

    @State private var companyName: String
    @State private var address: String
    @State private var bankDetails: String
    @State private var sequence: String

    init (isPresented: Binding<Bool>) {
        companyName = UserDefaults.standard.string(forKey: "companyName") ?? ""
        address = UserDefaults.standard.string(forKey: "address") ?? ""
        bankDetails = UserDefaults.standard.string(forKey: "bankDetails") ?? ""
        sequence = UserDefaults.standard.string(forKey: "sequence") ?? "0"
        
        _isPresented = Binding.constant(false)
        self.isPresented = isPresented.wrappedValue
    }

    var body: some View {
        VStack(alignment: .leading) {
            
            Text("Settings").font(.headline).padding(.bottom, 8)
            Text("Company Name").fontWeight(.bold)
            TextField(
                "Company Name",
                text: $companyName).textFieldStyle(.roundedBorder)
                .onChange(of: companyName) {
                    saveCompanyName(companyName)
                }

            Text("Address").fontWeight(.bold)
            TextEditor(
                text: $address).textFieldStyle(.roundedBorder).frame(height: max(40,textEditorHeight))
                .onChange(of: address) {
                    saveAddress(address)
                }
            
            Text("Bank Details").fontWeight(.bold)
            TextEditor(
                text: $bankDetails).textFieldStyle(.roundedBorder).frame(height: max(40,textEditorHeight))
                .onChange(of: bankDetails) {
                    saveBankDetails(bankDetails)
                }
            
            Text("Current Invoice Sequence").fontWeight(.bold)
            TextField(
                "Sequence",
                text: $sequence).textFieldStyle(.roundedBorder)
                .onChange(of: sequence) { oldValue, newValue in
                    let filtered = newValue.filter { $0.isNumber }
                    saveSequence(filtered)
                    sequence = filtered
                }

            HStack {
                Text("Rates").fontWeight(.bold)
                Spacer()
                Button {
                    showingRateList.toggle()
                } label: {
                    Label("Show", systemImage: "bahtsign.bank.building")
                }.sheet(isPresented: $showingRateList, content: {
                    RateList(isPresented: $showingRateList)
                })

            }.padding(.vertical)

            HStack {
                Text("Taxes").fontWeight(.bold)
                Spacer()
                Button {
                    showingTaxesList.toggle()
                } label: {
                    Label("Show", systemImage: "bahtsign.bank.building.fill")
                }.sheet(isPresented: $showingTaxesList, content: {
                    TaxesList(isPresented: $showingTaxesList)
                })

            }.padding(.vertical)


            HStack {
                Spacer()
                Button("Close") {
                    dismiss()
                    self.isPresented = false
                }
                Spacer()
            }
        }.padding()
    }
    
    private func saveCompanyName(_ companyName: String) {
        UserDefaults.standard.set(companyName, forKey: "companyName")
    }
    
    private func saveAddress(_ address: String) {
        UserDefaults.standard.set(address, forKey: "address")
    }

    private func saveBankDetails(_ bankDetails: String) {
        UserDefaults.standard.set(bankDetails, forKey: "bankDetails")
    }
    

    private func saveSequence(_ sequence: String) {
        UserDefaults.standard.set(sequence, forKey: "sequence")
    }
}

#Preview {
    Settings(isPresented: .constant(true))
        .modelContainer(ModelData.shared.modelContainer)
}
