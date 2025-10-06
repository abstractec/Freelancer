//
//  ProjectDetail.swift
//  Freelancer
//
//  Created by John Haselden on 03/07/2024.
//

import SwiftUI

struct ProjectDetail: View {
    @Environment(\.modelContext) private var modelData
    @Environment(\.dismiss) var dismiss
    @State private var showingEditTask = false
    @State private var showingTasks = false

    var project: Project
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading) {
                    HStack {
                        Text(project.name)
                            .font(.title)
                    }
                    
                    if let clientName = project.client?.name {
                        Text("For \(clientName)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("Tasks").font(.title2)
                        Spacer()
                        Button {
                            showingEditTask.toggle()
                        } label: {
                            Label("Add", systemImage: "plus")
                        }
                        .padding(.trailing, 8)
                        .sheet(isPresented: $showingEditTask, content: {
                            EditTask(isPresented: $showingEditTask, project: project, task: Task.emptyTask)
                        })
                    }
                    
                    HStack {
                        TaskSummary(tasks: project.tasks)
                        Button {
                            print("pressed")
                            showingTasks.toggle()
                        } label: {
                            Label("View", systemImage: "checkmark.rectangle")
                        }
                        .padding(.trailing, 8)
                        .sheet(isPresented: $showingTasks, content: {
                            TaskList(isPresented: $showingTasks, project: project, tasks: project.tasks)
                        })
                    }
                    
                    Spacer()
                }
                .padding()
                
            }
            
            HStack(alignment: .center) {
                Spacer()
                Button(action: {
                    dismiss()
                }, label: {
                    Text("OK")
                })
                Spacer()
            }
            .padding(.bottom, 16)
        }
        
        .frame(width: max(40,640), height: max(40,640))
        .navigationTitle(project.name)
    }
}


#Preview {
    Group {
        ProjectDetail(project: ModelData.shared.project)
    }
    .modelContainer(ModelData.shared.modelContainer)
}
