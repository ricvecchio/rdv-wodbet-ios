import SwiftUI

struct AuthView: View {
    @ObservedObject var viewModel: AuthViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text("RDV WODBet")
                .font(.largeTitle.bold())

            Text("Apostas entre amigos do box.\nQuem ganha o WOD?")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            // Placeholder de login (na próxima etapa colocamos Sign in with Apple real)
            PrimaryButton(title: "Entrar (dev)", isDisabled: false) {
                viewModel.mockLoginForDev()
            }

            if let msg = viewModel.errorMessage {
                Text(msg)
                    .foregroundStyle(.red)
                    .font(.footnote)
            }
        }
        .padding()
    }
}
