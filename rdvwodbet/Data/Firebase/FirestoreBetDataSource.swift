import Foundation
import FirebaseFirestore
import Combine

final class FirestoreBetDataSource {
    private let db = Firestore.firestore()

    func observeBets() -> AnyPublisher<[BetDTO], AppError> {
        let subject = PassthroughSubject<[BetDTO], AppError>()

        db.collection("bets").addSnapshotListener { snap, err in
            if let err {
                subject.send(completion: .failure(.network(err.localizedDescription)))
                return
            }

            guard let snap else {
                subject.send([])
                return
            }

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
                if let err {
                    return promise(.failure(.network(err.localizedDescription)))
                }
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }

    func createBet(betId: String, data: [String: Any]) -> AnyPublisher<Void, AppError> {
        Future { promise in
            self.db.collection("bets").document(betId).setData(data) { err in
                if let err {
                    return promise(.failure(.network(err.localizedDescription)))
                }
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }

    /// Confirma o vencedor proposto usando transação (evita race condition).
    /// Regra:
    /// - precisa existir proposedWinnerUserId
    /// - confirmer precisa ser athleteAUserId ou athleteBUserId
    /// - marca athleteAConfirmed / athleteBConfirmed
    /// - se ambos confirmarem: status = finished e confirmedWinnerUserId = proposedWinnerUserId
    func confirmWinnerTransaction(betId: String, confirmerUserId: String) -> AnyPublisher<Void, AppError> {
        Future { promise in
            let ref = self.db.collection("bets").document(betId)

            self.db.runTransaction({ transaction, errorPointer -> Any? in
                let snap: DocumentSnapshot

                do {
                    snap = try transaction.getDocument(ref)
                } catch {
                    errorPointer?.pointee = NSError(
                        domain: "FirestoreBetDataSource",
                        code: 1,
                        userInfo: [NSLocalizedDescriptionKey: "Não foi possível ler a aposta."]
                    )
                    return nil
                }

                guard let data = snap.data() else {
                    errorPointer?.pointee = NSError(
                        domain: "FirestoreBetDataSource",
                        code: 2,
                        userInfo: [NSLocalizedDescriptionKey: "Aposta não encontrada."]
                    )
                    return nil
                }

                let athleteAUserId = data["athleteAUserId"] as? String ?? ""
                let athleteBUserId = data["athleteBUserId"] as? String ?? ""

                if confirmerUserId != athleteAUserId && confirmerUserId != athleteBUserId {
                    errorPointer?.pointee = NSError(
                        domain: "FirestoreBetDataSource",
                        code: 3,
                        userInfo: [NSLocalizedDescriptionKey: "Apenas os atletas podem confirmar o resultado."]
                    )
                    return nil
                }

                let proposedWinnerUserId = data["proposedWinnerUserId"] as? String
                guard let proposedWinnerUserId, !proposedWinnerUserId.isEmpty else {
                    errorPointer?.pointee = NSError(
                        domain: "FirestoreBetDataSource",
                        code: 4,
                        userInfo: [NSLocalizedDescriptionKey: "Nenhum vencedor foi proposto ainda."]
                    )
                    return nil
                }

                let athleteAConfirmed = data["athleteAConfirmed"] as? Bool ?? false
                let athleteBConfirmed = data["athleteBConfirmed"] as? Bool ?? false
                let status = data["status"] as? String ?? BetStatus.open.rawValue

                if status == BetStatus.finished.rawValue || status == BetStatus.canceled.rawValue {
                    errorPointer?.pointee = NSError(
                        domain: "FirestoreBetDataSource",
                        code: 5,
                        userInfo: [NSLocalizedDescriptionKey: "Esta aposta não pode mais ser confirmada."]
                    )
                    return nil
                }

                var newAConfirmed = athleteAConfirmed
                var newBConfirmed = athleteBConfirmed

                if confirmerUserId == athleteAUserId {
                    newAConfirmed = true
                }

                if confirmerUserId == athleteBUserId {
                    newBConfirmed = true
                }

                var updates: [String: Any] = [
                    "athleteAConfirmed": newAConfirmed,
                    "athleteBConfirmed": newBConfirmed
                ]

                if newAConfirmed && newBConfirmed {
                    updates["status"] = BetStatus.finished.rawValue
                    updates["confirmedWinnerUserId"] = proposedWinnerUserId
                }

                transaction.setData(updates, forDocument: ref, merge: true)
                return nil

            }, completion: { _, err in
                if let err {
                    promise(.failure(.network(err.localizedDescription)))
                } else {
                    promise(.success(()))
                }
            })
        }
        .eraseToAnyPublisher()
    }

    /// Rejeita o vencedor proposto e coloca a aposta em disputa.
    /// Também limpa confirmações anteriores e remove vencedor confirmado.
    func rejectWinnerTransaction(betId: String, rejectorUserId: String) -> AnyPublisher<Void, AppError> {
        Future { promise in
            let ref = self.db.collection("bets").document(betId)

            self.db.runTransaction({ transaction, errorPointer -> Any? in
                let snap: DocumentSnapshot

                do {
                    snap = try transaction.getDocument(ref)
                } catch {
                    errorPointer?.pointee = NSError(
                        domain: "FirestoreBetDataSource",
                        code: 10,
                        userInfo: [NSLocalizedDescriptionKey: "Não foi possível ler a aposta."]
                    )
                    return nil
                }

                guard let data = snap.data() else {
                    errorPointer?.pointee = NSError(
                        domain: "FirestoreBetDataSource",
                        code: 11,
                        userInfo: [NSLocalizedDescriptionKey: "Aposta não encontrada."]
                    )
                    return nil
                }

                let athleteAUserId = data["athleteAUserId"] as? String ?? ""
                let athleteBUserId = data["athleteBUserId"] as? String ?? ""
                let status = data["status"] as? String ?? BetStatus.open.rawValue

                if rejectorUserId != athleteAUserId && rejectorUserId != athleteBUserId {
                    errorPointer?.pointee = NSError(
                        domain: "FirestoreBetDataSource",
                        code: 12,
                        userInfo: [NSLocalizedDescriptionKey: "Apenas os atletas podem rejeitar o resultado."]
                    )
                    return nil
                }

                if status == BetStatus.finished.rawValue || status == BetStatus.canceled.rawValue {
                    errorPointer?.pointee = NSError(
                        domain: "FirestoreBetDataSource",
                        code: 13,
                        userInfo: [NSLocalizedDescriptionKey: "Esta aposta não pode mais entrar em disputa."]
                    )
                    return nil
                }

                let updates: [String: Any] = [
                    "status": BetStatus.disputed.rawValue,
                    "athleteAConfirmed": false,
                    "athleteBConfirmed": false,
                    "proposedWinnerUserId": NSNull(),
                    "confirmedWinnerUserId": NSNull()
                ]

                transaction.setData(updates, forDocument: ref, merge: true)
                return nil

            }, completion: { _, err in
                if let err {
                    promise(.failure(.network(err.localizedDescription)))
                } else {
                    promise(.success(()))
                }
            })
        }
        .eraseToAnyPublisher()
    }

    /// Cancela a aposta com validação de regra:
    /// - apenas o criador pode cancelar
    /// - aposta finalizada/cancelada não pode mais ser cancelada
    func cancelBetTransaction(betId: String, requesterUserId: String) -> AnyPublisher<Void, AppError> {
        Future { promise in
            let ref = self.db.collection("bets").document(betId)

            self.db.runTransaction({ transaction, errorPointer -> Any? in
                let snap: DocumentSnapshot

                do {
                    snap = try transaction.getDocument(ref)
                } catch {
                    errorPointer?.pointee = NSError(
                        domain: "FirestoreBetDataSource",
                        code: 20,
                        userInfo: [NSLocalizedDescriptionKey: "Não foi possível ler a aposta."]
                    )
                    return nil
                }

                guard let data = snap.data() else {
                    errorPointer?.pointee = NSError(
                        domain: "FirestoreBetDataSource",
                        code: 21,
                        userInfo: [NSLocalizedDescriptionKey: "Aposta não encontrada."]
                    )
                    return nil
                }

                let createdByUserId = data["createdByUserId"] as? String ?? ""
                let status = data["status"] as? String ?? BetStatus.open.rawValue

                if requesterUserId != createdByUserId {
                    errorPointer?.pointee = NSError(
                        domain: "FirestoreBetDataSource",
                        code: 22,
                        userInfo: [NSLocalizedDescriptionKey: "Somente o criador da aposta pode cancelá-la."]
                    )
                    return nil
                }

                if status == BetStatus.finished.rawValue || status == BetStatus.canceled.rawValue {
                    errorPointer?.pointee = NSError(
                        domain: "FirestoreBetDataSource",
                        code: 23,
                        userInfo: [NSLocalizedDescriptionKey: "Esta aposta não pode mais ser cancelada."]
                    )
                    return nil
                }

                let updates: [String: Any] = [
                    "status": BetStatus.canceled.rawValue
                ]

                transaction.setData(updates, forDocument: ref, merge: true)
                return nil

            }, completion: { _, err in
                if let err {
                    promise(.failure(.network(err.localizedDescription)))
                } else {
                    promise(.success(()))
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
