import Foundation
import FirebaseFirestore
import Combine

final class FirestoreBetDataSource {
    private let db = Firestore.firestore()

    func observeBets() -> AnyPublisher<[BetDTO], AppError> {
        let subject = PassthroughSubject<[BetDTO], AppError>()

        db.collection("bets").addSnapshotListener { snap, err in
            if let err { subject.send(completion: .failure(.network(err.localizedDescription))); return }
            guard let snap else { subject.send([]); return }

            let dtos = snap.documents.map { doc in
                BetDTO(id: doc.documentID, data: doc.data())
            }
            subject.send(dtos)
        }

        return subject.eraseToAnyPublisher()
    }

    func setBet(betId: String, data: [String: Any]) -> AnyPublisher<Void, AppError> {
        Future { promise in
            self.db.collection("bets").document(betId).setData(data, merge: true) { err in
                if let err { return promise(.failure(.network(err.localizedDescription))) }
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }

    func createBet(betId: String, data: [String: Any]) -> AnyPublisher<Void, AppError> {
        Future { promise in
            self.db.collection("bets").document(betId).setData(data) { err in
                if let err { return promise(.failure(.network(err.localizedDescription))) }
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }
}
