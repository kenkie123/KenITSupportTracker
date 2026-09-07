//
//  SupportTicket.swift
//  KenSupportTracker
//
//  Created by Kenneth Lee on 9/7/26.
//

import Foundation

struct SupportTicket: Identifiable {
    let id = UUID()

    var title: String
    var issueDescription: String
    var requesterName: String
    var location: String

    var status: TicketStatus = .open
    var createdAt: Date = Date()

    var technicianName: String?
    var resolutionNotes: String?
}

enum TicketStatus: String, CaseIterable {
    case open = "Open"
    case inProgress = "In Progress"
    case resolved = "Resolved"
}
