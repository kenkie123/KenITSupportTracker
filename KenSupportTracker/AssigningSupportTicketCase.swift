//
//  AssigningSupportTicketCase.swift
//  KenSupportTracker
//
//  Created by Kenneth Lee on 9/9/26.
//
import Foundation
struct AssignSupportTicketUseCase {
    let repository: TicketRepository

    func execute(
        ticketID: UUID,
        technicianName: String
    ) throws -> SupportTicket {

        let cleanName = technicianName.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !cleanName.isEmpty else {
            throw AssignTicketError.missingTechnician
        }

        var tickets: [SupportTicket]

        do {
            tickets = try repository.loadTickets()
        } catch {
            throw AssignTicketError.loadFailed
        }

        guard let index = tickets.firstIndex(
            where: { $0.id == ticketID }
        ) else {
            throw AssignTicketError.ticketNotFound
        }

        guard tickets[index].status != .resolved else {
            throw AssignTicketError.alreadyResolved
        }

        tickets[index].technicianName = cleanName
        tickets[index].status = .pending

        do {
            try repository.saveTickets(tickets)
        } catch {
            throw AssignTicketError.saveFailed
        }

        return tickets[index]
    }
}
enum AssignTicketError: LocalizedError {
    case missingTechnician
    case ticketNotFound
    case alreadyResolved
    case loadFailed
    case saveFailed

    var errorDescription: String? {
        switch self {
        case .missingTechnician:
            return "Enter the technician's name before assigning this ticket."

        case .ticketNotFound:
            return "This ticket could not be found. Return to the dashboard and reload."

        case .alreadyResolved:
            return "This ticket is already resolved. Create a new ticket if the issue has returned."

        case .loadFailed:
            return "Tickets could not be loaded. Return to the dashboard and try reloading before assigning."

        case .saveFailed:
            return "The assignment could not be saved. Check device storage and try again."
        }
    }
}
