import Foundation
import Combine

final class AppDIContainer: ObservableObject {
    let env = AppEnvironment()

    // MARK: - ⚠️ ENTREGA ACADÊMICA
    // O fluxo de autenticação Firebase (e-mail/senha) está temporariamente substituído
    // pelo fluxo de telefone via backend Java.
    //
    // Para restaurar o Firebase:
    //   1. Descomentar as lazy vars Firebase abaixo.
    //   2. Descomentar authRepository, observeAuthStateUseCase.
    //   3. Restaurar RootView.swift para o fluxo com AuthViewModel.
    //   4. Remover / comentar o bloco "Backend Phone Auth" abaixo.

    // MARK: Firebase Data Sources (preservados — não instanciados no fluxo atual)
    // private lazy var authDataSource    = FirebaseAuthDataSource()
    // private lazy var userDataSource    = FirestoreUserDataSource()
    // private lazy var betDataSource     = FirestoreBetDataSource()

    // MARK: Firebase Repositories (preservados)
    // lazy var authRepository: AuthRepository = FirebaseAuthRepository(dataSource: authDataSource)
    // lazy var userRepository: UserRepository = FirestoreUserRepository(dataSource: userDataSource)
    // lazy var betRepository: BetRepository   = FirestoreBetRepository(dataSource: betDataSource)

    // MARK: Firebase Use Cases (preservados)
    // lazy var observeAuthStateUseCase = ObserveAuthStateUseCase(authRepository: authRepository)

    // MARK: - Backend Phone Auth (ativo para entrega acadêmica)

    /// Sessão local do usuário autenticado pelo backend.
    lazy var sessionManager = SessionManager()

    private lazy var phoneAuthRemoteDataSource = PhoneAuthRemoteDataSource(baseURL: env.backendBaseURL)
    lazy var phoneAuthRepository: PhoneAuthRepositoryProtocol = PhoneAuthRepository(
        remoteDataSource: phoneAuthRemoteDataSource
    )
    lazy var loginWithPhoneUseCase   = LoginWithPhoneUseCase(repository: phoneAuthRepository)
    lazy var confirmPhoneLoginUseCase = ConfirmPhoneLoginUseCase(repository: phoneAuthRepository)
    lazy var updateUserProfileUseCase = UpdateUserProfileUseCase(repository: phoneAuthRepository)

    // MARK: - Repositórios ainda ativos (apostas — inalterados)
    private lazy var userDataSource = FirestoreUserDataSource()
    private lazy var betDataSource  = FirestoreBetDataSource()

    lazy var userRepository: UserRepository = FirestoreUserRepository(dataSource: userDataSource)
    lazy var betRepository: BetRepository   = FirestoreBetRepository(dataSource: betDataSource)

    // MARK: - Bet Use Cases (inalterados)
    lazy var observeBetsUseCase      = ObserveBetsUseCase(betRepository: betRepository)
    lazy var createBetUseCase        = CreateBetUseCase(betRepository: betRepository)
    lazy var proposeWinnerUseCase    = ProposeWinnerUseCase(betRepository: betRepository)
    lazy var confirmWinnerUseCase    = ConfirmWinnerUseCase(betRepository: betRepository)
    lazy var rejectWinnerUseCase     = RejectWinnerUseCase(betRepository: betRepository)
    lazy var cancelBetUseCase        = CancelBetUseCase(betRepository: betRepository)
    lazy var updateBetResultUseCase  = UpdateBetResultUseCase(betRepository: betRepository)
    lazy var voteOnBetUseCase        = VoteOnBetUseCase(betRepository: betRepository)
}
