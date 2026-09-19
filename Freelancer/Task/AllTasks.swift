//
//  AllTasks.swift
//  Freelancer
//
//  Created by John Haselden on 02/08/2024.
//

import SwiftUI
import SwiftData

struct AllTasks: View {
    var tasks: [Task]
    
    private var incompleteTasks: [Task] {
        tasks.filter { $0.status == .pending }.sorted()
    }
    
    private var completeTasks: [Task] {
        tasks.filter { $0.status == .done }.sorted()
    }
    
    private var cancelledTasks: [Task] {
        tasks.filter { $0.status == .cancelled }.sorted()
    }
    
    var body: some View {
        Group {
            if tasks.isEmpty {
                ContentUnavailableView(
                    "No Tasks",
                    systemImage: "checklist",
                    description: Text("Tasks from clients and projects will appear here.")
                )
            } else {
                List {
                    taskSection(title: "Pending", tasks: incompleteTasks)
                    taskSection(title: "Done", tasks: completeTasks)
                    taskSection(title: "Cancelled", tasks: cancelledTasks)
                }
            }
        }
        .navigationTitle("Tasks")
    }
    
    @ViewBuilder
    private func taskSection(title: String, tasks: [Task]) -> some View {
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
    NavigationStack {
        AllTasks(tasks: ModelData.shared.tasks)
    }
}
