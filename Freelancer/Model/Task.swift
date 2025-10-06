//
//  Task.swift
//  Freelancer
//
//  Created by John Haselden on 09/07/2024.
//

import Foundation
import SwiftData

@Model
final class Task: Identifiable {
    var name: String
    var details: String
    var hasDueDate: Bool
    var dueDate: Date?
    var priority: TaskPriority
    var status: TaskStatus
    var timestamp: Date
    var client: Client?
    var project: Project?

    init(name: String, details: String, hasDueDate: Bool, dueDate: Date? = nil, priority: TaskPriority, status: TaskStatus, timestamp: Date, client: Client? = nil, project: Project? = nil) {
        self.name = name
        self.details = details
        self.hasDueDate = hasDueDate
        self.dueDate = dueDate
        self.priority = priority
        self.status = status
        self.timestamp = timestamp
        self.client = client
        self.project = project
    }
    
    static let sampleData = [
        Task(name: "Client Task 0", details: "Description 1", hasDueDate: true, dueDate: Date.now, priority: .low, status: .pending, timestamp: Date.now),
        Task(name: "Client Task 1", details: "Description 1", hasDueDate: false, priority: .high, status: .done, timestamp: Date.now),
        Task(name: "Client Task 2", details: "Description 1", hasDueDate: true, dueDate: Date.now, priority: .medium, status: .cancelled, timestamp: Date.now),
        Task(name: "Client Task 3", details: "Description 1", hasDueDate: false, priority: .low, status: .pending, timestamp: Date.now),
        Task(name: "Client Task 4", details: "Description 1", hasDueDate: true, dueDate: Date.now, priority: .high, status: .done, timestamp: Date.now),
        Task(name: "Client Task 5", details: "Description 1", hasDueDate: false, priority: .medium, status: .cancelled, timestamp: Date.now),
        Task(name: "Client Task 6", details: "Description 1", hasDueDate: true, dueDate: Date().dayAfter, priority: .medium, status: .cancelled, timestamp: Date.now),
        Task(name: "Client Task 7", details: "Description 1", hasDueDate: true, dueDate: Date().dayBefore, priority: .medium, status: .cancelled, timestamp: Date.now)

    ]

    static var emptyTask: Task {
        Task(name: "", details: "", hasDueDate: false, priority: .low, status: .pending, timestamp: Date.now)
    }
}

extension Task: Comparable {
    static func < (lhs: Task, rhs: Task) -> Bool {
        /* our priorities are
        
         * overdue
         * if not overdue, then priority
         * then priority
         
         */
        
        if let lhsDue = lhs.dueDate, let rhsDue = rhs.dueDate {
            if (lhsDue > rhsDue && lhs.priority == rhs.priority) {
                
                return true
            }
        }
        
        if lhs.priority == rhs.priority {
            return lhs.status < rhs.status
        } else {
            return lhs.priority < rhs.priority
        }
    }
}

enum TaskPriority: String, CaseIterable, Codable, Identifiable, Comparable {
    static func < (lhs: TaskPriority, rhs: TaskPriority) -> Bool {
        if (lhs == rhs) {
            return true
        } else if (rhs == .medium && lhs == .low) {
            return true
        } else if (rhs == .high) {
            return true
        } else if (lhs == .low) {
            return false
        }
        
        return false
    }
    
    var id: Self {self}
    
    case high = "high"
    case medium = "medium"
    case low = "low"

}

enum TaskStatus: String, CaseIterable, Codable, Identifiable, Comparable {
    static func < (lhs: TaskStatus, rhs: TaskStatus) -> Bool {
        if (lhs == rhs) {
            return true
        } else if (rhs == .pending && lhs == .done) {
            return true
        } else if (rhs == .done && lhs == .cancelled) {
            return true
        } else if (rhs == .pending) {
            return true
        } else if (lhs == .cancelled) {
            return false
        }
        return false
    }
    
    var id: Self {self}
    
    case pending = "pending"
    case done = "done"
    case cancelled = "cancelled"
}
