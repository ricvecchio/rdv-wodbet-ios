import SwiftUI

struct CreateBetView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: CreateBetViewModel

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
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Theme.Colors.border, lineWidth: 1)
                                )
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
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Theme.Colors.border, lineWidth: 1)
                                    )
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

                        PrimaryButton(
                            title: viewModel.isSaving ? "Salvando..." : "Salvar aposta",
                            isDisabled: viewModel.isSaving,
                            widthStyle: .card
                        ) {
                            viewModel.save { dismiss() }
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
                            Image(systemName: "chevron.left")
                                .font(.headline)
                                .foregroundColor(Theme.Colors.textPrimary)
                        }
                    }
                }
                .toolbarBackground(.hidden, for: .navigationBar)
            }
            .tint(.white)
        }
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
                .background(Color.white.opacity(0.14))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Theme.Colors.border, lineWidth: 1)
                )
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
                .background(Color.white.opacity(0.14))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Theme.Colors.border, lineWidth: 1)
                )
            }
        }
    }
}
