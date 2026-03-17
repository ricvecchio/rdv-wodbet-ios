import Foundation
import Combine

@MainActor
final class CreateBetViewModel: ObservableObject {
    @Published var users: [AppUser] = []
    @Published var selectedAUserId: String?
    @Published var selectedBUserId: String?
    @Published var wodTitle: String = ""
    @Published var prizeType: PrizeType = .water
    @Published var prizeOtherDescription: String = ""
    @Published var expiresAt: Date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()

    @Published var isSaving: Bool = false
    @Published var errorMessage: String?

    private let currentUser: AppUser
    private let userRepository: UserRepository
    private let createBetUseCase: CreateBetUseCase

    private var cancellables = Set<AnyCancellable>()

    init(
        currentUser: AppUser,
        userRepository: UserRepository,
        createBetUseCase: CreateBetUseCase
    ) {
        self.currentUser = currentUser
        self.userRepository = userRepository
        self.createBetUseCase = createBetUseCase

        loadUsers()
    }

    private func loadUsers() {
        userRepository.observeAllUsers()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let err) = completion {
                    self?.errorMessage = err.localizedDescription
                }
            } receiveValue: { [weak self] users in
                self?.users = users.sorted {
                    $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending
                }
            }
            .store(in: &cancellables)
    }

    func save(onSuccess: @escaping () -> Void) {
        guard let aId = selectedAUserId, let bId = selectedBUserId else {
            errorMessage = "Selecione os dois atletas."
            return
        }

        isSaving = true
        errorMessage = nil

        let otherDesc = (prizeType == .other) ? prizeOtherDescription : nil

        createBetUseCase.execute(
            createdByUserId: currentUser.id,
            athleteAUserId: aId,
            athleteBUserId: bId,
            wodTitle: wodTitle,
            prizeType: prizeType,
            prizeOtherDescription: otherDesc,
            expiresAt: expiresAt
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            guard let self else { return }
            self.isSaving = false

            if case .failure(let err) = completion {
                self.errorMessage = err.localizedDescription
            } else {
                onSuccess()
            }
        } receiveValue: { _ in }
        .store(in: &cancellables)
    }
}
