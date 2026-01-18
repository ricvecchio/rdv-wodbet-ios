import Foundation

struct AppUserDTO {
    let id: String
    let displayName: String
    let photoURL: String?
    let createdAt: Date

    init(id: String, data: [String: Any]) {
        self.id = id
        self.displayName = data["displayName"] as? String ?? "Sem nome"
        self.photoURL = data["photoURL"] as? String
        self.createdAt = (data["createdAt"] as? Date) ?? Date()
    }
}
