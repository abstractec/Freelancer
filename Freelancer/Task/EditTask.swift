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
    
    @State private var name: String
    @State private var details: String
    @State private var status: TaskStatus
    @State private var priority: TaskPriority
    @State private var date: Date = Date.now
    @State private var hasDueDate: Bool
    @State var textEditorHeight : CGFloat = 160

    @Binding var isPresented: Bool

    private var project: Project?
    private var client: Client?
    private var task: Task

    init (isPresented: Binding<Bool>, client: Client, task: Task) {
        self.client = client
        self.task = task
        self.status = task.status
        self.priority = task.priority
        self.details = task.details
        
        self.name = task.name
        self.hasDueDate = task.hasDueDate
        
        if let date = task.dueDate {
            self.date = date
        }
        
        _isPresented = Binding.constant(false)
        self.isPresented = isPresented.wrappedValue
    }
    
    init (isPresented: Binding<Bool>, project: Project, task: Task) {
        self.project = project
        self.task = task
        self.status = task.status
        self.priority = task.priority
        self.details = task.details
        
        self.name = task.name
        self.hasDueDate = task.hasDueDate

        if let date = task.dueDate {
            self.date = date
        }
        
        _isPresented = Binding.constant(false)
        self.isPresented = isPresented.wrappedValue
    }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text("Task Name").bold()
                TextField(
                    "Name",
                    text: $name).textFieldStyle(.roundedBorder)
                
                Text("Task Description").bold()
                TextEditor(
                    text: $details).textFieldStyle(.roundedBorder).frame(height: max(40,textEditorHeight))
      
                    .padding(.bottom, 8)

                Picker("Status", selection: $status) {
                    ForEach(TaskStatus.allCases) { option in
                        Text(String(describing: option).capitalized)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.bottom, 8)
                
                Picker("Priority", selection: $priority) {
                    ForEach(TaskPriority.allCases) { option in
                        Text(String(describing: option).capitalized)
                    }
                }
                .pickerStyle(.segmented)

                Toggle(isOn: $hasDueDate) {
                    Text("Has Due Date")
                }
                .toggleStyle(.checkbox)

                DatePicker(
                        "Due Date",
                        selection: $date,
                        displayedComponents: [.date, .hourAndMinute]
                ).disabled(!hasDueDate)
                
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
                    }).padding(.trailing, 8)
                    
                    Button(action: {
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
                    }, label: {
                        Text("Save")
                    })
                    
                }.padding(.bottom, 16)
            }).padding(.bottom, 16)
        }
    }
    
}
#Preview {
    Group {
        EditTask(isPresented: .constant(false), client: ModelData.shared.client, task: ModelData.shared.clientTask)
    }
    .modelContainer(ModelData.shared.modelContainer)
}

#Preview("Create") {
    Group {
        EditTask(isPresented: .constant(false), client: ModelData.shared.client, task: Task.emptyTask)
    }
    .modelContainer(ModelData.shared.modelContainer)

}
