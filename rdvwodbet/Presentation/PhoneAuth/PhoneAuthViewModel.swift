import Foundation
import Combine
import UIKit

// ⚠️ ENTREGA ACADÊMICA: ViewModel da tela de autenticação por telefone.

/// Etapa atual do fluxo de autenticação por telefone.
enum PhoneAuthStep: Equatable {
    case enterPhone
    case enterCode
}

@MainActor
final class PhoneAuthViewModel: ObservableObject {

    // MARK: - Estado publicado

    @Published private(set) var step: PhoneAuthStep = .enterPhone
    @Published var phone: String = ""
    @Published var code: String = ""
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false

    // MARK: - Dependências

    private let loginWithPhoneUseCase: LoginWithPhoneUseCase
    private let confirmPhoneLoginUseCase: ConfirmPhoneLoginUseCase
    private let sessionManager: SessionManager
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UUID do dispositivo (identifierForVendor, conforme requisito)

    private var deviceUUID: String {
        UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
    }

    // MARK: - Init

    init(
        loginWithPhoneUseCase: LoginWithPhoneUseCase,
        confirmPhoneLoginUseCase: ConfirmPhoneLoginUseCase,
        sessionManager: SessionManager
    ) {
        self.loginWithPhoneUseCase = loginWithPhoneUseCase
        self.confirmPhoneLoginUseCase = confirmPhoneLoginUseCase
        self.sessionManager = sessionManager
    }

    // MARK: - Ações

    /// Chamado ao tocar em "Acessar" na tela de telefone.
    func requestCode() {
        let trimmedPhone = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedPhone.isEmpty else {
            errorMessage = "Informe seu número de telefone."
            return
        }
        guard trimmedPhone.count >= 8 else {
            errorMessage = "Número de telefone inválido."
            return
        }

        errorMessage = nil
        isLoading = true

        loginWithPhoneUseCase
            .execute(phone: trimmedPhone, uuid: deviceUUID)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isLoading = false
                if case .failure(let error) = completion {
                    self.errorMessage = error.errorDescription ?? "Erro ao tentar acessar."
                }
            } receiveValue: { [weak self] result in
                guard let self else { return }
                switch result {
                case .loggedIn(let user):
                    // HTTP 200 — usuário e uuid já conhecidos, login direto
                    self.sessionManager.save(user: user)
                case .codeRequired:
                    // HTTP 202 — backend enviou código de confirmação
                    self.step = .enterCode
                }
            }
            .store(in: &cancellables)
    }

    /// Chamado ao tocar em "Confirmar" na tela de código.
    func confirmCode() {
        let trimmedCode = code.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedCode.isEmpty else {
            errorMessage = "Informe o código de confirmação."
            return
        }

        errorMessage = nil
        isLoading = true

        confirmPhoneLoginUseCase
            .execute(
                phone: phone.trimmingCharacters(in: .whitespacesAndNewlines),
                uuid: deviceUUID,
                code: trimmedCode
            )
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isLoading = false
                if case .failure(let error) = completion {
                    self.errorMessage = Self.mapConfirmError(error)
                }
            } receiveValue: { [weak self] user in
                guard let self else { return }
                // HTTP 200 — usuário criado/atualizado, salva sessão
                self.sessionManager.save(user: user)
            }
            .store(in: &cancellables)
    }

    /// Volta à etapa de inserção de telefone.
    func goBackToPhone() {
        code = ""
        errorMessage = nil
        step = .enterPhone
    }

    // MARK: - Private

    private static func mapConfirmError(_ error: AppError) -> String {
        switch error {
        case .dataNotFound:
            return "Nenhum código de confirmação foi encontrado para este telefone."
        case .invalidInput:
            return "Código inválido. Verifique e tente novamente."
        default:
            return error.errorDescription ?? "Erro ao confirmar o código."
        }
    }
}

