//
//  ContentView.swift
//  KenSupportTracker
//
//  Created by Kenneth Lee on 9/7/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TicketViewModel()

    var body: some View {
        NavigationStack {
            List {
                Section("Support Team") {
                    Text("Track kiosk, display and staff access issues.")
                }

                Section("Tickets") {
                    ForEach(viewModel.tickets) { ticket in
                        NavigationLink {
                            TicketDetailView(ticket: ticket)
                        } label: {
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
            }
            .navigationTitle("KenSupport")
        }
    }
}
