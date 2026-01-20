import SwiftUI

struct CreateBetView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: CreateBetViewModel
    @FocusState private var focusedField: Field?
    
    enum Field {
        case wodTitle, prizeDescription
    }

    var body: some View {
        AppBackgroundView {
            NavigationStack {
                ScrollView {
                    VStack(spacing: 14) {

                        GlassCard {
                            Text("Atletas")
                                .font(.headline)
                                .foregroundColor(Theme.Colors.textPrimary)

                            VStack(spacing: 10) {
                                selectionRow(
                                    title: "Atleta A",
                                    value: selectedUserName(viewModel.selectedAUserId),
                                    options: viewModel.users.map { ($0.id, $0.displayName) },
                                    onSelect: { viewModel.selectedAUserId = $0 }
                                )

                                selectionRow(
                                    title: "Atleta B",
                                    value: selectedUserName(viewModel.selectedBUserId),
                                    options: viewModel.users.map { ($0.id, $0.displayName) },
                                    onSelect: { viewModel.selectedBUserId = $0 }
                                )
                            }
                        }

                        GlassCard {
                            Text("WOD")
                                .font(.headline)
                                .foregroundColor(Theme.Colors.textPrimary)

                            TextField("Ex: Fran / DT / WOD do dia", text: $viewModel.wodTitle)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 14)
                                .background(Color.white.opacity(0.14))
                                .cornerRadius(12)
                                .foregroundColor(Theme.Colors.textPrimary)
                                .focused($focusedField, equals: .wodTitle)
                                .submitLabel(.next)
                        }

                        GlassCard {
                            Text("Prêmio")
                                .font(.headline)
                                .foregroundColor(Theme.Colors.textPrimary)

                            prizeRow()

                            if viewModel.prizeType == .other {
                                TextField("Descreva o prêmio", text: $viewModel.prizeOtherDescription)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 14)
                                    .background(Color.white.opacity(0.14))
                                    .cornerRadius(12)
                                    .foregroundColor(Theme.Colors.textPrimary)
                                    .focused($focusedField, equals: .prizeDescription)
                                    .submitLabel(.done)
                            }
                        }

                        if let msg = viewModel.errorMessage {
                            Text(msg)
                                .font(.footnote)
                                .foregroundColor(Theme.Colors.error)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(Capsule().fill(Color.black.opacity(0.55)))
                                .frame(maxWidth: Theme.Layout.cardMaxWidth)
                        }

                        VStack(spacing: 10) {
                            PrimaryButton(
                                title: viewModel.isSaving ? "Salvando..." : "Salvar aposta",
                                isDisabled: viewModel.isSaving,
                                widthStyle: .card
                            ) {
                                viewModel.save { dismiss() }
                            }
                            
                            Button("Cancelar") {
                                dismiss()
                            }
                            .font(.subheadline)
                            .foregroundColor(Theme.Colors.textSecondary)
                            .padding(.vertical, 8)
                        }
                        .padding(.top, 6)

                    }
                    .frame(maxWidth: Theme.Layout.cardMaxWidth)
                    .padding(.top, 16)
                    .padding(.bottom, 28)
                    .frame(maxWidth: .infinity)
                }
                .navigationTitle("Nova Aposta")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(Theme.Colors.textPrimary)
                        }
                    }
                }
                .toolbarBackground(.hidden, for: .navigationBar)
                .onSubmit {
                    switch focusedField {
                    case .wodTitle:
                        focusedField = (viewModel.prizeType == .other) ? .prizeDescription : nil
                    case .prizeDescription:
                        focusedField = nil
                    case .none:
                        break
                    }
                }
            }
        }
        .tint(.white)
    }

    // MARK: - Helpers

    private func selectedUserName(_ userId: String?) -> String {
        guard let userId,
              let user = viewModel.users.first(where: { $0.id == userId })
        else { return "Selecione" }
        return user.displayName
    }

    private func selectionRow(
        title: String,
        value: String,
        options: [(id: String, name: String)],
        onSelect: @escaping (String?) -> Void
    ) -> some View {
        HStack {
            Text(title)
                .foregroundColor(Theme.Colors.textSecondary)
                .font(.footnote)

            Spacer()

            Menu {
                Button("Limpar seleção") { onSelect(nil) }
                Divider()
                ForEach(options, id: \.id) { opt in
                    Button(opt.name) { onSelect(opt.id) }
                }
            } label: {
                HStack(spacing: 8) {
                    Text(value)
                        .foregroundColor(Theme.Colors.textPrimary)
                        .lineLimit(1)

                    Image(systemName: "chevron.down")
                        .font(.footnote)
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .background(Color.black.opacity(0.22))
                .cornerRadius(12)
            }
        }
    }

    private func prizeRow() -> some View {
        HStack {
            Text("Tipo")
                .foregroundColor(Theme.Colors.textSecondary)
                .font(.footnote)

            Spacer()

            Menu {
                ForEach(PrizeType.allCases, id: \.self) { type in
                    Button(type.displayName) { viewModel.prizeType = type }
                }
            } label: {
                HStack(spacing: 8) {
                    Text(viewModel.prizeType.displayName)
                        .foregroundColor(Theme.Colors.textPrimary)

                    Image(systemName: "chevron.down")
                        .font(.footnote)
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .background(Color.black.opacity(0.22))
                .cornerRadius(12)
            }
        }
    }
}
