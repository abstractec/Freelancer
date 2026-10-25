//
//  EditClient.swift
//  Freelancer
//
//  Created by John Haselden on 01/07/2024.
//

import SwiftUI

struct EditClient: View {
    @Environment(\.modelContext) private var modelData
    @Environment(\.dismiss) var dismiss
    
    @Binding var isPresented: Bool
    
    private let isNew: Bool
    /// Existing client when editing. Creation does not allocate a model until Save,
    /// so SwiftData autosave cannot refresh the window and dismiss the sheet.
    private let client: Client?
    
    @State private var name: String
    @State private var address: String
    @State private var details: String
    @State private var status: Client.ClientStatus
    @State private var paymentTermsDays: Int
    
    init(isPresented: Binding<Bool>, client: Client?, isNew: Bool) {
        _isPresented = isPresented
        self.isNew = isNew
        self.client = client
        _name = State(initialValue: client?.name ?? "")
        _address = State(initialValue: client?.address ?? "")
        _details = State(initialValue: client?.details ?? "")
        _status = State(initialValue: client?.status ?? .pending)
        _paymentTermsDays = State(initialValue: max(client?.paymentTermsDays ?? 30, 0))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                TextField("Address", text: $address, axis: .vertical)
                    .lineLimit(3...6)
                TextField("Description", text: $details, axis: .vertical)
                    .lineLimit(3...8)
                Picker("Status", selection: $status) {
                    ForEach(Client.ClientStatus.allCases) { option in
                        Text(String(describing: option).capitalized).tag(option)
                    }
                }
                Stepper(value: $paymentTermsDays, in: 0...365) {
                    LabeledContent("Payment Terms", value: "Net \(paymentTermsDays) days")
                }
            }
            .formStyle(.grouped)
            .navigationTitle(isNew ? "New Client" : "Edit Client")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .frame(minWidth: 420, minHeight: 400)
            .onAppear {
                modelData.autosaveEnabled = false
            }
            .onDisappear {
                modelData.autosaveEnabled = true
            }
        }
    }
    
    private func save() {
        if isNew {
            let newClient = Client(
                timestamp: Date(),
                name: name,
                details: details,
                status: status,
                address: address,
                paymentTermsDays: paymentTermsDays,
                projects: [],
                tasks: []
            )
            modelData.insert(newClient)
        } else if let client {
            client.name = name
            client.address = address
            client.details = details
            client.status = status
            client.paymentTermsDays = paymentTermsDays
        }
        
        try? modelData.save()
        isPresented = false
        dismiss()
    }
}

#Preview {
    EditClient(isPresented: .constant(true), client: ModelData.shared.client, isNew: false)
        .modelContainer(ModelData.shared.modelContainer)
}
