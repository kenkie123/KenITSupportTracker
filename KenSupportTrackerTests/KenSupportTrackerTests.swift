import XCTest
@testable import KenSupportTracker

final class TestTicketRepository: TicketRepository {
    var tickets: [SupportTicket] = []
    var failLoading = false
    var failSaving = false
    func loadTickets() throws -> [SupportTicket] {
        if failLoading {
            throw TicketStorageError.loadFailed
        }

        return tickets
    }

    func saveTickets(_ tickets: [SupportTicket]) throws {
        if failSaving {
            throw TicketStorageError.saveFailed
        }

        self.tickets = tickets
    }
}

@MainActor
final class KenSupportTrackerTests: XCTestCase {


    private func makeTicket() -> SupportTicket {
        SupportTicket(
            title: "Printer offline",
            issueDescription: "Reception cannot print tickets.",
            requesterName: "Jamie",
            location: "Reception"
        )
    }

    private func makeAssignedTicket() -> SupportTicket {
        var ticket = makeTicket()
        ticket.technicianName = "Kenneth"
        ticket.status = .pending
        return ticket
    }

    private func submitTestTicket(
        to repository: TestTicketRepository,
        title: String = "Printer offline",
        description: String = "Reception cannot print tickets.",
        requester: String = "Jamie",
        location: String = "Reception"
    ) throws -> SupportTicket {
        let useCase = SubmitSupportTicketUseCase(
            repository: repository
        )

        return try useCase.execute(
            title: title,
            issueDescription: description,
            requesterName: requester,
            location: location
        )
    }
    
    func test_submitTicket_savesValidTicketAsOpen() throws {
        let repository = TestTicketRepository()

        let ticket = try submitTestTicket(to: repository)

        XCTAssertEqual(repository.tickets.count, 1)
        XCTAssertEqual(repository.tickets.first?.id, ticket.id)
        XCTAssertEqual(
            repository.tickets.first?.title,
            "Printer offline"
        )
        XCTAssertEqual(ticket.status, .open)
        XCTAssertEqual(repository.tickets.first?.status, .open)
        XCTAssertNil(ticket.technicianName)
        XCTAssertNil(ticket.resolutionNotes)
    }

    func test_submitTicket_rejectsWhitespaceOnlyTitle() {
        let repository = TestTicketRepository()

        XCTAssertThrowsError(
            try submitTestTicket(
                to: repository,
                title: "   \n "
            )
        ) { error in
            guard case SubmitTicketError.missingTitle = error else {
                XCTFail("Expected the missing title error.")
                return
            }
        }

        XCTAssertTrue(repository.tickets.isEmpty)
    }

    func test_submitTicket_acceptsTitleOf100Characters() throws {
        let repository = TestTicketRepository()
        let title = String(repeating: "A", count: 100)

        let ticket = try submitTestTicket(
            to: repository,
            title: title
        )

        XCTAssertEqual(ticket.title, title)
        XCTAssertEqual(repository.tickets.count, 1)
        XCTAssertEqual(repository.tickets.first?.title, title)
    }

    func test_submitTicket_rejectsTitleOver100Characters() {
        let repository = TestTicketRepository()
        let title = String(repeating: "A", count: 101)

        XCTAssertThrowsError(
            try submitTestTicket(
                to: repository,
                title: title
            )
        ) { error in
            guard case SubmitTicketError.titleTooLong = error else {
                XCTFail("Expected the title too long error.")
                return
            }
        }

        XCTAssertTrue(repository.tickets.isEmpty)
    }

    func test_submitTicket_rejectsMissingDescription() {
        let repository = TestTicketRepository()

        XCTAssertThrowsError(
            try submitTestTicket(
                to: repository,
                description: "   "
            )
        ) { error in
            guard case SubmitTicketError.missingDescription = error else {
                XCTFail("Expected the missing description error.")
                return
            }
        }

        XCTAssertTrue(repository.tickets.isEmpty)
    }

    func test_submitTicket_rejectsMissingRequester() {
        let repository = TestTicketRepository()

        XCTAssertThrowsError(
            try submitTestTicket(
                to: repository,
                requester: "   "
            )
        ) { error in
            guard case SubmitTicketError.missingRequester = error else {
                XCTFail("Expected the missing requester error.")
                return
            }
        }

        XCTAssertTrue(repository.tickets.isEmpty)
    }

    func test_submitTicket_rejectsMissingLocation() {
        let repository = TestTicketRepository()

        XCTAssertThrowsError(
            try submitTestTicket(
                to: repository,
                location: "   "
            )
        ) { error in
            guard case SubmitTicketError.missingLocation = error else {
                XCTFail("Expected the missing location error.")
                return
            }
        }

        XCTAssertTrue(repository.tickets.isEmpty)
    }

    func test_submitTicket_preservesRegisterWhenLoadingFails() {
        let repository = TestTicketRepository()
        let existingTicket = makeTicket()
        repository.tickets = [existingTicket]
        repository.failLoading = true

        XCTAssertThrowsError(
            try submitTestTicket(to: repository)
        ) { error in
            guard case SubmitTicketError.loadFailed = error else {
                XCTFail("Expected the load failed error.")
                return
            }
        }

        XCTAssertEqual(repository.tickets.count, 1)
        XCTAssertEqual(
            repository.tickets.first?.id,
            existingTicket.id
        )
    }

    func test_submitTicket_doesNotAddTicketWhenSavingFails() {
        let repository = TestTicketRepository()
        let existingTicket = makeTicket()
        repository.tickets = [existingTicket]
        repository.failSaving = true

        XCTAssertThrowsError(
            try submitTestTicket(to: repository)
        ) { error in
            guard case SubmitTicketError.saveFailed = error else {
                XCTFail("Expected the save failed error.")
                return
            }
        }

        XCTAssertEqual(repository.tickets.count, 1)
        XCTAssertEqual(
            repository.tickets.first?.id,
            existingTicket.id
        )
    }

    func test_assignTicket_savesTechnicianAndChangesStatus() throws {
        let repository = TestTicketRepository()
        let ticket = makeTicket()
        repository.tickets = [ticket]

        let useCase = AssignSupportTicketUseCase(
            repository: repository
        )

        let updatedTicket = try useCase.execute(
            ticketID: ticket.id,
            technicianName: "Kenneth"
        )

        XCTAssertEqual(updatedTicket.id, ticket.id)
        XCTAssertEqual(updatedTicket.technicianName, "Kenneth")
        XCTAssertEqual(updatedTicket.status, .pending)
        XCTAssertEqual(repository.tickets.count, 1)
        XCTAssertEqual(
            repository.tickets.first?.technicianName,
            "Kenneth"
        )
        XCTAssertEqual(repository.tickets.first?.status, .pending)
    }

    func test_assignTicket_rejectsBlankTechnicianName() {
        let repository = TestTicketRepository()
        let ticket = makeTicket()
        repository.tickets = [ticket]

        let useCase = AssignSupportTicketUseCase(
            repository: repository
        )

        XCTAssertThrowsError(
            try useCase.execute(
                ticketID: ticket.id,
                technicianName: "   "
            )
        ) { error in
            guard case AssignTicketError.missingTechnician = error else {
                XCTFail("Expected the missing technician error.")
                return
            }
        }

        XCTAssertEqual(repository.tickets.first?.status, .open)
        XCTAssertNil(repository.tickets.first?.technicianName)
    }

    func test_assignTicket_rejectsAlreadyResolvedTicket() {
        let repository = TestTicketRepository()
        var ticket = makeAssignedTicket()
        ticket.status = .resolved
        ticket.resolutionNotes = "Printer repaired."
        repository.tickets = [ticket]

        let useCase = AssignSupportTicketUseCase(
            repository: repository
        )

        XCTAssertThrowsError(
            try useCase.execute(
                ticketID: ticket.id,
                technicianName: "Alex"
            )
        ) { error in
            guard case AssignTicketError.alreadyResolved = error else {
                XCTFail("Expected the already resolved error.")
                return
            }
        }

        XCTAssertEqual(repository.tickets.first?.status, .resolved)
        XCTAssertEqual(
            repository.tickets.first?.technicianName,
            "Kenneth"
        )
        XCTAssertEqual(
            repository.tickets.first?.resolutionNotes,
            "Printer repaired."
        )
    }

    func test_assignTicket_rejectsMissingTicket() {
        let repository = TestTicketRepository()

        let useCase = AssignSupportTicketUseCase(
            repository: repository
        )

        XCTAssertThrowsError(
            try useCase.execute(
                ticketID: UUID(),
                technicianName: "Kenneth"
            )
        ) { error in
            guard case AssignTicketError.ticketNotFound = error else {
                XCTFail("Expected the ticket not found error.")
                return
            }
        }

        XCTAssertTrue(repository.tickets.isEmpty)
    }

    func test_assignTicket_reportsLoadingFailure() {
        let repository = TestTicketRepository()
        let ticket = makeTicket()
        repository.tickets = [ticket]
        repository.failLoading = true

        let useCase = AssignSupportTicketUseCase(
            repository: repository
        )

        XCTAssertThrowsError(
            try useCase.execute(
                ticketID: ticket.id,
                technicianName: "Kenneth"
            )
        ) { error in
            guard case AssignTicketError.loadFailed = error else {
                XCTFail("Expected the load failed error.")
                return
            }
        }

        XCTAssertEqual(repository.tickets.first?.status, .open)
        XCTAssertNil(repository.tickets.first?.technicianName)
    }

    func test_assignTicket_preservesTicketWhenSavingFails() {
        let repository = TestTicketRepository()
        let ticket = makeTicket()
        repository.tickets = [ticket]
        repository.failSaving = true

        let useCase = AssignSupportTicketUseCase(
            repository: repository
        )

        XCTAssertThrowsError(
            try useCase.execute(
                ticketID: ticket.id,
                technicianName: "Kenneth"
            )
        ) { error in
            guard case AssignTicketError.saveFailed = error else {
                XCTFail("Expected the save failed error.")
                return
            }
        }

        XCTAssertEqual(repository.tickets.first?.status, .open)
        XCTAssertNil(repository.tickets.first?.technicianName)
    }
    func test_resolveTicket_savesNotesAndResolvedStatus() throws {
        let repository = TestTicketRepository()
        let ticket = makeAssignedTicket()
        repository.tickets = [ticket]

        let useCase = ResolveSupportTicketUseCase(
            repository: repository
        )

        let notes = "Reconnected the printer and printed a test ticket."

        let updatedTicket = try useCase.execute(
            ticketID: ticket.id,
            resolutionNotes: notes
        )

        XCTAssertEqual(updatedTicket.id, ticket.id)
        XCTAssertEqual(updatedTicket.status, .resolved)
        XCTAssertEqual(updatedTicket.resolutionNotes, notes)
        XCTAssertEqual(repository.tickets.count, 1)
        XCTAssertEqual(repository.tickets.first?.status, .resolved)
        XCTAssertEqual(
            repository.tickets.first?.resolutionNotes,
            notes
        )
        XCTAssertEqual(
            repository.tickets.first?.technicianName,
            "Kenneth"
        )
    }

    func test_resolveTicket_rejectsBlankResolutionNotes() {
        let repository = TestTicketRepository()
        let ticket = makeAssignedTicket()
        repository.tickets = [ticket]

        let useCase = ResolveSupportTicketUseCase(
            repository: repository
        )

        XCTAssertThrowsError(
            try useCase.execute(
                ticketID: ticket.id,
                resolutionNotes: "   "
            )
        ) { error in
            guard case ResolveTicketError.notesRequired = error else {
                XCTFail("Expected the notes required error.")
                return
            }
        }

        XCTAssertEqual(repository.tickets.first?.status, .pending)
        XCTAssertNil(repository.tickets.first?.resolutionNotes)
    }

    func test_resolveTicket_rejectsUnassignedTicket() {
        let repository = TestTicketRepository()
        let ticket = makeTicket()
        repository.tickets = [ticket]

        let useCase = ResolveSupportTicketUseCase(
            repository: repository
        )

        XCTAssertThrowsError(
            try useCase.execute(
                ticketID: ticket.id,
                resolutionNotes: "Printer repaired."
            )
        ) { error in
            guard case ResolveTicketError.technicianRequired = error else {
                XCTFail("Expected the technician required error.")
                return
            }
        }

        XCTAssertEqual(repository.tickets.first?.status, .open)
        XCTAssertNil(repository.tickets.first?.resolutionNotes)
    }

    func test_resolveTicket_rejectsAlreadyResolvedTicket() {
        let repository = TestTicketRepository()
        var ticket = makeAssignedTicket()
        ticket.status = .resolved
        ticket.resolutionNotes = "Original fix."
        repository.tickets = [ticket]

        let useCase = ResolveSupportTicketUseCase(
            repository: repository
        )

        XCTAssertThrowsError(
            try useCase.execute(
                ticketID: ticket.id,
                resolutionNotes: "Replacement notes."
            )
        ) { error in
            guard case ResolveTicketError.alreadyResolved = error else {
                XCTFail("Expected the already resolved error.")
                return
            }
        }

        XCTAssertEqual(repository.tickets.first?.status, .resolved)
        XCTAssertEqual(
            repository.tickets.first?.resolutionNotes,
            "Original fix."
        )
    }

    func test_resolveTicket_rejectsMissingTicket() {
        let repository = TestTicketRepository()

        let useCase = ResolveSupportTicketUseCase(
            repository: repository
        )

        XCTAssertThrowsError(
            try useCase.execute(
                ticketID: UUID(),
                resolutionNotes: "Printer repaired."
            )
        ) { error in
            guard case ResolveTicketError.ticketNotFound = error else {
                XCTFail("Expected the ticket not found error.")
                return
            }
        }

        XCTAssertTrue(repository.tickets.isEmpty)
    }

    func test_resolveTicket_reportsLoadingFailure() {
        let repository = TestTicketRepository()
        let ticket = makeAssignedTicket()
        repository.tickets = [ticket]
        repository.failLoading = true

        let useCase = ResolveSupportTicketUseCase(
            repository: repository
        )

        XCTAssertThrowsError(
            try useCase.execute(
                ticketID: ticket.id,
                resolutionNotes: "Printer repaired."
            )
        ) { error in
            guard case ResolveTicketError.loadFailed = error else {
                XCTFail("Expected the load failed error.")
                return
            }
        }

        XCTAssertEqual(repository.tickets.first?.status, .pending)
        XCTAssertNil(repository.tickets.first?.resolutionNotes)
    }

    func test_resolveTicket_preservesTicketWhenSavingFails() {
        let repository = TestTicketRepository()
        let ticket = makeAssignedTicket()
        repository.tickets = [ticket]
        repository.failSaving = true

        let useCase = ResolveSupportTicketUseCase(
            repository: repository
        )

        XCTAssertThrowsError(
            try useCase.execute(
                ticketID: ticket.id,
                resolutionNotes: "Printer repaired."
            )
        ) { error in
            guard case ResolveTicketError.saveFailed = error else {
                XCTFail("Expected the save failed error.")
                return
            }
        }
        XCTAssertEqual(repository.tickets.first?.status, .pending)
        XCTAssertNil(repository.tickets.first?.resolutionNotes)
        XCTAssertEqual(
            repository.tickets.first?.technicianName,
            "Kenneth"
        )
    }
}
