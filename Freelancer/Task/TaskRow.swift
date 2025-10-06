//
//  TaskRow.swift
//  Freelancer
//
//  Created by John Haselden on 09/07/2024.
//

import SwiftUI

struct TaskRow: View {
    var task: Task
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Text("Name").bold()
                    Text(task.name)
                }
                .padding(.bottom, 8)
                .padding(.top, 4)
                
                switch task.status {
                case .pending:
                    Text("⏰ Pending")
                case .done:
                    Text("🎉 Complete")
                case .cancelled:
                    Text("😢 Cancelled")
                }
               
                if task.hasDueDate, let date = task.dueDate {
                    Text("Due").bold()
                    Text(date.formatted())
                }

                Divider()
            }
        }
    }
}

#Preview {
    return Group {
        TaskRow(task: ModelData.shared.clientTask)
    }
}
