//
//  ModelData.swift
//  Freelancer
//
//  Created by John Haselden on 01/07/2024.
//

import SwiftData


@MainActor
class ModelData {
    static let shared = ModelData()
    
    let modelContainer: ModelContainer
    
    var context: ModelContext {
        modelContainer.mainContext
    }
    
    private init() {
        let schema = Schema([
            Client.self,
            Project.self,
            Task.self,
        ])

        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        
        do {
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            insertSampleData()
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
    
    func insertSampleData() {
        for client in Client.sampleData {
            context.insert(client);
        }
        
        for project in Project.sampleData {
            context.insert(project);
        }

        for task in Task.sampleData {
            context.insert(task);
        }

        Project.sampleData[0].client = Client.sampleData[0];
        Project.sampleData[1].client = Client.sampleData[0];
        Project.sampleData[2].client = Client.sampleData[2];
        Project.sampleData[3].client = Client.sampleData[3];
        
        Task.sampleData[0].client = Client.sampleData[0];
        Task.sampleData[1].client = Client.sampleData[0];
        Task.sampleData[2].client = Client.sampleData[0];
        Task.sampleData[3].client = Client.sampleData[1];
        Task.sampleData[4].client = Client.sampleData[3];
        Task.sampleData[5].client = Client.sampleData[3];

        do {
            try context.save()
        } catch {
            print("Sample data context failed to save.")
        }

    }
    
    var client: Client {
        Client.sampleData[0]
    }
    
    var project: Project {
        Project.sampleData[0]
    }
    
    var clientTask: Task {
        Task.sampleData[0]
    }
    
    var tasks: [Task] {
        Task.sampleData
    }
    
    func save(client: Client) {
        context.insert(client)
    }
    
    func save(project: Project) {
        context.insert(project)
    }
}

