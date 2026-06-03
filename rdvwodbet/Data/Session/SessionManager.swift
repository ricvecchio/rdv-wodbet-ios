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
        static let userId       = "session_userId"
        static let phone        = "session_phone"
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

    /// Salva o usuário logado localmente e atualiza o estado publicado.
    func save(user: AppUser) {
        defaults.set(true,                         forKey: Keys.isLoggedIn)
        defaults.set(user.id,                      forKey: Keys.userId)
        defaults.set(user.phone ?? "",             forKey: Keys.phone)
        defaults.set(user.displayName,             forKey: Keys.name)
        defaults.set(user.createdAt.timeIntervalSince1970, forKey: Keys.createdAt)
        currentUser = user
    }

    /// Atualiza apenas o displayName na sessão (usado após onboarding de nome).
    func updateDisplayName(_ name: String) {
        guard let user = currentUser else { return }
        defaults.set(name, forKey: Keys.name)
        let updated = AppUser(
            id: user.id,
            displayName: name,
            photoURL: user.photoURL,
            createdAt: user.createdAt,
            phone: user.phone
        )
        currentUser = updated
    }

    /// Remove a sessão local e desloga o usuário.
    func clear() {
        defaults.removeObject(forKey: Keys.isLoggedIn)
        defaults.removeObject(forKey: Keys.userId)
        defaults.removeObject(forKey: Keys.phone)
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
        else { return }

        let phone     = defaults.string(forKey: Keys.phone)
        let name      = defaults.string(forKey: Keys.name) ?? ""
        let ts        = defaults.double(forKey: Keys.createdAt)
        let createdAt = ts > 0 ? Date(timeIntervalSince1970: ts) : Date()

        currentUser = AppUser(
            id: userId,
            displayName: name,
            photoURL: nil,
            createdAt: createdAt,
            phone: phone
        )
    }
}

