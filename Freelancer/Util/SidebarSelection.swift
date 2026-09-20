//
//  SidebarSelection.swift
//  Freelancer
//

import Foundation
import SwiftData

enum SidebarSelection: Hashable {
    case tasks
    case invoices
    case client(PersistentIdentifier)
    case project(PersistentIdentifier)
}
