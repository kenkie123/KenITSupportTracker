//
//  SupportTicket.swift
//  KenSupportTracker
//
//  Created by Kenneth Lee on 9/7/26.
//

import Foundation

struct SupportTicket: Identifiable, Codable {
    var id = UUID()

    var title: String
    var issueDescription: String
    var requesterName: String
    var location: String

    var status: TicketStatus = .open
    var createdAt = Date()

    var technicianName: String?
    var resolutionNotes: String?
}

enum TicketStatus: String, Codable, CaseIterable {
    case open = "Open"
    case pending = "Pending"
    case resolved = "Resolved"
}
