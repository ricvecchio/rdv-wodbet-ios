import SwiftUI

struct DisplayNameOnboardingView: View {
    @ObservedObject var viewModel: DisplayNameOnboardingViewModel

    var body: some View {
        VStack(spacing: 16) {
            Text("Seu apelido no box")
                .font(.title2.bold())

            TextField("Ex: João RDV", text: $viewModel.displayName)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.words)

            PrimaryButton(title: viewModel.isSaving ? "Salvando..." : "Continuar",
                          isDisabled: viewModel.isSaving) {
                viewModel.save()
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

