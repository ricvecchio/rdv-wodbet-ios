import Foundation
import Combine

// ⚠️ ENTREGA ACADÊMICA: ViewModel para onboarding de nome do usuário no fluxo backend.
// Utiliza UpdateUserProfileUseCase (PUT /users/{id}) em vez de Firestore.

@MainActor
final class BackendDisplayNameOnboardingViewModel: ObservableObject {

    @Published var displayName: String = ""
    @Published var isSaving: Bool = false
    @Published var errorMessage: String?

    private let user: AppUser
    private let updateUserProfileUseCase: UpdateUserProfileUseCase
    private let sessionManager: SessionManager
    private let onFinished: () -> Void
    private var cancellables = Set<AnyCancellable>()

    init(
        user: AppUser,
        updateUserProfileUseCase: UpdateUserProfileUseCase,
        sessionManager: SessionManager,
        onFinished: @escaping () -> Void
    ) {
        self.user = user
        self.updateUserProfileUseCase = updateUserProfileUseCase
        self.sessionManager = sessionManager
        self.onFinished = onFinished
    }

    func save() {
        do {
            try Validators.validateDisplayName(displayName)
        } catch let e as AppError {
            errorMessage = e.localizedDescription
            return
        } catch {
            errorMessage = "Erro inesperado."
            return
        }

        isSaving = true
        errorMessage = nil

        updateUserProfileUseCase
            .execute(userId: user.id, name: displayName.trimmingCharacters(in: .whitespacesAndNewlines))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isSaving = false
                if case .failure(let err) = completion {
                    self.errorMessage = err.localizedDescription
                }
            } receiveValue: { [weak self] updatedUser in
                guard let self else { return }
                self.sessionManager.save(user: updatedUser)
                self.onFinished()
            }
            .store(in: &cancellables)
    }
}

