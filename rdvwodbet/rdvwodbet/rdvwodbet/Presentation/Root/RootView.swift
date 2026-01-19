import SwiftUI

struct RootView: View {
    @ObservedObject var container: AppDIContainer
    @StateObject private var authVM: AuthViewModel

    init(container: AppDIContainer) {
        self.container = container
        _authVM = StateObject(wrappedValue: AuthViewModel(
            observeAuthStateUseCase: container.observeAuthStateUseCase,
            userRepository: container.userRepository,
            authRepository: container.authRepository
        ))
    }

    var body: some View {
        AppBackgroundView {
            Group {
                switch authVM.state {
                case .loading:
                    LoadingView(text: "Carregando...")

                case .loggedOut:
                    AuthView(viewModel: authVM)

                case .needsDisplayName(let uid):
                    DisplayNameOnboardingView(
                        viewModel: DisplayNameOnboardingViewModel(
                            uid: uid,
                            userRepository: container.userRepository,
                            onFinished: { authVM.refreshUserState() }
                        )
                    )

                case .loggedIn(let user):
                    FeedView(
                        viewModel: FeedViewModel(
                            currentUser: user,
                            observeBetsUseCase: container.observeBetsUseCase,
                            betRepository: container.betRepository
                        ),
                        container: container
                    )
                }
            }
            // ✅ impede que alguma view pinte fundo sólido
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.clear)
        }
    }
}

