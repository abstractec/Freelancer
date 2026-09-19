//
//  SidebarSelection.swift
//  Freelancer
//

import Foundation
import SwiftData

enum SidebarSelection: Hashable {
    case tasks
    case client(PersistentIdentifier)
    case project(PersistentIdentifier)
}
