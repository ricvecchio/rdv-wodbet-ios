import SwiftUI

struct DisplayNameOnboardingView: View {
    @ObservedObject var viewModel: DisplayNameOnboardingViewModel
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack {
            Spacer()

            AuthCardView {
                VStack(spacing: 16) {
                    Text("Seu apelido no box")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Esse nome aparece no feed de apostas.")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.75))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    TextField("Ex: Ric", text: $viewModel.displayName)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 14)
                        .background(Color.white.opacity(0.14))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                        .textInputAutocapitalization(.words)
                        .disableAutocorrection(true)
                        .focused($isFocused)
                        .submitLabel(.done)
                        .onSubmit { viewModel.save() }

                    PrimaryButton(
                        title: viewModel.isSaving ? "Salvando..." : "Continuar",
                        isDisabled: viewModel.isSaving
                    ) {
                        viewModel.save()
                    }

                    if let msg = viewModel.errorMessage {
                        Text(msg)
                            .font(.footnote)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }

            Spacer()
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 8)
        .task {
            // ✅ foca o campo assim que a view aparece
            isFocused = true
        }
        .onTapGesture {
            // ✅ permite fechar/abrir teclado tocando fora
            isFocused = false
        }
    }
}

