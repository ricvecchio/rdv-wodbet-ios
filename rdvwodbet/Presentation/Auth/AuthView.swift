import SwiftUI

struct AuthView: View {
    @ObservedObject var viewModel: AuthViewModel

    @State private var email: String = ""
    @State private var password: String = ""
    @FocusState private var focusedField: Field?

    private enum Field { case email, password }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                Spacer(minLength: Theme.Layout.authTopSpacerMin)

                Image("rdv_wodbet_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: Theme.Layout.logoWidth)
                    .padding(.bottom, Theme.Layout.logoBottomPadding)
                    .accessibilityHidden(true)
                    .shadow(
                        color: Theme.Colors.logoShadow,
                        radius: Theme.Effects.logoShadowRadius,
                        x: 0,
                        y: Theme.Effects.logoShadowY
                    )

                AuthCardView {
                    VStack(spacing: Theme.Layout.authInnerSpacing) {

                        Text("RDV WODBet")
                            .font(Theme.Typography.title)
                            .foregroundColor(Theme.Colors.textPrimary)
                            .multilineTextAlignment(.center)

                        Text("Apostas entre amigos do box.\nQuem ganha o WOD?")
                            .font(Theme.Typography.footnote)
                            .foregroundColor(Theme.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)

                        // E-mail
                        TextField("email@teste.com", text: $email)
                            .authFieldStyle()
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .focused($focusedField, equals: .email)
                            .submitLabel(.next)
                            .onSubmit { focusedField = .password }

                        // Senha
                        SecureField("Senha", text: $password)
                            .authFieldStyle()
                            .focused($focusedField, equals: .password)
                            .submitLabel(.go)
                            .onSubmit { triggerLogin() }

                        // Esqueceu a senha?
                        HStack {
                            Spacer()
                            Button("Esqueceu a senha?") {
                                viewModel.forgotPasswordEmail = email
                                viewModel.forgotPasswordMessage = nil
                                viewModel.showForgotPassword = true
                            }
                            .font(.footnote)
                            .foregroundColor(Theme.Colors.textSecondary)
                        }

                        // Botão Acessar
                        PrimaryButton(
                            title: viewModel.isLoading ? "Entrando..." : "Acessar",
                            isDisabled: viewModel.isLoading
                        ) {
                            triggerLogin()
                        }

                        // Mensagem de erro
                        if let msg = viewModel.errorMessage {
                            Text(msg)
                                .font(Theme.Typography.footnote)
                                .foregroundColor(Theme.Colors.error)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        // Link para Cadastro
                        NavigationLink(destination:
                            RegisterView(
                                viewModel: RegisterViewModel(
                                    authRepository: viewModel.authRepository,
                                    userRepository: viewModel.userRepository
                                )
                            )
                        ) {
                            Text("Não tem conta? ")
                                .foregroundColor(Theme.Colors.textSecondary)
                            + Text("Cadastre-se")
                                .bold()
                                .foregroundColor(Theme.Colors.textPrimary)
                        }
                        .font(.footnote)
                        .padding(.top, 4)
                    }
                }

                Spacer()
            }
            .padding(.top, Theme.Layout.authTopOffset)
            .padding(.horizontal, Theme.Layout.screenHorizontalPadding)
            .onTapGesture { focusedField = nil }
            .sheet(isPresented: $viewModel.showForgotPassword) {
                ForgotPasswordSheet(viewModel: viewModel)
            }
        }
    }

    private func triggerLogin() {
        focusedField = nil
        viewModel.signInWithEmail(email: email, password: password)
    }
}
