//
//  TaskSummary.swift
//  Freelancer
//
//  Created by John Haselden on 09/07/2024.
//

import SwiftUI

struct TaskSummary: View {
    var tasks: [Task]
    
    var incompleteTaskCount: Int {
        tasks.filter { task in
            task.status == .pending
        }.count
    }

    var completedTaskCount: Int  {
        tasks.filter { task in
            task.status == .done
        }.count
    }

    var cancelledTaskCount: Int  {
        tasks.filter { task in
            task.status == .cancelled
        }.count
    }

    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Incomplete: \(incompleteTaskCount)")
                    .bold()
                Text("Completed: \(completedTaskCount)")
                Text("Cancelled: \(cancelledTaskCount)")
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    return Group {
        TaskSummary(tasks: ModelData.shared.client.tasks)
    }
}

