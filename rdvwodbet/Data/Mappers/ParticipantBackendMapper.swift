import Foundation

enum ParticipantBackendMapper {
    static func toDomain(_ dto: ParticipantBackendDTO) -> Participant {
        Participant(
            id: dto.id,
            name: dto.name,
            email: dto.email,
            phone: dto.phone,
            createdAt: parseDate(dto.createdAt)
        )
    }

    private static func parseDate(_ raw: String?) -> Date {
        guard let raw else { return Date() }

        let formatterWithFractions: ISO8601DateFormatter = {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            return formatter
        }()

        let fallback = ISO8601DateFormatter()

        if let date = formatterWithFractions.date(from: raw) {
            return date
        }
        if let date = fallback.date(from: raw) {
            return date
        }
        return Date()
    }
}

