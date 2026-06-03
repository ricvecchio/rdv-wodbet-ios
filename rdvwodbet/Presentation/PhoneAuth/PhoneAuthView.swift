import SwiftUI

// ⚠️ ENTREGA ACADÊMICA: Tela de autenticação por telefone.
// Substitui temporariamente AuthView (e-mail/senha do Firebase).

struct PhoneAuthView: View {

    @ObservedObject var viewModel: PhoneAuthViewModel
    @FocusState private var focusedField: Field?

    private enum Field { case phone, code }

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

                        // MARK: Etapa 1 — Inserir telefone
                        if viewModel.step == .enterPhone {
                            phoneStep
                        }

                        // MARK: Etapa 2 — Inserir código
                        if viewModel.step == .enterCode {
                            codeStep
                        }

                        // Mensagem de erro
                        if let msg = viewModel.errorMessage {
                            Text(msg)
                                .font(Theme.Typography.footnote)
                                .foregroundColor(Theme.Colors.error)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }

                Spacer()
            }
            .padding(.top, Theme.Layout.authTopOffset)
            .padding(.horizontal, Theme.Layout.screenHorizontalPadding)
            .onTapGesture { focusedField = nil }
            .animation(.easeInOut(duration: 0.25), value: viewModel.step)
        }
    }

    // MARK: - Etapa: Telefone

    private var phoneStep: some View {
        VStack(spacing: Theme.Layout.authInnerSpacing) {
            TextField("+55 11 99999-9999", text: $viewModel.phone)
                .authFieldStyle()
                .keyboardType(.phonePad)
                .focused($focusedField, equals: .phone)
                .submitLabel(.go)
                .onSubmit { triggerRequestCode() }
                .onAppear { focusedField = .phone }

            PrimaryButton(
                title: viewModel.isLoading ? "Verificando..." : "Acessar",
                isDisabled: viewModel.isLoading
            ) {
                triggerRequestCode()
            }
        }
    }

    // MARK: - Etapa: Código

    private var codeStep: some View {
        VStack(spacing: Theme.Layout.authInnerSpacing) {

            Text("Enviamos um código de confirmação para seu telefone.")
                .font(Theme.Typography.footnote)
                .foregroundColor(Theme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            TextField("Código de confirmação", text: $viewModel.code)
                .authFieldStyle()
                .keyboardType(.numberPad)
                .focused($focusedField, equals: .code)
                .submitLabel(.go)
                .onSubmit { triggerConfirmCode() }
                .onAppear { focusedField = .code }

            PrimaryButton(
                title: viewModel.isLoading ? "Confirmando..." : "Confirmar",
                isDisabled: viewModel.isLoading
            ) {
                triggerConfirmCode()
            }

            Button("Voltar") {
                viewModel.goBackToPhone()
            }
            .font(.footnote)
            .foregroundColor(Theme.Colors.textSecondary)
        }
    }

    // MARK: - Actions

    private func triggerRequestCode() {
        focusedField = nil
        viewModel.requestCode()
    }

    private func triggerConfirmCode() {
        focusedField = nil
        viewModel.confirmCode()
    }
}

