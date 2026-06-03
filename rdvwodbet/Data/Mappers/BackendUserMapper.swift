import Foundation

// ⚠️ ENTREGA ACADÊMICA: Mapper de BackendUserDTO → AppUser (domínio)
enum BackendUserMapper {

    static func toDomain(_ dto: BackendUserDTO) -> AppUser {
        let createdAt = parseDate(dto.createdAt)
        return AppUser(
            id: dto.id,
            displayName: dto.name,
            photoURL: nil,
            createdAt: createdAt,
            phone: dto.phone
        )
    }

    // MARK: - Private

    private static func parseDate(_ raw: String?) -> Date {
        guard let raw else { return Date() }
        // Tenta ISO 8601 com frações de segundo, depois sem
        let formatters: [ISO8601DateFormatter] = [
            {
                let f = ISO8601DateFormatter()
                f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                return f
            }(),
            ISO8601DateFormatter()
        ]
        for formatter in formatters {
            if let date = formatter.date(from: raw) { return date }
        }
        return Date()
    }
}

