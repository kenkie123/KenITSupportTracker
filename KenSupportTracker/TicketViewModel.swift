//
//  TicketViewModel.swift
//  KenSupportTracker
//
//  Created by Kenneth Lee on 9/7/26.
//

import Foundation
import Combine

// Holds ticket list, loads it from local storage
class TicketViewModel: ObservableObject {
    @Published var tickets: [SupportTicket] = []
    @Published var errorMessage = ""
    @Published var showingError = false

    private let repository: TicketRepository

    init(repository: TicketRepository = LocalTicketRepository()) {
        self.repository = repository
        loadTickets()
    }

    func loadTickets() {
        do {
            tickets = try repository.loadTickets()
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
    
    func submitTicket(
        title: String,
        issueDescription: String,
        requesterName: String,
        location: String
    ) throws {
        let useCase = SubmitSupportTicketUseCase(repository: repository)

        let ticket = try useCase.execute(
            title: title,
            issueDescription: issueDescription,
            requesterName: requesterName,
            location: location
        )
        tickets.append(ticket)
    }
}
