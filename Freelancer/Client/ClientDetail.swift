//
//  ClientDetail.swift
//  Freelancer
//
//  Created by John Haselden on 01/07/2024.
//

import SwiftUI

struct ClientDetail: View {
    var client: Client
    @Binding var selection: SidebarSelection?
    
    @State private var showingEditClient = false
    @State private var showingEditProject = false
    @State private var showingEditClientTask = false
    @State private var showingClientTasks = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                
                tasksSection
                
                projectsSection
            }
            .padding()
        }
        .navigationTitle(client.name)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingEditClient = true
                } label: {
                    Label("Edit Client", systemImage: "pencil")
                }
            }
        }
        .sheet(isPresented: $showingEditClient) {
            EditClient(isPresented: $showingEditClient, client: client, isNew: false)
        }
        .sheet(isPresented: $showingEditClientTask) {
            EditTask(isPresented: $showingEditClientTask, client: client, task: Task.emptyTask)
        }
        .sheet(isPresented: $showingClientTasks) {
            TaskList(isPresented: $showingClientTasks, client: client, tasks: client.tasks)
        }
        .sheet(isPresented: $showingEditProject) {
            EditProject(isPresented: $showingEditProject, client: client, project: Project.emptyProject)
        }
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(client.name)
                    .font(.largeTitle.bold())
                Spacer()
                StatusBadge.client(client.status)
            }
            
            if !client.address.isEmpty {
                Text(client.address)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            if !client.details.isEmpty {
                Text(client.details)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            
            Text("Payment terms: Net \(client.paymentTermsDays) days")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.quaternary.opacity(0.4), in: RoundedRectangle(cornerRadius: 12))
    }
    
    private var tasksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Tasks")
                    .font(.title2.bold())
                Spacer()
                Button {
                    showingEditClientTask = true
                } label: {
                    Label("Add", systemImage: "plus")
                }
                Button {
                    showingClientTasks = true
                } label: {
                    Label("View", systemImage: "checklist")
                }
            }
            
            TaskSummary(tasks: client.tasks)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.quaternary.opacity(0.4), in: RoundedRectangle(cornerRadius: 12))
        }
    }
    
    private var projectsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Projects")
                    .font(.title2.bold())
                Spacer()
                Button {
                    showingEditProject = true
                } label: {
                    Label("Add Project", systemImage: "plus")
                }
            }
            
            if client.projects.isEmpty {
                ContentUnavailableView(
                    "No projects",
                    systemImage: "folder",
                    description: Text("Add a project to track billables and invoices.")
                )
                .frame(minHeight: 120)
            } else {
                VStack(spacing: 8) {
                    ForEach(client.projects) { project in
                        ProjectRow(project: project) {
                            selection = .project(project.persistentModelID)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ClientDetail(client: ModelData.shared.client, selection: .constant(.tasks))
        .modelContainer(ModelData.shared.modelContainer)
}
