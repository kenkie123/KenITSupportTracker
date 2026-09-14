import Foundation
/// Records an IT issue reported at a service centre, including its requester, location, technician and resolution.
/// Business rules are enforced by the use cases such as new tickets requiring a title, description, requester and location. assignment requires a technician name and ther resolution requires pending status, a technician and resolution notes.
struct SupportTicket: Identifiable, Codable {
    var id = UUID()
    var title: String
    var issueDescription: String
    var requesterName: String
    var location: String
    
    var status: TicketStatus = .open
    var createdAt = Date()
    var technicianName: String?
    var resolutionNotes: String?
}
/// Represents a ticket's progress through the support workflow.
/// Tickets start as open, become pending when a technician is assigned, and become resolved when resolution notes are successfully saved. The assignment and resolution use cases reject resolved tickets.
enum TicketStatus: String, Codable, CaseIterable {
    case open = "Open"
    case pending = "Pending"
    case resolved = "Resolved"
}
