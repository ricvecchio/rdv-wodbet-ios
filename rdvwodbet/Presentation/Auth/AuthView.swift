import SwiftUI

struct AuthView: View {
    @ObservedObject var viewModel: AuthViewModel

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
                    Text("RDV WODBet")
                        .font(Theme.Typography.title)
                        .foregroundColor(Theme.Colors.textPrimary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Apostas entre amigos do box.\nQuem ganha o WOD?")
                        .font(Theme.Typography.footnote)
                        .foregroundColor(Theme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    PrimaryButton(
                        title: "Entrar (dev)",
                        isDisabled: false
                    ) {
                        // ✅ login real para não dar “insufficient permissions”
                        viewModel.signInAnonymouslyForDev()
                    }

                    if let msg = viewModel.errorMessage {
                        Text(msg)
                            .font(Theme.Typography.footnote)
                            .foregroundColor(Theme.Colors.error)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 4)
                    }
                }
            }

            Spacer()
        }
        .padding(.top, Theme.Layout.authTopOffset)
        .padding(.horizontal, Theme.Layout.screenHorizontalPadding)
    }
}

