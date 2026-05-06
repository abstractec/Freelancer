//
//  ContentView.swift
//  Freelancer
//
//  Created by John Haselden on 30/06/2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var tasks: [Task]
    
    @Query private var clients: [Client]
    @State private var showingEditClient = false
    @State private var isCreatingClient = false
    @State private var showingRateList = false
    @State private var showingEditTask = false
    @State private var showingSettings = false
    
    @State private var selectedClient: Client?

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(clients) { client in
                    HStack {
                        NavigationLink {
                            ClientDetail(client: client)
                        } label: {
                            Text(client.name)
                        }
                        Spacer()
                        
                        Button {
                            editClient(client: client)
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .buttonStyle(.borderless)
                        .help("Edit client")
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationSplitViewColumnWidth(min: 240, ideal: 240)
            .sheet(isPresented: $showingEditClient, onDismiss: {
                selectedClient = nil
            }) {
                if let selectedClient {
                    EditClient(
                        isPresented: $showingEditClient,
                        client: selectedClient,
                        isNew: isCreatingClient
                    )
                }
            }
            .toolbar {
                ToolbarItem {
                    Button {
                        isCreatingClient = true
                        selectedClient = Client.emptyClient
                        showingEditClient = true
                    } label: {
                        Label("Add Item", systemImage: "plus")
                    }
                }
                ToolbarItem {
                    Button {
                        showingSettings.toggle()
                    } label: {
                        Label("Rate", systemImage: "gear")
                    }.sheet(isPresented: $showingSettings, content: {
                        Settings(isPresented: $showingSettings)
                    })
                }
            }
            AllTasks(isPresented: $showingEditTask, tasks: tasks)
                .frame(height: 200)
        } detail: {
            Text("Select an item")
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(clients[index])
            }
        }
    }
    
    private func editClient(client: Client) {
        isCreatingClient = false
        selectedClient = client
        showingEditClient = true
    }
}

#Preview {
    ContentView().modelContainer(ModelData.shared.modelContainer)
}

#Preview("Empty List") {
    ContentView()
        .modelContainer(for: Client.self, inMemory: true)
}
