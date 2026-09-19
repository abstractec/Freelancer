//
//  EditTask.swift
//  Freelancer
//
//  Created by John Haselden on 09/07/2024.
//

import SwiftUI

struct EditTask: View {
    @Environment(\.modelContext) private var modelData
    @Environment(\.dismiss) var dismiss
    
    @Binding var isPresented: Bool
    
    private var project: Project?
    private var client: Client?
    private var task: Task
    
    @State private var name: String
    @State private var details: String
    @State private var status: TaskStatus
    @State private var priority: TaskPriority
    @State private var date: Date = Date.now
    @State private var hasDueDate: Bool
    
    init(isPresented: Binding<Bool>, client: Client, task: Task) {
        self.client = client
        self.task = task
        _isPresented = isPresented
        _status = State(initialValue: task.status)
        _priority = State(initialValue: task.priority)
        _details = State(initialValue: task.details)
        _name = State(initialValue: task.name)
        _hasDueDate = State(initialValue: task.hasDueDate)
        _date = State(initialValue: task.dueDate ?? Date.now)
    }
    
    init(isPresented: Binding<Bool>, project: Project, task: Task) {
        self.project = project
        self.task = task
        _isPresented = isPresented
        _status = State(initialValue: task.status)
        _priority = State(initialValue: task.priority)
        _details = State(initialValue: task.details)
        _name = State(initialValue: task.name)
        _hasDueDate = State(initialValue: task.hasDueDate)
        _date = State(initialValue: task.dueDate ?? Date.now)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                TextField("Description", text: $details, axis: .vertical)
                    .lineLimit(4...10)
                Picker("Status", selection: $status) {
                    ForEach(TaskStatus.allCases) { option in
                        Text(String(describing: option).capitalized).tag(option)
                    }
                }
                Picker("Priority", selection: $priority) {
                    ForEach(TaskPriority.allCases) { option in
                        Text(String(describing: option).capitalized).tag(option)
                    }
                }
                Toggle("Has Due Date", isOn: $hasDueDate)
                if hasDueDate {
                    DatePicker("Due Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                }
            }
            .formStyle(.grouped)
            .navigationTitle(name.isEmpty ? "New Task" : "Edit Task")
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
                        task.name = name
                        task.details = details
                        task.status = status
                        task.priority = priority
                        task.dueDate = date
                        task.hasDueDate = hasDueDate
                        
                        if let c = client {
                            task.client = c
                        }
                        if let p = project {
                            task.project = p
                        }
                        
                        modelData.insert(task)
                        isPresented = false
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .frame(minWidth: 420, minHeight: 420)
        }
    }
}

#Preview {
    EditTask(isPresented: .constant(true), client: ModelData.shared.client, task: ModelData.shared.clientTask)
        .modelContainer(ModelData.shared.modelContainer)
}
