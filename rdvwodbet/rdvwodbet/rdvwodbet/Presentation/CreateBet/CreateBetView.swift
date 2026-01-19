import SwiftUI

struct CreateBetView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: CreateBetViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section("Atletas") {
                    Picker("Atleta A", selection: $viewModel.selectedAUserId) {
                        Text("Selecione").tag(Optional<String>.none)
                        ForEach(viewModel.users) { user in
                            Text(user.displayName).tag(Optional(user.id))
                        }
                    }

                    Picker("Atleta B", selection: $viewModel.selectedBUserId) {
                        Text("Selecione").tag(Optional<String>.none)
                        ForEach(viewModel.users) { user in
                            Text(user.displayName).tag(Optional(user.id))
                        }
                    }
                }

                Section("WOD") {
                    TextField("Ex: Fran / DT / WOD do dia", text: $viewModel.wodTitle)
                }

                Section("Prêmio") {
                    Picker("Tipo", selection: $viewModel.prizeType) {
                        ForEach(PrizeType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }

                    if viewModel.prizeType == .other {
                        TextField("Descreva o prêmio", text: $viewModel.prizeOtherDescription)
                    }
                }

                if let msg = viewModel.errorMessage {
                    Text(msg).foregroundStyle(.red)
                }
            }
            .scrollContentBackground(.hidden) // 🔥 remove branco do Form
            .navigationTitle("Nova Aposta")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(viewModel.isSaving ? "Salvando..." : "Salvar") {
                        viewModel.save { dismiss() }
                    }
                    .disabled(viewModel.isSaving)
                }
            }
        }
    }
}

