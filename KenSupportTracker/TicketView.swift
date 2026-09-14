import SwiftUI
struct CreateTicketView: View {
    @ObservedObject var viewModel: TicketViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var issueDescription = ""
    @State private var requesterName = ""
    @State private var location = ""
    @State private var errorMessage = ""
    @State private var showingError = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Issue") {
                    TextField("Ticket title", text: $title)

                    TextField(
                        "Describe the issue",
                        text: $issueDescription,
                        axis: .vertical
                    )
                    .lineLimit(3...6)
                }

                Section("Reported by") {
                    TextField("Requester name", text: $requesterName)
                    TextField("Site or location", text: $location)
                }

                Section {
                    Button("Submit ticket") {
                        submitTicket()
                    }
                }
            }
            .navigationTitle("Create Ticket")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert(
                "Ticket could not be submitted",
                isPresented: $showingError
            ) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }

    private func submitTicket() {
        do {
            try viewModel.submitTicket(
                title: title,
                issueDescription: issueDescription,
                requesterName: requesterName,
                location: location
            )

            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
}
