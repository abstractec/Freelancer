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
    @Query(sort: \Client.name) private var clients: [Client]
    @Query private var tasks: [Task]
    
    @State private var selection: SidebarSelection? = .tasks
    @State private var showingEditClient = false
    @State private var isCreatingClient = false
    @State private var selectedClientForEdit: Client?
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                Section {
                    Label("Tasks", systemImage: "checklist")
                        .tag(SidebarSelection.tasks)
                }
                
                Section("Clients") {
                    if clients.isEmpty {
                        ContentUnavailableView(
                            "No Clients",
                            systemImage: "person.2",
                            description: Text("Add a client to get started.")
                        )
                        .frame(minHeight: 120)
                    } else {
                        ForEach(clients) { client in
                            Label(client.name, systemImage: "person")
                                .tag(SidebarSelection.client(client.persistentModelID))
                                .contextMenu {
                                    Button("Edit Client") {
                                        editClient(client)
                                    }
                                    Button("Delete Client", role: .destructive) {
                                        modelContext.delete(client)
                                        if case .client(let id) = selection, id == client.persistentModelID {
                                            selection = .tasks
                                        }
                                    }
                                }
                            
                            ForEach(client.projects) { project in
                                Label(project.name, systemImage: "folder")
                                    .tag(SidebarSelection.project(project.persistentModelID))
                                    .padding(.leading, 8)
                            }
                        }
                        .onDelete(perform: deleteClients)
                    }
                }
            }
            .navigationTitle("Freelancer")
            .navigationSplitViewColumnWidth(min: 220, ideal: 260)
            .toolbar {
                ToolbarItem {
                    Button {
                        isCreatingClient = true
                        selectedClientForEdit = Client.emptyClient
                        showingEditClient = true
                    } label: {
                        Label("Add Client", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingEditClient, onDismiss: {
                selectedClientForEdit = nil
            }) {
                if let selectedClientForEdit {
                    EditClient(
                        isPresented: $showingEditClient,
                        client: selectedClientForEdit,
                        isNew: isCreatingClient
                    )
                }
            }
        } detail: {
            detailView
        }
    }
    
    @ViewBuilder
    private var detailView: some View {
        switch selection {
        case .tasks:
            AllTasks(tasks: tasks)
        case .client(let id):
            if let client = clients.first(where: { $0.persistentModelID == id }) {
                ClientDetail(client: client, selection: $selection)
            } else {
                ContentUnavailableView("Client not found", systemImage: "person.slash")
            }
        case .project(let id):
            if let project = findProject(id: id) {
                ProjectWorkspace(project: project)
            } else {
                ContentUnavailableView("Project not found", systemImage: "folder.badge.questionmark")
            }
        case .none:
            ContentUnavailableView(
                "Select an item",
                systemImage: "sidebar.left",
                description: Text("Choose Tasks, a client, or a project from the sidebar.")
            )
        }
    }
    
    private func findProject(id: PersistentIdentifier) -> Project? {
        for client in clients {
            if let project = client.projects.first(where: { $0.persistentModelID == id }) {
                return project
            }
        }
        return nil
    }
    
    private func deleteClients(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let client = clients[index]
                if case .client(let id) = selection, id == client.persistentModelID {
                    selection = .tasks
                }
                modelContext.delete(client)
            }
        }
    }
    
    private func editClient(_ client: Client) {
        isCreatingClient = false
        selectedClientForEdit = client
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
