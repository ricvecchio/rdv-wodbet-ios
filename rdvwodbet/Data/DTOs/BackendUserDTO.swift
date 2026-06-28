import Foundation

struct BackendUserDTO: Decodable {
    let id: String
    let name: String
    let phone: String
    let uuid: String?
    let active: Bool?
    let description: String?
    let photoUrl: String?
    let createdAt: String?
    let email: String?
    let roles: [String]?

    init(
    id: String,
    name: String,
    phone: String,
    uuid: String? = nil,
    active: Bool? = nil,
    description: String? = nil,
    photoUrl: String? = nil,
    createdAt: String? = nil,
    email: String? = nil,
    roles: [String]? = nil
    ) {
        self.id = id
        self.name = name
        self.phone = phone
        self.uuid = uuid
        self.active = active
        self.description = description
        self.photoUrl = photoUrl
        self.createdAt = createdAt
        self.email = email
        self.roles = roles
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
        case email
        case roles
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decodeFlexibleString(forKey: .id) ?? ""

        email = try container.decodeIfPresent(String.self, forKey: .email)

        let decodedName = try container.decodeIfPresent(String.self, forKey: .name)
        let decodedPhone = try container.decodeFlexibleString(forKey: .phone)

        name = decodedName?.isEmpty == false
        ? decodedName!
        : (email?.isEmpty == false ? email! : (decodedPhone?.isEmpty == false ? decodedPhone! : "Usuário"))

        phone = decodedPhone ?? ""

        uuid = try container.decodeFlexibleString(forKey: .uuid)
        active = try container.decodeIfPresent(Bool.self, forKey: .active)
        description = try container.decodeIfPresent(String.self, forKey: .description)

        let photoUrlPrimary = try container.decodeIfPresent(String.self, forKey: .photoUrl)
        let photoUrlLegacy = try container.decodeIfPresent(String.self, forKey: .photoURL)
        photoUrl = photoUrlPrimary ?? photoUrlLegacy

        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        roles = try container.decodeIfPresent([String].self, forKey: .roles)
    }
}

struct AuthServerSessionDTO {
    let jwt: String?
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
    let email: String?
    let roles: [String]?

    private enum CodingKeys: String, CodingKey {
        case token
        case jwt
        case accessToken
        case access_token
        case user
        case id
        case name
        case phone
        case uuid
        case active
        case description
        case photoUrl
        case photoURL
        case createdAt
        case email
        case roles
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        token = try container.decodeIfPresent(String.self, forKey: .token)
        jwt = try container.decodeIfPresent(String.self, forKey: .jwt)
        accessToken = try container.decodeIfPresent(String.self, forKey: .accessToken)
        ?? (try container.decodeIfPresent(String.self, forKey: .access_token))

        user = try container.decodeIfPresent(BackendUserDTO.self, forKey: .user)

        id = try container.decodeFlexibleString(forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        phone = try container.decodeFlexibleString(forKey: .phone)
        uuid = try container.decodeFlexibleString(forKey: .uuid)
        active = try container.decodeIfPresent(Bool.self, forKey: .active)
        description = try container.decodeIfPresent(String.self, forKey: .description)

        let primaryPhoto = try container.decodeIfPresent(String.self, forKey: .photoUrl)
        let legacyPhoto = try container.decodeIfPresent(String.self, forKey: .photoURL)
        photoUrl = primaryPhoto ?? legacyPhoto

        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        roles = try container.decodeIfPresent([String].self, forKey: .roles)
    }

    var resolvedToken: String? {
        token ?? jwt ?? accessToken
    }

    var resolvedUser: BackendUserDTO? {
        if let user { return user }

        guard let id else { return nil }

        let resolvedName =
        name?.isEmpty == false ? name! :
        email?.isEmpty == false ? email! :
        phone?.isEmpty == false ? phone! :
        "Usuário"

        return BackendUserDTO(
            id: id,
            name: resolvedName,
            phone: phone ?? "",
            uuid: uuid,
            active: active,
            description: description,
            photoUrl: photoUrl,
            createdAt: createdAt,
            email: email,
            roles: roles
        )
    }
}

// DTO para respostas de erro do backend (ex.: 400, 401, 404)
struct BackendErrorDTO: Decodable {
    let message: String?
    let error: String?
}

private extension KeyedDecodingContainer {
    func decodeFlexibleString(forKey key: Key) throws -> String? {
        if let stringValue = try decodeIfPresent(String.self, forKey: key) {
            return stringValue
        }

        if let intValue = try decodeIfPresent(Int.self, forKey: key) {
            return String(intValue)
        }

        if let int64Value = try decodeIfPresent(Int64.self, forKey: key) {
            return String(int64Value)
        }

        if let doubleValue = try decodeIfPresent(Double.self, forKey: key) {
            if doubleValue.truncatingRemainder(dividingBy: 1) == 0 {
                return String(Int64(doubleValue))
            }
            return String(doubleValue)
        }

        return nil
    }
}