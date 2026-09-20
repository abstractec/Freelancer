//
//  TaskRow.swift
//  Freelancer
//
//  Created by John Haselden on 09/07/2024.
//

import SwiftUI

struct TaskRow: View {
    var task: Task
    var showsContext: Bool = false
    
    @State private var showingEditTask = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(task.name)
                    .font(.headline)
                
                if showsContext, let contextLabel {
                    Text(contextLabel)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                if !task.details.isEmpty {
                    Text(task.details)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                
                HStack(spacing: 8) {
                    StatusBadge.task(task.status)
                    
                    if task.hasDueDate, let date = task.dueDate {
                        Label(date.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Spacer()
            
            if task.status == .pending {
                Button {
                    task.status = .done
                } label: {
                    Image(systemName: "checkmark.circle")
                }
                .buttonStyle(.borderless)
                .help("Mark as done")
            }
            
            Button {
                showingEditTask = true
            } label: {
                Image(systemName: "pencil")
            }
            .buttonStyle(.borderless)
            .help("Edit task")
        }
        .padding(.vertical, 4)
        .sheet(isPresented: $showingEditTask) {
            EditTask(isPresented: $showingEditTask, task: task)
        }
    }
    
    private var contextLabel: String? {
        let clientName = task.client?.name ?? task.project?.client?.name
        let projectName = task.project?.name
        
        switch (clientName, projectName) {
        case let (client?, project?):
            return "\(client) · \(project)"
        case let (client?, nil):
            return client
        case let (nil, project?):
            return project
        default:
            return nil
        }
    }
}

#Preview {
    TaskRow(task: ModelData.shared.clientTask)
        .padding()
}
