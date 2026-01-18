import Foundation

struct AppUser: Identifiable, Equatable {
    let id: String
    let displayName: String
    let photoURL: String?
    let createdAt: Date
}
