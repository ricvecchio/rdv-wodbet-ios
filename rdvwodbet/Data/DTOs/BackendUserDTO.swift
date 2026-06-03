import Foundation

// ⚠️ ENTREGA ACADÊMICA: DTO que representa a resposta do backend Java para usuário.
// Utilizado nas rotas POST /users/login (HTTP 200), POST /users/confirm (HTTP 200)
// e PUT /users/{id}.

struct BackendUserDTO: Decodable {
    let id: String
    let name: String
    let phone: String
    let uuid: String?
    let active: Bool?
    let description: String?
    let createdAt: String?
}

// DTO para respostas de erro do backend (ex.: 400, 401, 404)
struct BackendErrorDTO: Decodable {
    let message: String?
    let error: String?
}

