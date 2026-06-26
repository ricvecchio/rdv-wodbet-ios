import Foundation

struct Participant: Identifiable, Equatable {
    let id: String
    let name: String
    let email: String?
    let phone: String?
    let createdAt: Date
}

