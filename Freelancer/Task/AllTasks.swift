//
//  AllTasks.swift
//  Freelancer
//
//  Created by John Haselden on 02/08/2024.
//

import SwiftUI
import SwiftData

struct AllTasks: View {
    @Environment(\.modelContext) private var modelData
    
    @Environment(\.dismiss) var dismiss
    @State private var showingEditTask = false

    @Binding var isPresented: Bool
    
    var tasks: [Task]

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

                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(tasks.sorted()) { task in
                            HStack {
                                Text(task.name).bold()
                                                                
                                if task.hasDueDate, let date = task.dueDate {
                                    Text(date.formatted())
                                }
                                
                                switch task.status {
                                case .pending:
                                    Text("⏰ Pending")
                                case .done:
                                    Text("🎉 Complete")
                                case .cancelled:
                                    Text("😢 Cancelled")
                                }
                            }
                            Spacer()
                        }
                    }
                }

            }.padding(.all, 8)
        }
        .padding(.vertical, 4)
//        .frame(width: max(40,640), height: max(40,640))
    }
}

#Preview {
    return Group {
        AllTasks(isPresented: .constant(false), tasks: ModelData.shared.tasks)
    }
}
