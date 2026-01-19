import Foundation

enum AppUserMapper {

    static func toDomain(_ dto: AppUserDTO) -> AppUser {
        AppUser(
            id: dto.id,
            displayName: dto.displayName,
            photoURL: dto.photoURL,
            createdAt: dto.createdAt
        )
    }

    static func toFirestore(displayName: String, photoURL: String?) -> [String: Any] {
        var data: [String: Any] = [
            "displayName": displayName,
            "createdAt": Date()
        ]

        if let photoURL {
            data["photoURL"] = photoURL
        }

        return data
    }
}

