import Foundation
import Combine

@MainActor
final class AuthViewModel: ObservableObject {

    enum State: Equatable {
        case loading
        case loggedOut
        case needsDisplayName(uid: String)
        case loggedIn(user: AppUser)
    }

    @Published private(set) var state: State = .loading
    @Published var errorMessage: String?

    private let observeAuthStateUseCase: ObserveAuthStateUseCase
    private let userRepository: UserRepository
    private let authRepository: AuthRepository

    private var cancellables = Set<AnyCancellable>()
    private var currentUID: String?

    init(
        observeAuthStateUseCase: ObserveAuthStateUseCase,
        userRepository: UserRepository,
        authRepository: AuthRepository
    ) {
        self.observeAuthStateUseCase = observeAuthStateUseCase
        self.userRepository = userRepository
        self.authRepository = authRepository

        bind()
    }

    private func bind() {
        observeAuthStateUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] uid in
                guard let self else { return }
                self.currentUID = uid
                if let uid {
                    self.loadUser(uid: uid)
                } else {
                    self.state = .loggedOut
                }
            }
            .store(in: &cancellables)
    }

    func refreshUserState() {
        guard let uid = currentUID else {
            state = .loggedOut
            return
        }
        loadUser(uid: uid)
    }

    private func loadUser(uid: String) {
        state = .loading
        userRepository.fetchUser(uid: uid)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let err) = completion {
                    self?.errorMessage = err.localizedDescription
                    self?.state = .loggedOut
                }
            } receiveValue: { [weak self] user in
                guard let self else { return }
                if let user {
                    self.state = .loggedIn(user: user)
                } else {
                    self.state = .needsDisplayName(uid: uid)
                }
            }
            .store(in: &cancellables)
    }

    func signOut() {
        do {
            try authRepository.signOut()
        } catch {
            errorMessage = "Falha ao sair."
        }
    }

    /// Aqui fica um placeholder: no passo seguinte vamos implementar Sign In with Apple de verdade.
    func mockLoginForDev(uid: String = "dev-user-123") {
        // Em produção, isso some. É só para conseguir navegar enquanto o Apple Sign In não entra.
        self.currentUID = uid
        self.state = .needsDisplayName(uid: uid)
    }
}
