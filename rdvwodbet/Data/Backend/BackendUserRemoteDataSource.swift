import Foundation
import Combine

// ⚠️ ENTREGA ACADÊMICA: DataSource HTTP para usuários no backend Java.
// Substitui leituras/edições em Firestore no fluxo principal do app.
final class BackendUserRemoteDataSource {
    private let client: BackendAPIClient

    init(baseURL: URL, authTokenProvider: @escaping () -> String? = { nil }, session: URLSession = .shared) {
        self.client = BackendAPIClient(baseURL: baseURL, session: session, authTokenProvider: authTokenProvider)
    }

    func fetchUser(id: String) -> AnyPublisher<BackendUserDTO?, AppError> {
        client.request(path: "users/\(id)", method: "GET")
            .tryMap { data, response -> BackendUserDTO? in
                switch response.statusCode {
                case 200:
                    return try self.client.decode(BackendUserDTO.self, from: data)
                case 404:
                    return nil
                default:
                    throw BackendAPIClient.error(for: response.statusCode)
                }
            }
            .mapError { $0 as? AppError ?? AppError.network("Não foi possível carregar o usuário.") }
            .eraseToAnyPublisher()
    }

    func fetchUsers() -> AnyPublisher<[BackendUserDTO], AppError> {
        client.request(path: "users", method: "GET")
            .tryMap { data, response -> [BackendUserDTO] in
                switch response.statusCode {
                case 200:
                    return try self.client.decodeCollection(BackendUserDTO.self, from: data)
                default:
                    throw BackendAPIClient.error(for: response.statusCode)
                }
            }
            .mapError { $0 as? AppError ?? AppError.network("Não foi possível carregar os usuários.") }
            .eraseToAnyPublisher()
    }

    func upsertUser(
        id: String,
        name: String,
        description: String?,
        phone: String?,
        photoUrl: String?
    ) -> AnyPublisher<BackendUserDTO, AppError> {
        let requestDTO = UpdateUserProfileRequestDTO(
            name: name,
            description: description,
            phone: phone,
            photoUrl: photoUrl
        )

        guard let body = try? JSONEncoder().encode(requestDTO) else {
            return Fail(error: .unknown).eraseToAnyPublisher()
        }

        return client.request(path: "users/\(id)", method: "PUT", body: body)
            .tryMap { data, response -> BackendUserDTO in
                switch response.statusCode {
                case 200, 201:
                    return try self.client.decode(BackendUserDTO.self, from: data)
                default:
                    throw BackendAPIClient.error(for: response.statusCode)
                }
            }
            .mapError { $0 as? AppError ?? AppError.network("Não foi possível atualizar o usuário.") }
            .eraseToAnyPublisher()
    }
}

