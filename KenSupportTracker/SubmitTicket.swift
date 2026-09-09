//
//  SubmitTicket.swift
//  KenSupportTracker
//
//  Created by Kenneth Lee on 9/7/26.
//

import Foundation

struct SubmitSupportTicketUseCase {
    let repository: TicketRepository

    func execute(
        title: String,
        issueDescription: String,
        requesterName: String,
        location: String
    ) throws -> SupportTicket {

        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanDescription = issueDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanRequester = requesterName.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanLocation = location.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanTitle.isEmpty else {
            throw SubmitTicketError.missingTitle
        }

        guard !cleanDescription.isEmpty else {
            throw SubmitTicketError.missingDescription
        }

        guard !cleanRequester.isEmpty else {
            throw SubmitTicketError.missingRequester
        }

        guard !cleanLocation.isEmpty else {
            throw SubmitTicketError.missingLocation
        }

        guard cleanTitle.count <= 100 else {
            throw SubmitTicketError.titleTooLong
        }

        let ticket = SupportTicket(
            title: cleanTitle,
            issueDescription: cleanDescription,
            requesterName: cleanRequester,
            location: cleanLocation
        )

        var tickets: [SupportTicket]

        do {
            tickets = try repository.loadTickets()
        } catch {
            throw SubmitTicketError.loadFailed
        }

        tickets.append(ticket)

        do {
            try repository.saveTickets(tickets)
        } catch {
            throw SubmitTicketError.saveFailed
        }

        return ticket
    }
}

enum SubmitTicketError: LocalizedError {
    case missingTitle
    case missingDescription
    case missingRequester
    case missingLocation
    case titleTooLong
    case loadFailed
    case saveFailed

    var errorDescription: String? {
        switch self {
        case .missingTitle:
            return "Enter a title describing the issue."

        case .missingDescription:
            return "Describe the issue in the description."

        case .missingRequester:
            return "Enter the name of the person reporting the issue."

        case .missingLocation:
            return "Enter the affected site or location."

        case .titleTooLong:
            return "Keep the title short and under 100 characters. Put extra details in the description."

        case .loadFailed:
            return "Existing tickets could not be loaded. Keep your form open and try again. No new ticket has been saved."

        case .saveFailed:
            return "Your ticket could not be saved. Keep your form open, check device storage and try again."
        }
    }
}
