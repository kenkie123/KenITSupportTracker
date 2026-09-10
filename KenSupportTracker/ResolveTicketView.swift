//
//  ResolveTicketView.swift
//  KenSupportTracker
//
//  Created by Kenneth Lee on 9/8/26.
//
import SwiftUI

struct ResolveTicketView: View {
    @ObservedObject var viewModel: TicketViewModel
    let ticketID: UUID

    @Environment(\.dismiss) private var dismiss

    @State private var resolutionNotes = ""
    @State private var showingConfirmation = false
    @State private var showingError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Ticket") {
                    Text(
                        viewModel.tickets.first {
                            $0.id == ticketID
                        }?.title ?? "Ticket unavailable"
                    )
                }

                Section("Resolution notes") {
                    TextField(
                        "Describe the fix and how you checked it",
                        text: $resolutionNotes,
                        axis: .vertical
                    )
                    .lineLimit(5...10)
                }

                Section {
                    Button("Mark as resolved") {
                        showingConfirmation = true
                    }
                }
            }
            .navigationTitle("Resolve Ticket")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .confirmationDialog(
                "Confirm this issue has been fixed?",
                isPresented: $showingConfirmation,
                titleVisibility: .visible
            ) {
                Button("Confirm resolution") {
                    resolveTicket()
                }

                Button("Keep editing", role: .cancel) { }
            }
            .alert(
                "Unable to resolve ticket",
                isPresented: $showingError
            ) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
        .interactiveDismissDisabled(!resolutionNotes.isEmpty)
    }

    private func resolveTicket() {
        do {
            try viewModel.resolveTicket(
                ticketID: ticketID,
                resolutionNotes: resolutionNotes
            )

            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
}
