//
//  Client.swift
//  Freelancer
//
//  Created by John Haselden on 30/06/2024.
//

import Foundation
import SwiftData

@Model
final class Client {
    var timestamp: Date = Date()
    var name: String
    var details: String
    var status: ClientStatus
    var address: String
    @Relationship(deleteRule: .nullify, inverse: \Project.client) var projects: [Project]
    @Relationship(deleteRule: .nullify, inverse: \Task.client) var tasks: [Task]

    init(timestamp: Date, name: String, details: String, status: ClientStatus, address: String, projects: [Project], tasks: [Task]) {
        self.timestamp = timestamp
        self.name = name
        self.details = details
        self.status = status
        self.address = address
        self.projects = projects
        self.tasks = tasks
    }
    
    enum ClientStatus: String, CaseIterable, Codable, Identifiable  {
        var id: Self { self }
        
        case pending = "pending"
        case won = "won"
        case lost = "lost"
        case expired = "expired"
    }
    
    static var emptyClient: Client {
        Client(timestamp: Date(), name: "", details: "", status: .pending, address: "", projects: [], tasks: [])
    }

    static let sampleData = [
        Client(timestamp: Date(), name: "Client 1", details: "This is client 1", status: .pending, address: "1234 A Street, Ras Al Khaimah", projects: [], tasks: []),
        Client(timestamp: Date(), name: "Client 2", details: "This is client 1", status: .won, address: "1234 A Street, Ras Al Khaimah", projects: [], tasks: []),
        Client(timestamp: Date(), name: "Client 3", details: "This is client 1", status: .lost, address: "1234 A Street, Ras Al Khaimah", projects: [], tasks: []),
        Client(timestamp: Date(), name: "Client 4", details: "This is client 1", status: .expired, address: "1234 A Street, Ras Al Khaimah", projects: [], tasks: [])
    ]
}

