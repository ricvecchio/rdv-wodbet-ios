import Foundation
import Combine

protocol ParticipantRepository {
    func fetchParticipant(id: String) -> AnyPublisher<Participant?, AppError>
    func observeParticipants() -> AnyPublisher<[Participant], AppError>
    func createParticipant(name: String, email: String?, phone: String?) -> AnyPublisher<Void, AppError>
    func updateParticipant(id: String, name: String?, phone: String?) -> AnyPublisher<Void, AppError>
}

