import SwiftUI

struct RootView: View {
    @ObservedObject var container: AppDIContainer

    // ⚠️ ENTREGA ACADÊMICA: Sessão gerenciada pelo SessionManager (backend Java).
    // Para restaurar o Firebase, substituir este bloco pelo AuthViewModel comentado abaixo.
    @ObservedObject private var sessionManager: SessionManager

    // MARK: - Firebase (preservado para retorno futuro)
    // @StateObject private var authVM: AuthViewModel
    //
    // init(container: AppDIContainer) {
    //     self.container = container
    //     _authVM = StateObject(wrappedValue: AuthViewModel(
    //         observeAuthStateUseCase: container.observeAuthStateUseCase,
    //         userRepository: container.userRepository,
    //         authRepository: container.authRepository
    //     ))
    // }

    // MARK: - Init (fluxo backend)

    init(container: AppDIContainer) {
        self.container = container
        self.sessionManager = container.sessionManager
    }

    // MARK: - Body

    var body: some View {
        AppBackgroundView {
            Group {
                // ⚠️ ENTREGA ACADÊMICA: navegação controlada pelo SessionManager.
                // Para restaurar o Firebase, substituir este bloco pelo switch authVM.state
                // (veja o código comentado no AppDIContainer e AuthViewModel).

                if !sessionManager.isReady {
                    // Verificando sessão persistida…
                    LoadingView(text: "Carregando...")

                } else if sessionManager.currentUser == nil {
                    // Sem sessão ativa — exibe tela de login por telefone
                    PhoneAuthView(
                        viewModel: PhoneAuthViewModel(
                            loginWithPhoneUseCase: container.loginWithPhoneUseCase,
                            confirmPhoneLoginUseCase: container.confirmPhoneLoginUseCase,
                            sessionManager: sessionManager
                        )
                    )

                } else if sessionManager.currentUser?.displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true {
                    // Usuário logado mas sem nome — onboarding de apelido
                    BackendDisplayNameOnboardingView(
                        viewModel: BackendDisplayNameOnboardingViewModel(
                            user: sessionManager.currentUser!,
                            updateUserProfileUseCase: container.updateUserProfileUseCase,
                            sessionManager: sessionManager,
                            onFinished: {}   // SessionManager.save() já publica o novo estado
                        )
                    )

                } else if let user = sessionManager.currentUser {
                    // Sessão válida com nome — vai para o Feed
                    FeedView(
                        viewModel: FeedViewModel(
                            currentUser: user,
                            observeBetsUseCase: container.observeBetsUseCase,
                            userRepository: container.userRepository
                        ),
                        container: container
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.clear)
        }
    }
}
