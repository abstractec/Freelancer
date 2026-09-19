//
//  TaskSummary.swift
//  Freelancer
//
//  Created by John Haselden on 09/07/2024.
//

import SwiftUI

struct TaskSummary: View {
    var tasks: [Task]
    
    private var incompleteTaskCount: Int {
        tasks.filter { $0.status == .pending }.count
    }
    
    private var completedTaskCount: Int {
        tasks.filter { $0.status == .done }.count
    }
    
    private var cancelledTaskCount: Int {
        tasks.filter { $0.status == .cancelled }.count
    }
    
    var body: some View {
        HStack(spacing: 16) {
            summaryChip(title: "Pending", count: incompleteTaskCount, tint: .orange)
            summaryChip(title: "Done", count: completedTaskCount, tint: .green)
            summaryChip(title: "Cancelled", count: cancelledTaskCount, tint: .red)
            Spacer()
        }
    }
    
    private func summaryChip(title: String, count: Int, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("\(count)")
                .font(.title2.bold())
                .foregroundStyle(tint)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    TaskSummary(tasks: ModelData.shared.client.tasks)
        .padding()
}
