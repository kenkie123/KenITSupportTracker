import SwiftUI
struct ContentView: View {
    @StateObject private var viewModel = TicketViewModel()
    @State private var showingCreateTicket = false

    var body: some View {
        NavigationStack {
        List {
            Section("Support Team") {
                Text("Track or log IT issues.")
            }

                Section("Tickets") {
                    if viewModel.tickets.isEmpty {
                    Text("No tickets pending")
                        .foregroundStyle(.secondary)
                    }

                    ForEach(viewModel.tickets) { ticket in
                        NavigationLink {
                            TicketDetailedView(
                                viewModel: viewModel,
                                ticketID: ticket.id
                            )
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
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reload") {
                        viewModel.loadTickets()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("New Ticket") {
                        showingCreateTicket = true
                    }
                }
            }
            .sheet(isPresented: $showingCreateTicket) {
                CreateTicketView(viewModel: viewModel)
            }
            .alert(
                "Unable to load tickets",
                isPresented: $viewModel.showingError
            ) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
}
