import Foundation

// ⚠️ ENTREGA ACADÊMICA: DTO de requisição para POST /users/confirm
struct PhoneConfirmRequestDTO: Encodable {
    let phone: String
    let uuid: String
    let code: String
}

