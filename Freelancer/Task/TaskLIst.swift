//
//  TaskLIst.swift
//  Freelancer
//
//  Created by John Haselden on 09/07/2024.
//

import SwiftUI

struct TaskList: View {
    @Environment(\.modelContext) private var modelData

    var tasks: [Task] {
        if let project = project {
            return project.tasks
        }
        
        if let client = client {
            return client.tasks
        }
        
        return []
    }
    
    @State var project: Project?
    @State var client: Client?
    
    @Environment(\.dismiss) var dismiss
    @State private var showingEditTask = false

    @Binding var isPresented: Bool

    init (isPresented: Binding<Bool>, project: Project, tasks: [Task]) {
        self.project = project
        
        _isPresented = Binding.constant(false)
        self.isPresented = isPresented.wrappedValue
    }
   
    init (isPresented: Binding<Bool>, client: Client, tasks: [Task]) {
        self.client = client

        _isPresented = Binding.constant(false)
        self.isPresented = isPresented.wrappedValue
    }
   
    var incompleteTasks: [Task] {
        tasks.filter{ task in
            task.status == .pending
        }
    }

    var completeTasks: [Task] {
        tasks.filter{ task in
            task.status == .done
        }
    }

    var cancelledTasks: [Task] {
        tasks.filter{ task in
            task.status == .cancelled
        }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack(alignment: .center) {
                    Spacer()
                    Text("Tasks").font(.title)
                    Spacer()
                }
                
                Button {
                    showingEditTask.toggle()
                } label: {
                    Label("Add", systemImage: "plus")
                }
                .padding(.trailing, 8)
                .sheet(isPresented: $showingEditTask, content: {
                    if let project = self.project {
                        EditTask(isPresented: $showingEditTask, project: project, task: Task.emptyTask)
                    }
                    
                    if let client = self.client {
                        EditTask(isPresented: $showingEditTask, client: client, task: Task.emptyTask)
                    }
                })
                
                if let project = self.project {
                    TaskSummary(tasks: project.tasks)
                }
                
                if let client = self.client {
                    TaskSummary(tasks: client.tasks)
                }

                ScrollView {
                    VStack(alignment: .leading) {
                        Text("Incomplete Tasks").bold()
                        ForEach(incompleteTasks) { task in
                            TaskRow(task: task)
                        }

                        Text("Done Tasks").bold().padding(.top, 8)
                        ForEach(completeTasks) { task in
                            TaskRow(task: task)
                        }

                        Text("Cancelled Tasks").bold().padding(.top, 8)
                        ForEach(cancelledTasks) { task in
                            TaskRow(task: task)
                        }
                    }
                }

                Spacer()
                
                HStack(alignment: .center) {
                    Spacer()
                    Button(action: {
                        dismiss()
                    }, label: {
                        Text("OK")
                    })
                    Spacer()
                }
            }.padding(.all, 8)
        }
        .padding(.vertical, 4)
        .frame(width: max(40,640), height: max(40,640))
    }
}

#Preview {
    return Group {
        TaskList(isPresented: .constant(false), client: ModelData.shared.client, tasks: ModelData.shared.client.tasks)
    }
}

