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
    let photoUrl: String?
    let createdAt: String?

    init(
        id: String,
        name: String,
        phone: String,
        uuid: String? = nil,
        active: Bool? = nil,
        description: String? = nil,
        photoUrl: String? = nil,
        createdAt: String? = nil
    ) {
        self.id = id
        self.name = name
        self.phone = phone
        self.uuid = uuid
        self.active = active
        self.description = description
        self.photoUrl = photoUrl
        self.createdAt = createdAt
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case phone
        case uuid
        case active
        case description
        case photoUrl
        case photoURL
        case createdAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        phone = try container.decode(String.self, forKey: .phone)
        uuid = try container.decodeIfPresent(String.self, forKey: .uuid)
        active = try container.decodeIfPresent(Bool.self, forKey: .active)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        let photoUrlPrimary = try container.decodeIfPresent(String.self, forKey: .photoUrl)
        let photoUrlLegacy = try container.decodeIfPresent(String.self, forKey: .photoURL)
        photoUrl = photoUrlPrimary ?? photoUrlLegacy
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
    }
}

struct AuthServerSessionDTO {
    let jwt: String
    let user: BackendUserDTO
}

struct AuthServerResponseDTO: Decodable {
    let token: String?
    let jwt: String?
    let accessToken: String?
    let user: BackendUserDTO?

    let id: String?
    let name: String?
    let phone: String?
    let uuid: String?
    let active: Bool?
    let description: String?
    let photoUrl: String?
    let createdAt: String?

    var resolvedToken: String? {
        token ?? jwt ?? accessToken
    }

    var resolvedUser: BackendUserDTO? {
        if let user { return user }
        guard let id, let name, let phone else { return nil }
        return BackendUserDTO(
            id: id,
            name: name,
            phone: phone,
            uuid: uuid,
            active: active,
            description: description,
            photoUrl: photoUrl,
            createdAt: createdAt
        )
    }
}

// DTO para respostas de erro do backend (ex.: 400, 401, 404)
struct BackendErrorDTO: Decodable {
    let message: String?
    let error: String?
}

