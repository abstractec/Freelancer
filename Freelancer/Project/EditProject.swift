//
//  EditProject.swift
//  Freelancer
//
//  Created by John Haselden on 02/07/2024.
//

import SwiftUI

struct EditProject: View {
    @Environment(\.modelContext) private var modelData
    @Environment(\.dismiss) var dismiss
    
    @Binding var isPresented: Bool
    
    private let client: Client
    private let project: Project?
    private let isNew: Bool
    
    @State private var name: String
    @State private var details: String
    @State private var status: Project.ProjectStatus
    
    init(isPresented: Binding<Bool>, client: Client, project: Project?) {
        self.client = client
        self.project = project
        self.isNew = project == nil
        _isPresented = isPresented
        _name = State(initialValue: project?.name ?? "")
        _details = State(initialValue: project?.details ?? "")
        _status = State(initialValue: project?.status ?? .pending)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                TextField("Description", text: $details, axis: .vertical)
                    .lineLimit(4...10)
                Picker("Status", selection: $status) {
                    ForEach(Project.ProjectStatus.allCases) { option in
                        Text(String(describing: option).capitalized).tag(option)
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle(isNew ? "New Project" : "Edit Project")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .frame(minWidth: 420, minHeight: 360)
            .onAppear {
                modelData.autosaveEnabled = false
            }
            .onDisappear {
                modelData.autosaveEnabled = true
            }
        }
    }
    
    private func save() {
        if let project {
            project.name = name
            project.details = details
            project.status = status
            project.client = client
        } else {
            let project = Project(
                timestamp: Date(),
                name: name,
                status: status,
                client: client,
                details: details,
                tasks: [],
                billables: []
            )
            modelData.insert(project)
        }
        
        try? modelData.save()
        isPresented = false
        dismiss()
    }
}

#Preview {
    EditProject(isPresented: .constant(true), client: ModelData.shared.client, project: ModelData.shared.project)
        .modelContainer(ModelData.shared.modelContainer)
}
