import Foundation
import Combine

final class BackendUserRemoteDataSource {
    private let client: BackendAPIClient

    init(
    baseURL: URL,
    authTokenProvider: @escaping () -> String? = { nil },
    session: URLSession = .shared
    ) {
        self.client = BackendAPIClient(
            baseURL: baseURL,
            session: session,
            authTokenProvider: authTokenProvider
        )
    }

    func fetchUser(id: String) -> AnyPublisher<BackendUserDTO?, AppError> {
        client.request(path: "users/\(id)", method: "GET")
        .tryMap { data, response -> BackendUserDTO? in
            let raw = String(data: data, encoding: .utf8) ?? "sem body"
            print("GET /users/\(id) status:", response.statusCode)
            print("GET /users/\(id) raw:", raw)

            switch response.statusCode {
            case 200:
                return try self.client.decode(BackendUserDTO.self, from: data)

            case 404:
                return nil

            default:
                throw BackendAPIClient.error(for: response.statusCode)
            }
        }
        .mapError { error in
            if let appError = error as? AppError {
                return appError
            }
            return AppError.network("Não foi possível carregar o usuário.")
        }
        .eraseToAnyPublisher()
    }

    func fetchUsers() -> AnyPublisher<[BackendUserDTO], AppError> {
        client.request(path: "users", method: "GET")
        .tryMap { data, response -> [BackendUserDTO] in
            let raw = String(data: data, encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

            print("GET /users status:", response.statusCode)
            print("GET /users raw:", raw)

            switch response.statusCode {
            case 200:
                if raw.isEmpty || raw == "[]" || raw == "null" || raw == "{}" {
                    return []
                }

                return try self.client.decodeCollection(BackendUserDTO.self, from: data)

            case 204:
                return []

            default:
                throw BackendAPIClient.error(for: response.statusCode)
            }
        }
        .mapError { error in
            if let appError = error as? AppError {
                return appError
            }

            print("❌ Erro ao decodificar /users:", error)
            return AppError.network("Não foi possível carregar os usuários.")
        }
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
            let raw = String(data: data, encoding: .utf8) ?? "sem body"
            print("PUT /users/\(id) status:", response.statusCode)
            print("PUT /users/\(id) raw:", raw)

            switch response.statusCode {
            case 200, 201:
                return try self.client.decode(BackendUserDTO.self, from: data)

            default:
                throw BackendAPIClient.error(for: response.statusCode)
            }
        }
        .mapError { error in
            if let appError = error as? AppError {
                return appError
            }
            return AppError.network("Não foi possível atualizar o usuário.")
        }
        .eraseToAnyPublisher()
    }
}