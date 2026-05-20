import Foundation
import FirebaseAuth
import Combine

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
                    return promise(.failure(.network(error.localizedDescription)))
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
                    return promise(.failure(.network(error.localizedDescription)))
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
                    return promise(.failure(.network(error.localizedDescription)))
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

