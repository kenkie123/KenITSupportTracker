//
//  ContentView.swift
//  KenSupportTracker
//
//  Created by Kenneth Lee on 9/7/26.
//

import SwiftUI

struct ContentView: View {

    let tickets: [SupportTicket] = [
        SupportTicket(
            title: "Kiosk not printing tickets",
            issueDescription: "The kiosk responds, but no ticket prints after selecting a service.",
            requesterName: "Jamie Wilson",
            location: "Demo Centre - Reception"
        ),
        SupportTicket(
            title: "Queue display not updating",
            issueDescription: "The screen still shows the previous ticket number.",
            requesterName: "Morgan Lee",
            location: "Demo Centre - Waiting Area"
        ),
        SupportTicket(
            title: "Staff member cannot sign in",
            issueDescription: "A staff member cannot access the queue calling application.",
            requesterName: "Taylor Brown",
            location: "Demo Centre - Counter 3"
        )
    ]

    var body: some View {
        NavigationStack {
            List {
                Section("Support Team") {
                    Text("Track kiosk, display and staff access issues.")
                }

                Section("Tickets") {
                    ForEach(tickets) { ticket in
                        VStack(alignment: .leading) {
                            Text(ticket.title)
                                .font(.headline)

                            Text(ticket.location)
                                .font(.subheadline)

                            Text("Status: \(ticket.status.rawValue)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("KenSupport")
        }
    }
}
