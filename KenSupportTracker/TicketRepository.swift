//
//  TicketRepository.swift
//  KenSupportTracker
//
//  Created by Kenneth Lee on 9/7/26.
//
import Foundation
protocol TicketRepository {
    func loadTickets() throws -> [SupportTicket]
    func saveTickets(_ tickets: [SupportTicket]) throws
}

//json
class LocalTicketRepository: TicketRepository {
    private let fileURL: URL

    init() {
        let folder = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        )[0]

        fileURL = folder
            .appendingPathComponent("KenSupportTracker")
            .appendingPathComponent("tickets.json")
    }

    func loadTickets() throws -> [SupportTicket] {
        // no saved register when the app start
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return []
        }

        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode(
                [SupportTicket].self,
                from: data
            )
        } catch {
            throw TicketStorageError.loadFailed
        }
    }

    func saveTickets(_ tickets: [SupportTicket]) throws {
        do {
            let folder = fileURL.deletingLastPathComponent()
            try FileManager.default.createDirectory(
                at: folder,
                withIntermediateDirectories: true
            )

            let data = try JSONEncoder().encode(tickets)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            throw TicketStorageError.saveFailed
        }
    }
}

//Eror shown to tech
enum TicketStorageError: LocalizedError {
    case loadFailed
    case saveFailed

    var errorDescription: String? {
        switch self {
        case .loadFailed:
            return "Saved tickets could not be opened.Please reload."

        case .saveFailed:
            return "Your ticket changes couldnt be saved."
        }
    }
}
