//
//  ProjectDetail.swift
//  Freelancer
//
//  Created by John Haselden on 03/07/2024.
//

import SwiftUI

/// Lightweight task inspector kept for previews and optional sheets.
/// Primary project work happens in `ProjectWorkspace`.
struct ProjectDetail: View {
    var project: Project
    
    var body: some View {
        ProjectWorkspace(project: project)
    }
}

#Preview {
    ProjectDetail(project: ModelData.shared.project)
        .modelContainer(ModelData.shared.modelContainer)
}
