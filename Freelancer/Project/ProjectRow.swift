//
//  ProjectRow.swift
//  Freelancer
//
//  Created by John Haselden on 01/07/2024.
//

import SwiftUI
import SwiftData

struct ProjectRow: View {
    @Environment(\.defaultMinListRowHeight) var minRowHeight
    @Environment(\.modelContext) private var modelData
    
    @State var project: Project
    @State private var showingProject = false
    @State private var showingEditProject = false
    @State private var showingEditProjectBillable = false
    @State private var showingCreateInvoice = false
    @State private var showingCreateProjectBillable = false
    
    @State var invoices: [Invoice] = []
    @State var billables: [Billable] = []
    
    private var currentBillable: Billable?
    @State private var selectedBillable: Billable?

    init (project: Project) {
        self.project = project
        self.invoices = project.invoices
    }
    
    var body: some View {
        VStack {
            VStack {
                
                HStack {
                    VStack(alignment: .leading) {
                        Text(project.name)
                            .bold().padding(.bottom, 4)
                        
                        switch project.status {
                        case .pending:
                            Text("⏰ Pending")
                        case .won:
                            Text("🎉 Won")
                        case .lost:
                            Text("😢 Lost")
                        case .expired:
                            Text("🪦 Expired")
                        }
                    }.onTapGesture {
                        showingProject.toggle()
                    }.sheet(isPresented: $showingProject, content: {
                        ProjectDetail(project: project)
                    })
                    
                    Spacer()
                    
                    if let startDate: Date = project.startDate {
                        Text("Started: \(startDate)")
                    }
                    
                    
                    Spacer()
                    
                    Button {
                        showingEditProject.toggle()
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }.padding(.trailing, 8)
                        .sheet(isPresented: $showingEditProject, content: {
                            if let client = self.project.client {
                                EditProject(isPresented: $showingEditProject, client: client, project: self.project)
                            }
                        })
                }
                .padding(.vertical, 4)
            }
            
            HStack {
                Text("Billables")
                    .bold().padding(.bottom, 4)
                Spacer()
                
                Button {
                    showingCreateProjectBillable.toggle()
                } label: {
                    Label("Add", systemImage: "plus")
                }.padding(.trailing, 8)
                    .sheet(isPresented: $showingCreateProjectBillable, content: {
                        ProjectBillables(isPresented: $showingEditProjectBillable, project: self.project, billable: Billable.emptyBillable)
                    })
                
            }.padding()
            
            Table(billables) {
                TableColumn("Details", value: \.details)
                TableColumn("Start") { billable in
                    Text(formatDate(billable.start))
                }
                TableColumn("End") { billable in
                    Text(formatDate(billable.end))
                }
                TableColumn("Rate") { billable in
                    Text(billable.rate.name)
                }
                TableColumn("Total") { billable in
                    Text(formatTotal(billable))
                }
                TableColumn("Status") { billable in
                    Text(billable.status?.rawValue ?? "new")
                }
                TableColumn("Actions") { billable in
                    HStack {
                        Button {
                            editBillable(billable)
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }.padding(.trailing, 8)
                        
                        Button {
                            if let idx = project.billables.firstIndex(of: billable) {
                                modelData.delete(billable)
                                project.billables.remove(at: idx)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }.padding(.trailing, 8)
                    }
                }
                
                
            }
            .frame(minHeight: (minRowHeight * 1.3)+(minRowHeight * CGFloat(max(project.billables.count, 5))))
            .onAppear() {
                self.billables = project.billables.sorted { $0.start < $1.start }
            }
            .onChange(of: project.billables) { oldValue, newValue in
                self.billables = project.billables.sorted { $0.start < $1.start }
            }
            .sheet(item: $selectedBillable) { item in
                ProjectBillables(isPresented: $showingEditProjectBillable, project: self.project, billable: item)
            }
            HStack {
                Text("Invoices")
                    .bold().padding(.bottom, 4)
                Spacer()
            }.padding()
            
            ForEach(project.invoices) { invoice in
                InvoiceRow(invoice: invoice, project: project).padding()
            }
            
            
            Button {
                showingCreateInvoice.toggle()
            } label: {
                Label("Create Invoice", systemImage: "document.badge.ellipsis")
            }.padding(.trailing, 8)
                .sheet(isPresented: $showingCreateInvoice, content: {
                    ProjectInvoice(isPresented: $showingCreateInvoice, project: self.project)
                })
        }
        .padding()
        .background(.indigo.opacity(0.1))
        .foregroundColor(.black)
        .cornerRadius(15)

    }
    
    func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: date)
    }
    
    func editBillable(_ billable: Billable) {
        print("Editing \(billable.details)")
        selectedBillable = billable
    }
    
    func formatTotal(_ billable: Billable) -> String {
        let billableHelper = BillableHelper()
        
        let interval = billableHelper.numberOfSegments(for: billable.rate.timeInterval, between: billable.start, and: billable.end)

        return "\(billable.rate.currency) \((interval * billable.rate.amount) / billable.rate.timeUnit)"
    }
}

#Preview {
    return Group {
        ProjectRow(project: ModelData.shared.project)
    }
}

