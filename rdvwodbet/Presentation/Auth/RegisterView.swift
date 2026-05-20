import SwiftUI

struct RegisterView: View {
    @ObservedObject var viewModel: RegisterViewModel
    @Environment(\.dismiss) private var dismiss

    @FocusState private var focusedField: Field?
    private enum Field { case name, email, password }

    var body: some View {
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

                    Text("Criar Conta")
                        .font(Theme.Typography.title)
                        .foregroundColor(Theme.Colors.textPrimary)
                        .multilineTextAlignment(.center)

                    Text("Preencha seus dados para comecar.")
                        .font(Theme.Typography.footnote)
                        .foregroundColor(Theme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    // Nome
                    TextField("Nome", text: $viewModel.name)
                        .authFieldStyle()
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                        .focused($focusedField, equals: .name)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .email }

                    // E-mail
                    TextField("E-mail", text: $viewModel.email)
                        .authFieldStyle()
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .focused($focusedField, equals: .email)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .password }

                    // Senha
                    SecureField("Senha (min. 6 caracteres)", text: $viewModel.password)
                        .authFieldStyle()
                        .focused($focusedField, equals: .password)
                        .submitLabel(.done)
                        .onSubmit { triggerSignUp() }

                    // Botao Criar Conta
                    PrimaryButton(
                        title: viewModel.isLoading ? "Criando conta..." : "Criar Conta",
                        isDisabled: viewModel.isLoading
                    ) {
                        triggerSignUp()
                    }

                    // Mensagem de erro
                    if let msg = viewModel.errorMessage {
                        Text(msg)
                            .font(Theme.Typography.footnote)
                            .foregroundColor(Theme.Colors.error)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    // Link Voltar ao Login
                    Button {
                        dismiss()
                    } label: {
                        Text("Já tenho conta — ")
                            .foregroundColor(Theme.Colors.textSecondary)
                        + Text("Voltar ao login")
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
        .onChange(of: viewModel.registrationSuccess) { success in
            if success { dismiss() }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Theme.Colors.textPrimary)
                        .fontWeight(.semibold)
                }
            }
        }
    }

    private func triggerSignUp() {
        focusedField = nil
        viewModel.signUp()
    }
}
