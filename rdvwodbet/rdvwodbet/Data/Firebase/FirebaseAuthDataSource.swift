import Foundation
import FirebaseAuth
import Combine

final class FirebaseAuthDataSource {
    func observeAuthState() -> AnyPublisher<String?, Never> {
        let subject = CurrentValueSubject<String?, Never>(Auth.auth().currentUser?.uid)

        Auth.auth().addStateDidChangeListener { _, user in
            subject.send(user?.uid)
        }

        return subject.eraseToAnyPublisher()
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    func currentUID() -> String? {
        Auth.auth().currentUser?.uid
    }
}
