import Foundation

// ⚠️ ENTREGA ACADÊMICA: DTO de requisição para PUT /users/{id}
struct UpdateUserProfileRequestDTO: Encodable {
    let name: String?
    let description: String?
    let phone: String?
    let photoUrl: String?
}

