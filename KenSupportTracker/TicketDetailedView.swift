import SwiftUI

struct TicketDetailedView: View {
    @ObservedObject var viewModel: TicketViewModel
    let ticketID: UUID
    @State private var technicianName = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showingResolution = false
    private var ticket: SupportTicket? {
        viewModel.tickets.first { $0.id == ticketID }
    }

    var body: some View {
        List {
            if let ticket = ticket {
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

                Section("Technician") {
                    Text(
                        "Assigned to: \(ticket.technicianName ?? "Unassigned")"
                    )

                    if ticket.status != .resolved {
                        TextField(
                            "Technician name",
                            text: $technicianName
                        )

                        Button("Assign technician") {
                            assignTechnician()
                        }
                    }
                }
                Section("Resolution") {
                    if ticket.status == .resolved {
                        Text(ticket.resolutionNotes ?? "No resolution notes recorded.")
                    } else {
                        Button("Resolve ticket") {
                            showingResolution = true
                        }
                    }
                }
                
            } else {
                Text("Ticket not found. Return to the dashboard and reload.")
            }
        }
        .navigationTitle("Ticket Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingResolution) {
            ResolveTicketView(
            viewModel: viewModel,
            ticketID: ticketID
            )
        }
        .onAppear {
            technicianName = ticket?.technicianName ?? ""
        }
        .alert(
            "Unable to assign technician",
            isPresented: $showingError
        ) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }

    private func assignTechnician() {
        do {
            try viewModel.assignTicket(
                ticketID: ticketID,
                technicianName: technicianName
            )
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
}
