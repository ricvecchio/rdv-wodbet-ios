import Foundation
import Combine

@MainActor
final class RegisterViewModel: ObservableObject {

    @Published var name: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var registrationSuccess: Bool = false

    private let authRepository: AuthRepository
    private let userRepository: UserRepository
    private var cancellables = Set<AnyCancellable>()

    init(authRepository: AuthRepository, userRepository: UserRepository) {
        self.authRepository = authRepository
        self.userRepository = userRepository
    }

    func signUp() {
        let nameTrimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let emailTrimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !nameTrimmed.isEmpty else { errorMessage = "Informe seu nome."; return }
        guard nameTrimmed.count >= 2 else { errorMessage = "O nome deve ter pelo menos 2 caracteres."; return }
        guard !emailTrimmed.isEmpty else { errorMessage = "Informe seu e-mail."; return }
        guard !password.isEmpty else { errorMessage = "Informe uma senha."; return }
        guard password.count >= 6 else { errorMessage = "A senha deve ter pelo menos 6 caracteres."; return }

        errorMessage = nil
        isLoading = true

        authRepository.signUp(email: emailTrimmed, password: password)
            .flatMap { [weak self] uid -> AnyPublisher<Void, AppError> in
                guard let self else { return Fail(error: .unknown).eraseToAnyPublisher() }
                return self.userRepository.createUserIfNeeded(uid: uid, displayName: nameTrimmed, photoURL: nil)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isLoading = false
                if case .failure(let err) = completion {
                    self.errorMessage = err.localizedDescription
                }
            } receiveValue: { [weak self] _ in
                self?.registrationSuccess = true
            }
            .store(in: &cancellables)
    }
}
