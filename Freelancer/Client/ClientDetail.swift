//
//  ClientDetail.swift
//  Freelancer
//
//  Created by John Haselden on 01/07/2024.
//

import SwiftUI

struct ClientDetail: View {
    @Environment(\.modelContext) private var modelData
    var client: Client
    @State private var selectedProject: Project?
    @State private var showingEditClient = false
    @State private var showingEditProject = false
    @State private var showingEditClientTask = false
    @State private var showingClientTasks = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Text(client.name)
                        .font(.title)
                    
                    HStack {
                        Text(client.address)
                        Spacer()
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Text(client.details)
                        .font(.subheadline).padding(.bottom, 4)
                    
                    HStack {
                        
                        switch client.status {
                        case .pending:
                            Text("⏰ Pending")
                        case .won:
                            Text("🎉 Won")
                        case .lost:
                            Text("😢 Lost")
                        case .expired:
                            Text("🪦 Expired")
                        }
                        Spacer()
                        Button {
                            showingEditClient.toggle()
                        } label: {
                            Image(systemName: "pencil").padding(4)
                        }
                        .background(.white)
                        .cornerRadius(15)
                        .buttonStyle(.plain)
                        .padding(.trailing, 8)
                        .sheet(isPresented: $showingEditClient, content: {
                            EditClient(isPresented: $showingEditClient, client: client)
                        })
                    }.padding()
                        .background(.green.opacity(0.1))
                        .foregroundColor(.black)
                        .cornerRadius(15)
                }
                
                VStack(alignment: .leading) {
                    HStack {
                        Text("Tasks").font(.title2)
                        Spacer()
                        Button {
                            showingEditClientTask.toggle()
                        } label: {
                            Image(systemName: "plus").padding(4)
                        }
                        .background(.white)
                        .cornerRadius(15)
                        .buttonStyle(.plain)
                        .padding(.trailing, 8)
                        .sheet(isPresented: $showingEditClientTask, content: {
                            EditTask(isPresented: $showingEditClientTask, client: client, task: Task.emptyTask)
                        })
                    }
                    
                    HStack {
                        TaskSummary(tasks: client.tasks)
                        Button {
                            showingClientTasks.toggle()
                        } label: {
                            Image(systemName: "checkmark.rectangle").padding(4)
                        }
                        .background(.white)
                        .cornerRadius(15)
                        .buttonStyle(.plain)
                        .padding(.trailing, 8)
                        .sheet(isPresented: $showingClientTasks, content: {
                            TaskList(isPresented: $showingClientTasks, client: client, tasks: client.tasks)
                        })
                    }.padding()
                        .background(.blue.opacity(0.1))
                        .foregroundColor(.black)
                        .cornerRadius(15)
                }
                
                HStack {
                    Text("Projects").font(.title2)
                    Spacer()
                    Button {
                        showingEditProject.toggle()
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
                    .padding(.trailing, 8)
                    .sheet(isPresented: $showingEditProject, content: {
                        EditProject(isPresented: $showingEditProject, client: client, project: Project.emptyProject)
                    })

                }
                
                ForEach(client.projects) { project in
                    ProjectRow(project: project)
                }
                
            }
            .padding()
        }
        .navigationTitle(client.name)
        .background(.white)
    }
}


#Preview {
    Group {
        ClientDetail(client: ModelData.shared.client)
    }
    .modelContainer(ModelData.shared.modelContainer)
}
