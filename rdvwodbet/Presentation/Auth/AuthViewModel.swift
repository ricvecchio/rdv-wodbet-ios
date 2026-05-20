import Foundation
import Combine
import FirebaseAuth

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
    @Published var isLoading: Bool = false

    // Forgot password
    @Published var showForgotPassword: Bool = false
    @Published var forgotPasswordEmail: String = ""
    @Published var forgotPasswordMessage: String?
    @Published var isSendingReset: Bool = false

    private let observeAuthStateUseCase: ObserveAuthStateUseCase
    let userRepository: UserRepository
    let authRepository: AuthRepository

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
        isLoading = false

        userRepository.fetchUser(uid: uid)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                if case .failure(let err) = completion {
                    self.errorMessage = err.localizedDescription
                    self.state = .loggedOut
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

    func signInWithEmail(email: String, password: String) {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Preencha e-mail e senha."
            return
        }
        errorMessage = nil
        isLoading = true

        authRepository.signIn(email: email, password: password)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isLoading = false
                if case .failure(let err) = completion {
                    self.errorMessage = err.localizedDescription
                    self.state = .loggedOut
                }
            } receiveValue: { [weak self] uid in
                guard let self else { return }
                self.currentUID = uid
                self.loadUser(uid: uid)
            }
            .store(in: &cancellables)
    }

    func sendPasswordReset() {
        let email = forgotPasswordEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !email.isEmpty else {
            forgotPasswordMessage = "Digite seu e-mail."
            return
        }
        forgotPasswordMessage = nil
        isSendingReset = true

        authRepository.sendPasswordReset(email: email)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isSendingReset = false
                if case .failure(let err) = completion {
                    self.forgotPasswordMessage = err.localizedDescription
                } else {
                    self.forgotPasswordMessage = "E-mail enviado! Verifique sua caixa de entrada."
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }

    // ✅ DEV LOGIN REAL (Firebase Auth - Anônimo)
    func signInAnonymouslyForDev() {
        errorMessage = nil
        state = .loading

        Task {
            do {
                let result = try await Auth.auth().signInAnonymously()
                let uid = result.user.uid
                currentUID = uid
                loadUser(uid: uid)
            } catch {
                errorMessage = "Falha ao autenticar: \(error.localizedDescription)"
                state = .loggedOut
            }
        }
    }
}

