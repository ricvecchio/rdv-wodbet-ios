import SwiftUI

// MARK: - Auth Text Field Style Modifier

struct AuthFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
            .background(Color.white.opacity(0.14))
            .cornerRadius(12)
            .foregroundColor(.white)
            .tint(.white)
            .frame(maxWidth: .infinity)
    }
}

extension View {
    func authFieldStyle() -> some View {
        modifier(AuthFieldStyle())
    }
}

// MARK: - Forgot Password Sheet

struct ForgotPasswordSheet: View {
    @ObservedObject var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack {
            // fundo igual ao app
            Image("rdv_wodbet_fundo")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            Color.black.opacity(0.45).ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                AuthCardView {
                    VStack(spacing: 16) {

                        Text("Recuperar Senha")
                            .font(.title2.bold())
                            .foregroundColor(Theme.Colors.textPrimary)
                            .multilineTextAlignment(.center)

                        Text("Informe seu e-mail e enviaremos\num link para redefinir sua senha.")
                            .font(.footnote)
                            .foregroundColor(Theme.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)

                        TextField("E-mail", text: $viewModel.forgotPasswordEmail)
                            .authFieldStyle()
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .focused($isFocused)
                            .submitLabel(.send)
                            .onSubmit { viewModel.sendPasswordReset() }

                        if let msg = viewModel.forgotPasswordMessage {
                            Text(msg)
                                .font(.footnote)
                                .foregroundColor(msg.contains("enviado") ? .green : Theme.Colors.error)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        PrimaryButton(
                            title: viewModel.isSendingReset ? "Enviando..." : "Enviar",
                            isDisabled: viewModel.isSendingReset
                        ) {
                            viewModel.sendPasswordReset()
                        }

                        Button("Cancelar") {
                            dismiss()
                        }
                        .font(.footnote)
                        .foregroundColor(Theme.Colors.textSecondary)
                        .padding(.top, 4)
                    }
                }

                Spacer()
            }
            .padding(.horizontal, Theme.Layout.screenHorizontalPadding)
        }
        .task { isFocused = true }
        .onTapGesture { isFocused = false }
    }
}

