import Foundation
import Combine

// ⚠️ ENTREGA ACADÊMICA: Gerenciador de sessão local via UserDefaults.
// Persiste o usuário autenticado pelo backend Java enquanto o Firebase Auth está suspenso.
// Para restaurar o Firebase, substitua as chamadas a SessionManager pelo fluxo
// ObserveAuthStateUseCase nos ViewModels e no RootView.

final class SessionManager: ObservableObject {

    // MARK: - Estado publicado

    @Published private(set) var currentUser: AppUser?
    /// true quando a verificação inicial da sessão foi concluída (permite exibir loading)
    @Published private(set) var isReady: Bool = false

    // MARK: - UserDefaults keys

    private enum Keys {
        static let isLoggedIn   = "session_isLoggedIn"
        static let jwt          = "session_jwt"
        static let userId       = "session_userId"
        static let phone        = "session_phone"
        static let description  = "session_description"
        static let photoURL     = "session_photoURL"
        static let name         = "session_name"
        static let uuid         = "session_uuid"
        static let createdAt    = "session_createdAt"
    }

    private let defaults: UserDefaults

    // MARK: - Init

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        loadSession()
    }

    // MARK: - API

    var authToken: String? {
        defaults.string(forKey: Keys.jwt)
    }

    var storedUUID: String? {
        defaults.string(forKey: Keys.uuid)
    }

    /// Salva o usuário logado localmente e atualiza o estado publicado.
    func save(user: AppUser) {
        defaults.set(true, forKey: Keys.isLoggedIn)
        defaults.set(user.id, forKey: Keys.userId)
        defaults.set(user.phone ?? defaults.string(forKey: Keys.phone) ?? "", forKey: Keys.phone)
        defaults.set(user.displayName, forKey: Keys.name)
        defaults.set(user.description ?? defaults.string(forKey: Keys.description) ?? "", forKey: Keys.description)
        defaults.set(user.photoURL ?? defaults.string(forKey: Keys.photoURL) ?? "", forKey: Keys.photoURL)
        defaults.set(defaults.string(forKey: Keys.uuid) ?? "", forKey: Keys.uuid)
        defaults.set(user.createdAt.timeIntervalSince1970, forKey: Keys.createdAt)
        currentUser = user
    }

    /// Salva JWT + usuário após autenticação no backend.
    func save(authSession: AuthSession) {
        defaults.set(true,                         forKey: Keys.isLoggedIn)
        if let jwt = authSession.jwt?.trimmingCharacters(in: .whitespacesAndNewlines), !jwt.isEmpty {
            defaults.set(jwt, forKey: Keys.jwt)
        } else {
            defaults.removeObject(forKey: Keys.jwt)
        }
        defaults.set(authSession.user.id,          forKey: Keys.userId)
        defaults.set(authSession.phone,            forKey: Keys.phone)
        defaults.set(authSession.user.displayName, forKey: Keys.name)
        defaults.set(authSession.user.description ?? "", forKey: Keys.description)
        defaults.set(authSession.user.photoURL ?? "", forKey: Keys.photoURL)
        defaults.set(authSession.uuid,             forKey: Keys.uuid)
        defaults.set(authSession.user.createdAt.timeIntervalSince1970, forKey: Keys.createdAt)
        currentUser = authSession.user
    }

    /// Atualiza apenas o displayName na sessão (usado após onboarding de nome).
    func updateDisplayName(_ name: String) {
        guard let user = currentUser else { return }
        defaults.set(name, forKey: Keys.name)
        let updated = AppUser(
            id: user.id,
            displayName: name,
            photoURL: user.photoURL,
            description: user.description,
            createdAt: user.createdAt,
            phone: user.phone
        )
        currentUser = updated
    }

    /// Remove a sessão local e desloga o usuário.
    func clear() {
        defaults.removeObject(forKey: Keys.isLoggedIn)
        defaults.removeObject(forKey: Keys.jwt)
        defaults.removeObject(forKey: Keys.userId)
        defaults.removeObject(forKey: Keys.phone)
        defaults.removeObject(forKey: Keys.description)
        defaults.removeObject(forKey: Keys.photoURL)
        defaults.removeObject(forKey: Keys.name)
        defaults.removeObject(forKey: Keys.uuid)
        defaults.removeObject(forKey: Keys.createdAt)
        currentUser = nil
    }

    // MARK: - Private

    private func loadSession() {
        defer { isReady = true }

        guard defaults.bool(forKey: Keys.isLoggedIn),
              let userId = defaults.string(forKey: Keys.userId), !userId.isEmpty
        else {
            clear()
            return
        }

        if let jwt = defaults.string(forKey: Keys.jwt),
           !jwt.isEmpty,
           !Self.isTokenLikelyValid(jwt) {
            clear()
            return
        }

        let phone     = defaults.string(forKey: Keys.phone)
        let description = defaults.string(forKey: Keys.description)
        let photoURL  = defaults.string(forKey: Keys.photoURL)
        let name      = defaults.string(forKey: Keys.name) ?? ""
        let ts        = defaults.double(forKey: Keys.createdAt)
        let createdAt = ts > 0 ? Date(timeIntervalSince1970: ts) : Date()

        currentUser = AppUser(
            id: userId,
            displayName: name,
            photoURL: photoURL?.isEmpty == true ? nil : photoURL,
            description: description?.isEmpty == true ? nil : description,
            createdAt: createdAt,
            phone: phone
        )
    }

    private static func isTokenLikelyValid(_ token: String) -> Bool {
        let parts = token.split(separator: ".")
        guard parts.count == 3 else { return true }
        var payload = String(parts[1])
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let padding = payload.count % 4
        if padding > 0 {
            payload.append(String(repeating: "=", count: 4 - padding))
        }
        guard let data = Data(base64Encoded: payload),
              let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let exp = object["exp"] as? TimeInterval
        else {
            return true
        }
        return Date().timeIntervalSince1970 < exp
    }
}

