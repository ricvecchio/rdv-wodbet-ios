import SwiftUI

struct AuthView: View {
    @ObservedObject var viewModel: AuthViewModel

    var body: some View {
        VStack(spacing: 0) {

            // 🔼 Spacer pequeno só para respiro
            Spacer(minLength: 20)

            // 🔥 LOGO DO APP (mais para cima)
            Image("rdv_wodbet_logo")
                .resizable()
                .scaledToFit()
                .frame(width: 300)
                .padding(.bottom, 12)
                .accessibilityHidden(true)
                .shadow(color: .black.opacity(0.25), radius: 8, y: 4)

            // 🔒 CARD DE LOGIN
            AuthCardView {
                VStack(spacing: 14) {
                    Text("RDV WODBet")
                        .font(.title.bold())
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Apostas entre amigos do box.\nQuem ganha o WOD?")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    PrimaryButton(
                        title: "Entrar (dev)",
                        isDisabled: false
                    ) {
                        viewModel.mockLoginForDev()
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

            // 🔽 Spacer grande para empurrar tudo para cima
            Spacer()
        }
        // 🔥 sobe ainda mais o conjunto (ajuste fino)
        .padding(.top, -100)
        .padding(.horizontal, 8)
    }
}

