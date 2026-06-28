import Foundation

// ⚠️ ENTREGA ACADÊMICA: DTO de requisição para POST /users/login
struct PhoneLoginRequestDTO: Encodable {
    let phone: String
    let uuid: String
}

