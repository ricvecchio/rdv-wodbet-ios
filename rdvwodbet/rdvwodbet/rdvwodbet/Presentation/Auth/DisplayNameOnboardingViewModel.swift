import Foundation
import Combine

@MainActor
final class DisplayNameOnboardingViewModel: ObservableObject {
    @Published var displayName: String = ""
    @Published var isSaving: Bool = false
    @Published var errorMessage: String?

    private let uid: String
    private let userRepository: UserRepository
    private let onFinished: () -> Void

    private var cancellables = Set<AnyCancellable>()

    init(uid: String, userRepository: UserRepository, onFinished: @escaping () -> Void) {
        self.uid = uid
        self.userRepository = userRepository
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

        userRepository.createUserIfNeeded(uid: uid, displayName: displayName, photoURL: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isSaving = false
                if case .failure(let err) = completion {
                    self.errorMessage = err.localizedDescription
                } else {
                    self.onFinished()
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
}
