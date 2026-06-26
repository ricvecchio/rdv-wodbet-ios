import Foundation
import Combine

final class AppDIContainer: ObservableObject {
    let env = AppEnvironment()

    // MARK: - ⚠️ ENTREGA ACADÊMICA
    // O fluxo principal do app foi migrado temporariamente para o backend Java:
    // - autenticação por telefone + UUID
    // - usuários, participantes e bets via REST
    //
    // O Firebase/Firestore permanece preservado no projeto para possível retorno futuro.
    // Para restaurá-lo, descomente as dependências abaixo e volte o RootView ao fluxo antigo.

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

    // MARK: - Backend Java (ativo para entrega acadêmica)

    /// Sessão local do usuário autenticado pelo backend.
    lazy var sessionManager = SessionManager()

    private lazy var phoneAuthRemoteDataSource = PhoneAuthRemoteDataSource(
        baseURL: env.backendBaseURL,
        authTokenProvider: { [weak self] in self?.sessionManager.authToken }
    )
    lazy var phoneAuthRepository: PhoneAuthRepositoryProtocol = PhoneAuthRepository(
        remoteDataSource: phoneAuthRemoteDataSource
    )
    lazy var loginWithPhoneUseCase   = LoginWithPhoneUseCase(repository: phoneAuthRepository)
    lazy var confirmPhoneLoginUseCase = ConfirmPhoneLoginUseCase(repository: phoneAuthRepository)
    lazy var updateUserProfileUseCase = UpdateUserProfileUseCase(repository: phoneAuthRepository)

    // MARK: - Backend repositories (users / participants / bets)
    private lazy var backendUserRemoteDataSource = BackendUserRemoteDataSource(
        baseURL: env.backendBaseURL,
        authTokenProvider: { [weak self] in self?.sessionManager.authToken }
    )
    private lazy var backendParticipantRemoteDataSource = BackendParticipantRemoteDataSource(
        baseURL: env.backendBaseURL,
        authTokenProvider: { [weak self] in self?.sessionManager.authToken }
    )
    private lazy var backendBetRemoteDataSource = BackendBetRemoteDataSource(
        baseURL: env.backendBaseURL,
        authTokenProvider: { [weak self] in self?.sessionManager.authToken }
    )

    lazy var userRepository: UserRepository = BackendUserRepository(remoteDataSource: backendUserRemoteDataSource)
    lazy var participantRepository: ParticipantRepository = BackendParticipantRepository(remoteDataSource: backendParticipantRemoteDataSource)
    lazy var betRepository: BetRepository = BackendBetRepository(remoteDataSource: backendBetRemoteDataSource)

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
