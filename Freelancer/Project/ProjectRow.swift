//
//  ProjectRow.swift
//  Freelancer
//
//  Created by John Haselden on 01/07/2024.
//

import SwiftUI

struct ProjectRow: View {
    var project: Project
    var onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                Image(systemName: "folder.fill")
                    .foregroundStyle(.tint)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(project.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    if let startDate = project.startDate {
                        Text("Started \(startDate.formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else if !project.details.isEmpty {
                        Text(project.details)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                StatusBadge.project(project.status)
                
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding()
            .background(.quaternary.opacity(0.4), in: RoundedRectangle(cornerRadius: 10))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ProjectRow(project: ModelData.shared.project) {}
        .padding()
}
