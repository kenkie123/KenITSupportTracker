//
//  TicketViewModel.swift
//  KenSupportTracker
//
//  Created by Kenneth Lee on 9/7/26.
//

import Foundation
import Combine

class TicketViewModel: ObservableObject {

    @Published var tickets: [SupportTicket] = [
        SupportTicket(
            title: "Kiosk not printing tickets",
            issueDescription: "The kiosk responds, but no ticket prints after selecting a service.",
            requesterName: "Jamie Wilson",
            location: "Demo Centre - Reception"
        ),
        SupportTicket(
            title: "Queue display not updating",
            issueDescription: "The screen still shows the previous ticket number.",
            requesterName: "Morgan Lee",
            location: "Demo Centre - Waiting Area"
        ),
        SupportTicket(
            title: "Staff member cannot sign in",
            issueDescription: "A staff member cannot access the queue calling application.",
            requesterName: "Taylor Brown",
            location: "Demo Centre - Counter 3"
        )
    ]
}
