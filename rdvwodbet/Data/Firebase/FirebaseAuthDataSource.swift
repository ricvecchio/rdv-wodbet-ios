import Foundation
import FirebaseAuth
import Combine

// MARK: - Firebase Auth Error → mensagem amigável em pt-BR
 
private func firebaseAuthErrorMessage(_ error: Error) -> String {
    let nsError = error as NSError
    guard let code = AuthErrorCode(rawValue: nsError.code) else {
        return "Ocorreu um erro inesperado. Tente novamente."
    }
    switch code {
    case .invalidEmail:
        return "O e-mail informado é inválido."
    case .wrongPassword:
        return "Senha incorreta. Verifique e tente novamente."
    case .userNotFound:
        return "Nenhuma conta encontrada com esse e-mail."
    case .userDisabled:
        return "Esta conta foi desativada. Entre em contato com o suporte."
    case .emailAlreadyInUse:
        return "Este e-mail já está em uso. Tente fazer login."
    case .weakPassword:
        return "A senha é muito fraca. Use pelo menos 6 caracteres."
    case .networkError:
        return "Sem conexão com a internet. Verifique sua rede."
    case .tooManyRequests:
        return "Muitas tentativas. Aguarde alguns minutos e tente novamente."
    case .invalidCredential:
        return "E-mail ou senha incorretos. Verifique e tente novamente."
    case .operationNotAllowed:
        return "Este método de login não está habilitado. Contate o suporte."
    case .requiresRecentLogin:
        return "Por segurança, faça login novamente para continuar."
    default:
        return "Ocorreu um erro inesperado. Tente novamente."
    }
}

// MARK: - FirebaseAuthDataSource

final class FirebaseAuthDataSource {

    private var authListenerHandle: AuthStateDidChangeListenerHandle?

    func observeAuthState() -> AnyPublisher<String?, Never> {
        let subject = CurrentValueSubject<String?, Never>(Auth.auth().currentUser?.uid)

        if let handle = authListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }

        authListenerHandle = Auth.auth().addStateDidChangeListener { _, user in
            subject.send(user?.uid)
        }

        return subject.eraseToAnyPublisher()
    }

    func signIn(email: String, password: String) -> AnyPublisher<String, AppError> {
        Future { promise in
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error {
                    return promise(.failure(.network(firebaseAuthErrorMessage(error))))
                }
                guard let uid = result?.user.uid else {
                    return promise(.failure(.unknown))
                }
                promise(.success(uid))
            }
        }
        .eraseToAnyPublisher()
    }

    func signUp(email: String, password: String) -> AnyPublisher<String, AppError> {
        Future { promise in
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let error {
                    return promise(.failure(.network(firebaseAuthErrorMessage(error))))
                }
                guard let uid = result?.user.uid else {
                    return promise(.failure(.unknown))
                }
                promise(.success(uid))
            }
        }
        .eraseToAnyPublisher()
    }

    func sendPasswordReset(email: String) -> AnyPublisher<Void, AppError> {
        Future { promise in
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                if let error {
                    return promise(.failure(.network(firebaseAuthErrorMessage(error))))
                }
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    func currentUID() -> String? {
        Auth.auth().currentUser?.uid
    }

    deinit {
        if let handle = authListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}

