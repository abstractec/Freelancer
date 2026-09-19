//
//  TaskLIst.swift
//  Freelancer
//
//  Created by John Haselden on 09/07/2024.
//

import SwiftUI

struct TaskList: View {
    @Environment(\.dismiss) var dismiss
    @State private var showingEditTask = false
    @Binding var isPresented: Bool
    
    @State private var project: Project?
    @State private var client: Client?
    
    private var tasks: [Task] {
        if let project {
            return project.tasks
        }
        if let client {
            return client.tasks
        }
        return []
    }
    
    private var incompleteTasks: [Task] {
        tasks.filter { $0.status == .pending }
    }
    
    private var completeTasks: [Task] {
        tasks.filter { $0.status == .done }
    }
    
    private var cancelledTasks: [Task] {
        tasks.filter { $0.status == .cancelled }
    }
    
    init(isPresented: Binding<Bool>, project: Project, tasks: [Task]) {
        _isPresented = isPresented
        _project = State(initialValue: project)
    }
    
    init(isPresented: Binding<Bool>, client: Client, tasks: [Task]) {
        _isPresented = isPresented
        _client = State(initialValue: client)
    }
    
    var body: some View {
        NavigationStack {
            List {
                if tasks.isEmpty {
                    ContentUnavailableView(
                        "No Tasks",
                        systemImage: "checklist",
                        description: Text("Add a task to track work for this \(project != nil ? "project" : "client").")
                    )
                } else {
                    taskSection("Pending", incompleteTasks)
                    taskSection("Done", completeTasks)
                    taskSection("Cancelled", cancelledTasks)
                }
            }
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        isPresented = false
                        dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingEditTask = true
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingEditTask) {
                if let project {
                    EditTask(isPresented: $showingEditTask, project: project, task: Task.emptyTask)
                } else if let client {
                    EditTask(isPresented: $showingEditTask, client: client, task: Task.emptyTask)
                }
            }
            .frame(minWidth: 520, minHeight: 480)
        }
    }
    
    @ViewBuilder
    private func taskSection(_ title: String, _ tasks: [Task]) -> some View {
        if !tasks.isEmpty {
            Section(title) {
                ForEach(tasks) { task in
                    TaskRow(task: task)
                }
            }
        }
    }
}

#Preview {
    TaskList(isPresented: .constant(true), client: ModelData.shared.client, tasks: ModelData.shared.client.tasks)
}
