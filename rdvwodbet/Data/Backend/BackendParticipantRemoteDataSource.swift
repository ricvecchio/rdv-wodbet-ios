import Foundation
import Combine

// ⚠️ ENTREGA ACADÊMICA: DataSource HTTP para participantes no backend Java.
// Fica pronto para telas futuras sem depender de Firestore.
final class BackendParticipantRemoteDataSource {
    private let client: BackendAPIClient

    init(baseURL: URL, authTokenProvider: @escaping () -> String? = { nil }, session: URLSession = .shared) {
        self.client = BackendAPIClient(baseURL: baseURL, session: session, authTokenProvider: authTokenProvider)
    }

    func fetchParticipant(id: String) -> AnyPublisher<ParticipantBackendDTO?, AppError> {
        client.request(path: "participants/\(id)", method: "GET")
            .tryMap { data, response -> ParticipantBackendDTO? in
                switch response.statusCode {
                case 200:
                    return try self.client.decode(ParticipantBackendDTO.self, from: data)
                case 404:
                    return nil
                default:
                    throw BackendAPIClient.error(for: response.statusCode)
                }
            }
            .mapError { $0 as? AppError ?? AppError.network("Não foi possível carregar o participante.") }
            .eraseToAnyPublisher()
    }

    func fetchParticipants() -> AnyPublisher<[ParticipantBackendDTO], AppError> {
        client.request(path: "participants", method: "GET")
            .tryMap { data, response -> [ParticipantBackendDTO] in
                guard response.statusCode == 200 else {
                    throw BackendAPIClient.error(for: response.statusCode)
                }
                return try self.client.decodeCollection(ParticipantBackendDTO.self, from: data)
            }
            .mapError { $0 as? AppError ?? AppError.network("Não foi possível carregar os participantes.") }
            .eraseToAnyPublisher()
    }

    func createParticipant(name: String, email: String?, phone: String?) -> AnyPublisher<Void, AppError> {
        performVoid(
            path: "participants",
            method: "POST",
            body: BackendCreateParticipantRequestDTO(name: name, email: email, phone: phone)
        )
    }

    func updateParticipant(id: String, name: String?, phone: String?) -> AnyPublisher<Void, AppError> {
        performVoid(
            path: "participants/\(id)",
            method: "PATCH",
            body: BackendUpdateParticipantRequestDTO(name: name, phone: phone)
        )
    }

    private func performVoid<T: Encodable>(path: String, method: String, body: T) -> AnyPublisher<Void, AppError> {
        guard let requestBody = try? JSONEncoder().encode(body) else {
            return Fail(error: .unknown).eraseToAnyPublisher()
        }
        return client.request(path: path, method: method, body: requestBody)
            .tryMap { _, response in
                guard (200...299).contains(response.statusCode) else {
                    throw BackendAPIClient.error(for: response.statusCode)
                }
                return ()
            }
            .mapError { $0 as? AppError ?? AppError.network("A operação não pôde ser concluída.") }
            .eraseToAnyPublisher()
    }
}

