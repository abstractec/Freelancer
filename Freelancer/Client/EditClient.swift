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
    
    @State private var client: Client
    @State private var name: String
    @State private var address: String
    @State private var details: String
    @State private var status: Client.ClientStatus
    
    init(isPresented: Binding<Bool>, client: Client, isNew: Bool) {
        _isPresented = isPresented
        self.isNew = isNew
        _client = State(initialValue: client)
        _name = State(initialValue: client.name)
        _address = State(initialValue: client.address)
        _details = State(initialValue: client.details)
        _status = State(initialValue: client.status)
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
            }
            .formStyle(.grouped)
            .navigationTitle(isNew ? "New Client" : "Edit Client")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        modelData.rollback()
                        isPresented = false
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        client.name = name
                        client.address = address
                        client.details = details
                        client.status = status
                        
                        if isNew {
                            modelData.insert(client)
                        }
                        isPresented = false
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .frame(minWidth: 420, minHeight: 360)
        }
    }
}

#Preview {
    EditClient(isPresented: .constant(true), client: ModelData.shared.client, isNew: false)
        .modelContainer(ModelData.shared.modelContainer)
}
