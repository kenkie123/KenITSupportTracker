//
//  TicketDetailedView.swift
//  KenSupportTracker
//
//  Created by Kenneth Lee on 9/7/26.
//

import SwiftUI

struct TicketDetailedView: View {
    let ticket: SupportTicket

    var body: some View {
        List {
            Section("Issue") {
                Text(ticket.title)
                    .font(.headline)

                Text(ticket.issueDescription)
            }

            Section("Reported by") {
                Text("Requester: \(ticket.requesterName)")
                Text("Location: \(ticket.location)")
            }

            Section("Ticket status") {
                Text(ticket.status.rawValue)

                Text(ticket.createdAt, style: .date)
            }
        }
        .navigationTitle("Ticket Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
