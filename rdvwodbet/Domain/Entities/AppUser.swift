import Foundation

struct AppUser: Identifiable, Equatable {
    let id: String
    let displayName: String
    let photoURL: String?
    let description: String?
    let createdAt: Date
    // ⚠️ ENTREGA ACADÊMICA: campo phone adicionado para suporte ao login via backend Java.
    // Firebase não usa este campo — pode ser removido ao restaurar o fluxo Firebase.
    let phone: String?

    // Inicializador compatível com o fluxo Firebase (phone omitido = nil)
    init(
        id: String,
        displayName: String,
        photoURL: String?,
        description: String? = nil,
        createdAt: Date,
        phone: String? = nil
    ) {
        self.id = id
        self.displayName = displayName
        self.photoURL = photoURL
        self.description = description
        self.createdAt = createdAt
        self.phone = phone
    }
}
