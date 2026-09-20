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
    private let isNew: Bool
    
    @State private var name: String
    @State private var details: String
    @State private var status: TaskStatus
    @State private var priority: TaskPriority
    @State private var date: Date = Date.now
    @State private var hasDueDate: Bool
    
    init(isPresented: Binding<Bool>, task: Task) {
        self.client = task.client
        self.project = task.project
        self.task = task
        self.isNew = task.modelContext == nil
        _isPresented = isPresented
        _status = State(initialValue: task.status)
        _priority = State(initialValue: task.priority)
        _details = State(initialValue: task.details)
        _name = State(initialValue: task.name)
        _hasDueDate = State(initialValue: task.hasDueDate)
        _date = State(initialValue: task.dueDate ?? Date.now)
    }
    
    init(isPresented: Binding<Bool>, client: Client, task: Task) {
        self.client = client
        self.task = task
        self.isNew = task.modelContext == nil
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
        self.isNew = task.modelContext == nil
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
                        Text(statusLabel(option)).tag(option)
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
            .navigationTitle(isNew ? "New Task" : "Edit Task")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
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
                        task.dueDate = hasDueDate ? date : nil
                        task.hasDueDate = hasDueDate
                        
                        if isNew {
                            if let client {
                                client.tasks.append(task)
                            } else if let project {
                                project.tasks.append(task)
                            }
                            modelData.insert(task)
                        }
                        
                        isPresented = false
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .frame(minWidth: 420, minHeight: 420)
        }
    }
    
    private func statusLabel(_ status: TaskStatus) -> String {
        switch status {
        case .pending: return "Pending"
        case .done: return "Done"
        case .cancelled: return "Cancelled"
        }
    }
}

#Preview {
    EditTask(isPresented: .constant(true), client: ModelData.shared.client, task: ModelData.shared.clientTask)
        .modelContainer(ModelData.shared.modelContainer)
}
