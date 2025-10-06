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
    
    @Binding var isPresented: Bool?

    @State var refresh: Bool = false
    @State var textEditorHeight : CGFloat = 40
    
    func update() {
       refresh.toggle()
    }
    
    @State private var client: Client = Client.emptyClient
    
    @State private var name: String
    @State private var address: String
    @State private var details: String
    @State private var status: Client.ClientStatus
    
    init (isPresented: Binding<Bool>, client: Client) {
        self.client = client
        self.name = client.name
        self.address = client.address
        self.details = client.details
        self.status = client.status
        
        _isPresented = Binding.constant(false)
        self.isPresented = isPresented.wrappedValue
    }

    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text("Client Name").bold()
                TextField(
                    "Name",
                    text: $name).textFieldStyle(.roundedBorder)

                Text("Client Address").bold()
                TextEditor(
                    text: $address).textFieldStyle(.roundedBorder).frame(height: max(40,textEditorHeight))

                Text("Client Description").bold()
                TextEditor(
                    text: $details).textFieldStyle(.roundedBorder).frame(height: max(40,textEditorHeight))
                    
                

                Picker("Status", selection: $status) {
                    ForEach(Client.ClientStatus.allCases) { option in
                        Text(String(describing: option).capitalized)
                    }
                }
                .pickerStyle(.segmented)
               
                
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
                        // TODO: save this - check if we're editing!
                        client.name = name
                        client.address = address
                        client.details = details
                        client.status = status
                        
                        modelData.insert(client)
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
    Group {
        EditClient(isPresented: .constant(false), client: ModelData.shared.client)
    }
    .modelContainer(ModelData.shared.modelContainer)
}

#Preview("Create") {
    Group {
        EditClient(isPresented: .constant(false), client: ModelData.shared.client)
    }
    .modelContainer(ModelData.shared.modelContainer)

}
