//
//  Project.swift
//  Freelancer
//
//  Created by John Haselden on 30/06/2024.
//

import Foundation
import SwiftData

@Model
final class Project {
    var timestamp: Date
    var startDate: Date?
    var endDate: Date?
    var name: String
    var status: ProjectStatus
    var details: String
    var client: Client?
    @Relationship(deleteRule: .nullify, inverse: \Task.project) var tasks: [Task]
    @Relationship(deleteRule: .nullify, inverse: \Billable.project) var billables: [Billable]
    @Relationship(deleteRule: .nullify, inverse: \Invoice.project) var invoices: [Invoice]

    init(timestamp: Date, name: String, status: ProjectStatus, client: Client?, details: String, tasks: [Task], billables: [Billable], invoices: [Invoice] = []) {
        self.timestamp = timestamp
        self.name = name
        self.status = status
        self.client = client
        self.tasks = tasks
        self.details = details
        self.billables = billables
        self.invoices = invoices
    }

    init(timestamp: Date, name: String, status: ProjectStatus, details: String, tasks: [Task], billables: [Billable], invoices: [Invoice] = []) {
        self.timestamp = timestamp
        self.name = name
        self.status = status
        self.tasks = tasks
        self.details = details
        self.billables = billables
        self.invoices = invoices
    }

    enum ProjectStatus: String, CaseIterable, Codable, Identifiable {
        var id: Self { self }
        case pending = "pending"
        case won = "won"
        case lost = "lost"
        case expired = "expired"
    }
    
    static let sampleData = [
        Project(timestamp: Date(), name: "Project 1", status: .pending, details: "Project 1 details", tasks: [], billables: []),
        Project(timestamp: Date(), name: "Project 2", status: .won, details: "Project 2 details", tasks: [], billables: []),
        Project(timestamp: Date(), name: "Project 3", status: .lost, details: "Project 3 details", tasks: [], billables: []),
        Project(timestamp: Date(), name: "Project 4", status: .expired, details: "Project 4 details", tasks: [], billables: []),

    ]
    
    static var emptyProject: Project {
        Project(timestamp: Date(), name: "", status: .pending, details: "", tasks: [], billables: [])
    }

    
}


