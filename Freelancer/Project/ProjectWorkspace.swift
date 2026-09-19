//
//  ProjectWorkspace.swift
//  Freelancer
//

import SwiftUI
import SwiftData

struct ProjectWorkspace: View {
    @Environment(\.defaultMinListRowHeight) var minRowHeight
    @Environment(\.modelContext) private var modelData
    
    @Bindable var project: Project
    
    @State private var showingEditProject = false
    @State private var showingCreateInvoice = false
    @State private var showingCreateProjectBillable = false
    @State private var showingEditTask = false
    @State private var showingTasks = false
    @State private var selectedBillable: Billable?
    
    private var openBillables: [Billable] {
        project.billables
            .filter { $0.status == .new }
            .sorted { $0.start < $1.start }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                
                tasksSection
                
                billablesSection
                
                invoicesSection
            }
            .padding()
        }
        .navigationTitle(project.name)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingEditProject = true
                } label: {
                    Label("Edit Project", systemImage: "pencil")
                }
            }
        }
        .sheet(isPresented: $showingEditProject) {
            if let client = project.client {
                EditProject(isPresented: $showingEditProject, client: client, project: project)
            }
        }
        .sheet(isPresented: $showingCreateProjectBillable) {
            ProjectBillables(isPresented: $showingCreateProjectBillable, project: project, billable: Billable.emptyBillable)
        }
        .sheet(item: $selectedBillable) { billable in
            ProjectBillables(
                isPresented: Binding(
                    get: { selectedBillable != nil },
                    set: { if !$0 { selectedBillable = nil } }
                ),
                project: project,
                billable: billable
            )
        }
        .sheet(isPresented: $showingCreateInvoice) {
            ProjectInvoice(isPresented: $showingCreateInvoice, project: project)
        }
        .sheet(isPresented: $showingEditTask) {
            EditTask(isPresented: $showingEditTask, project: project, task: Task.emptyTask)
        }
        .sheet(isPresented: $showingTasks) {
            TaskList(isPresented: $showingTasks, project: project, tasks: project.tasks)
        }
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(project.name)
                    .font(.largeTitle.bold())
                Spacer()
                StatusBadge.project(project.status)
            }
            
            if let clientName = project.client?.name {
                Text(clientName)
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            
            if !project.details.isEmpty {
                Text(project.details)
                    .foregroundStyle(.secondary)
            }
            
            if let startDate = project.startDate {
                Text("Started \(startDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.quaternary.opacity(0.4), in: RoundedRectangle(cornerRadius: 12))
    }
    
    private var tasksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Tasks")
                    .font(.title2.bold())
                Spacer()
                Button {
                    showingEditTask = true
                } label: {
                    Label("Add", systemImage: "plus")
                }
                Button {
                    showingTasks = true
                } label: {
                    Label("View", systemImage: "checklist")
                }
            }
            
            TaskSummary(tasks: project.tasks)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.quaternary.opacity(0.4), in: RoundedRectangle(cornerRadius: 12))
        }
    }
    
    private var billablesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Billables")
                    .font(.title2.bold())
                Spacer()
                Button {
                    showingCreateProjectBillable = true
                } label: {
                    Label("Add", systemImage: "plus")
                }
            }
            
            if openBillables.isEmpty {
                ContentUnavailableView(
                    "No open billables",
                    systemImage: "clock",
                    description: Text("Add time or fixed-cost entries to invoice later.")
                )
                .frame(minHeight: 120)
            } else {
                Table(openBillables) {
                    TableColumn("Details", value: \.details)
                    TableColumn("Start") { billable in
                        Text(formatDate(billable.start, includeTime: billable.kind != .fixed))
                    }
                    TableColumn("End") { billable in
                        if billable.kind == .fixed {
                            Text("—")
                        } else {
                            Text(formatDate(billable.end))
                        }
                    }
                    TableColumn("Rate") { billable in
                        Text(BillableHelper().rateLabel(for: billable))
                    }
                    TableColumn("Total") { billable in
                        Text(BillableHelper().formattedAmount(for: billable))
                    }
                    TableColumn("Status") { billable in
                        StatusBadge.billable(billable.status)
                    }
                    TableColumn("Actions") { billable in
                        HStack {
                            Button {
                                selectedBillable = billable
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .buttonStyle(.borderless)
                            .help("Edit billable")
                            
                            Button(role: .destructive) {
                                if let idx = project.billables.firstIndex(of: billable) {
                                    modelData.delete(billable)
                                    project.billables.remove(at: idx)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            .buttonStyle(.borderless)
                            .help("Delete billable")
                        }
                    }
                }
                .frame(minHeight: (minRowHeight * 1.3) + (minRowHeight * CGFloat(max(openBillables.count, 5))))
            }
        }
    }
    
    private var invoicesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Invoices")
                    .font(.title2.bold())
                Spacer()
                Button {
                    showingCreateInvoice = true
                } label: {
                    Label("Create Invoice", systemImage: "doc.badge.plus")
                }
            }
            
            if project.invoices.isEmpty {
                ContentUnavailableView(
                    "No invoices yet",
                    systemImage: "doc.text",
                    description: Text("Select billables to create an invoice.")
                )
                .frame(minHeight: 120)
            } else {
                VStack(spacing: 8) {
                    ForEach(project.invoices) { invoice in
                        InvoiceRow(invoice: invoice, project: project)
                            .padding()
                            .background(.quaternary.opacity(0.4), in: RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
        }
    }
    
    private func formatDate(_ date: Date, includeTime: Bool = true) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = includeTime ? .short : .none
        return dateFormatter.string(from: date)
    }
}

#Preview {
    ProjectWorkspace(project: ModelData.shared.project)
        .modelContainer(ModelData.shared.modelContainer)
}
