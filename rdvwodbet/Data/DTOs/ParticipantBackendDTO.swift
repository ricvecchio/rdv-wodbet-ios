import Foundation

struct ParticipantBackendDTO: Decodable {
    let id: String
    let name: String
    let email: String?
    let phone: String?
    let createdAt: String?

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case phone
        case createdAt
    }
}

struct BackendCreateParticipantRequestDTO: Encodable {
    let name: String
    let email: String?
    let phone: String?
}

struct BackendUpdateParticipantRequestDTO: Encodable {
    let name: String?
    let phone: String?
}

