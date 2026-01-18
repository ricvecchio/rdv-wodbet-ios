import Foundation
import FirebaseFirestore
import Combine

final class FirestoreUserDataSource {
    private let db = Firestore.firestore()

    func fetchUser(uid: String) -> AnyPublisher<AppUserDTO?, AppError> {
        Future { promise in
            self.db.collection("users").document(uid).getDocument { snap, err in
                if let err { return promise(.failure(.network(err.localizedDescription))) }
                guard let snap, snap.exists, let data = snap.data() else {
                    return promise(.success(nil))
                }
                promise(.success(AppUserDTO(id: uid, data: data)))
            }
        }
        .eraseToAnyPublisher()
    }

    func upsertUser(uid: String, data: [String: Any]) -> AnyPublisher<Void, AppError> {
        Future { promise in
            self.db.collection("users").document(uid).setData(data, merge: true) { err in
                if let err { return promise(.failure(.network(err.localizedDescription))) }
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }

    func observeAllUsers() -> AnyPublisher<[AppUserDTO], AppError> {
        let subject = PassthroughSubject<[AppUserDTO], AppError>()

        db.collection("users").addSnapshotListener { snap, err in
            if let err { subject.send(completion: .failure(.network(err.localizedDescription))); return }
            guard let snap else { subject.send([]); return }

            let dtos: [AppUserDTO] = snap.documents.map { doc in
                AppUserDTO(id: doc.documentID, data: doc.data())
            }
            subject.send(dtos)
        }

        return subject.eraseToAnyPublisher()
    }
}
