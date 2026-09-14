import Foundation

/// Records the fix and marks an assigned, pending ticket as resolved. Resolution notes are required, and already resolved tickets are rejected.
struct ResolveSupportTicketUseCase {
    let repository: TicketRepository

    func execute(
        ticketID: UUID,
        resolutionNotes: String
    ) throws -> SupportTicket {

        let cleanNotes = resolutionNotes.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        var tickets: [SupportTicket]

        do {
            tickets = try repository.loadTickets()
        } catch {
            throw ResolveTicketError.loadFailed
        }

        guard let index = tickets.firstIndex(
            where: { $0.id == ticketID }
        ) else {
            throw ResolveTicketError.ticketNotFound
        }

        guard tickets[index].status != .resolved else {
            throw ResolveTicketError.alreadyResolved
        }

        let technicianName = tickets[index].technicianName ?? ""

        guard tickets[index].status == .pending,
              !technicianName.trimmingCharacters(
                in: .whitespacesAndNewlines
              ).isEmpty else {
            throw ResolveTicketError.technicianRequired
        }

        guard !cleanNotes.isEmpty else {
            throw ResolveTicketError.notesRequired
        }

        tickets[index].resolutionNotes = cleanNotes
        tickets[index].status = .resolved

        do {
            try repository.saveTickets(tickets)
        } catch {
            throw ResolveTicketError.saveFailed
        }

        return tickets[index]
    }
}

enum ResolveTicketError: LocalizedError {
    case ticketNotFound
    case alreadyResolved
    case technicianRequired
    case notesRequired
    case loadFailed
    case saveFailed

    var errorDescription: String? {
        switch self {
        case .ticketNotFound:
            return "This ticket could not be found. Return to the dashboard and reload."

        case .alreadyResolved:
            return "This ticket is already resolved.Resolution notes availaible in ticket details."

        case .technicianRequired:
            return "Assign name of technitian in ticket details before resolving this issue."

        case .notesRequired:
            return "Describe the fix and how you checked it before resolving the ticket."

        case .loadFailed:
            return "Tickets could not be loaded. Keep your notes open and try again."

        case .saveFailed:
            return "The resolution could not be saved. Keep your notes open, try again."
        }
    }
}
