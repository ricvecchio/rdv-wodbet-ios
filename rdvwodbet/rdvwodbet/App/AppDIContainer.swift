import Foundation
import Combine

final class AppDIContainer: ObservableObject {
    let env = AppEnvironment()

    // MARK: - DataSources
    private lazy var authDataSource = FirebaseAuthDataSource()
    private lazy var userDataSource = FirestoreUserDataSource()
    private lazy var betDataSource  = FirestoreBetDataSource()

    // MARK: - Repositories
    lazy var authRepository: AuthRepository = FirebaseAuthRepository(dataSource: authDataSource)
    lazy var userRepository: UserRepository = FirestoreUserRepository(dataSource: userDataSource)
    lazy var betRepository: BetRepository   = FirestoreBetRepository(dataSource: betDataSource)

    // MARK: - UseCases
    lazy var observeAuthStateUseCase = ObserveAuthStateUseCase(authRepository: authRepository)
    lazy var observeBetsUseCase      = ObserveBetsUseCase(betRepository: betRepository)
    lazy var createBetUseCase        = CreateBetUseCase(betRepository: betRepository)
    lazy var proposeWinnerUseCase    = ProposeWinnerUseCase(betRepository: betRepository)
    lazy var confirmWinnerUseCase    = ConfirmWinnerUseCase(betRepository: betRepository)
    lazy var rejectWinnerUseCase     = RejectWinnerUseCase(betRepository: betRepository)
    lazy var cancelBetUseCase        = CancelBetUseCase(betRepository: betRepository)
}
