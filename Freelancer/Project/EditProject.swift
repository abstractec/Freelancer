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

    @State var refresh: Bool = false
    @State var textEditorHeight : CGFloat = 160
    
    private var client: Client
    
    func update() {
       refresh.toggle()
    }
    
    @State private var project: Project = Project.emptyProject
    
    @State private var name: String
    @State private var details: String
    @State private var status: Project.ProjectStatus

    init (isPresented: Binding<Bool>, client: Client, project: Project) {
        self.client = client
        self.project = project
        self.name = project.name
        self.details = project.details
        self.status = project.status
        
        _isPresented = Binding.constant(false)
        self.isPresented = isPresented.wrappedValue
    }

    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text("Project Name").bold()
                TextField(
                    "Name",
                    text: $name).textFieldStyle(.roundedBorder)

                Text("Project Description").bold()
                TextEditor(
                    text: $details).textFieldStyle(.roundedBorder).frame(height: max(40,textEditorHeight))
                    
                Picker("Status", selection: $status) {
                    ForEach(Project.ProjectStatus.allCases) { option in
                        Text(String(describing: option).capitalized)
                    }
                }
                .pickerStyle(.segmented)
               
                
            }
            .padding()
        }
        .safeAreaInset(edge: .bottom) {
            VStack(alignment: .trailing, content: {
                HStack {
                    Button(action: {
                        modelData.rollback()
                        isPresented = false
                        dismiss()
                    }, label: {
                        Text("Cancel")
                    }).padding(.trailing, 8)
                    
                    Button(action: {
                        // TODO: save this - check if we're editing!
                        project.name = name
                        project.details = details
                        project.status = status
                        project.client = client
                        
                        modelData.insert(project)
                        isPresented = false
                        
                        dismiss()
                    }, label: {
                        Text("Save")
                    })

                }
            }).padding(.bottom, 16)

        }
    }
}


#Preview {
    Group {
        EditProject(isPresented: .constant(false), client: ModelData.shared.client, project: ModelData.shared.project)
    }
    .modelContainer(ModelData.shared.modelContainer)
}

#Preview("Create") {
    Group {
        EditProject(isPresented: .constant(false), client: ModelData.shared.client, project: Project.emptyProject)
    }
    .modelContainer(ModelData.shared.modelContainer)

}
