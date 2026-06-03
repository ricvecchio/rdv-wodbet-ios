import Foundation
import Combine

// ⚠️ ENTREGA ACADÊMICA: DataSource de rede para autenticação via telefone (backend Java).
// Utiliza URLSession + Combine (via Future). Não contém lógica de negócio.

// Resultado bruto da rota POST /users/login antes do mapeamento de domínio.
enum PhoneLoginRawResult {
    case loggedIn(BackendUserDTO)
    case codeRequired
}

final class PhoneAuthRemoteDataSource {

    private let baseURL: URL
    private let session: URLSession

    init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    // MARK: - POST /users/login

    func loginWithPhone(phone: String, uuid: String) -> AnyPublisher<PhoneLoginRawResult, AppError> {
        let url = baseURL.appendingPathComponent("users/login")
        let body = PhoneLoginRequestDTO(phone: phone, uuid: uuid)

        return makeRequest(url: url, method: "POST", body: body)
            .tryMap { (data, response) -> PhoneLoginRawResult in
                try Self.parseLoginResponse(data: data, response: response)
            }
            .mapError(Self.mapError)
            .eraseToAnyPublisher()
    }

    // MARK: - POST /users/confirm

    func confirmPhone(phone: String, uuid: String, code: String) -> AnyPublisher<BackendUserDTO, AppError> {
        let url = baseURL.appendingPathComponent("users/confirm")
        let body = PhoneConfirmRequestDTO(phone: phone, uuid: uuid, code: code)

        return makeRequest(url: url, method: "POST", body: body)
            .tryMap { (data, response) -> BackendUserDTO in
                try Self.parseUserResponse(data: data, response: response)
            }
            .mapError(Self.mapError)
            .eraseToAnyPublisher()
    }

    // MARK: - PUT /users/{id}

    func updateUserProfile(userId: String, name: String, description: String?) -> AnyPublisher<BackendUserDTO, AppError> {
        let url = baseURL.appendingPathComponent("users/\(userId)")
        let body = UpdateUserProfileRequestDTO(name: name, description: description, phone: nil)

        return makeRequest(url: url, method: "PUT", body: body)
            .tryMap { (data, response) -> BackendUserDTO in
                try Self.parseUserResponse(data: data, response: response)
            }
            .mapError(Self.mapError)
            .eraseToAnyPublisher()
    }

    // MARK: - Private Helpers

    private func makeRequest<T: Encodable>(
        url: URL,
        method: String,
        body: T
    ) -> AnyPublisher<(Data, URLResponse), Error> {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }

        // mapError converts URLError → Error to match the return type
        return session.dataTaskPublisher(for: request)
            .map { ($0.data, $0.response) }
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }

    private static func parseLoginResponse(data: Data, response: URLResponse) throws -> PhoneLoginRawResult {
        guard let http = response as? HTTPURLResponse else {
            throw AppError.network("Resposta inválida do servidor.")
        }
        switch http.statusCode {
        case 200:
            let dto = try decodeUser(from: data)
            return .loggedIn(dto)
        case 202:
            return .codeRequired
        default:
            throw errorForStatus(http.statusCode, data: data)
        }
    }

    private static func parseUserResponse(data: Data, response: URLResponse) throws -> BackendUserDTO {
        guard let http = response as? HTTPURLResponse else {
            throw AppError.network("Resposta inválida do servidor.")
        }
        switch http.statusCode {
        case 200:
            return try decodeUser(from: data)
        case 400, 401:
            let msg = decodeErrorMessage(from: data) ?? "Dados inválidos."
            throw AppError.invalidInput(msg)
        case 404:
            throw AppError.dataNotFound
        default:
            throw errorForStatus(http.statusCode, data: data)
        }
    }

    private static func decodeUser(from data: Data) throws -> BackendUserDTO {
        do {
            return try JSONDecoder().decode(BackendUserDTO.self, from: data)
        } catch {
            throw AppError.network("Não foi possível interpretar a resposta do servidor.")
        }
    }

    private static func decodeErrorMessage(from data: Data) -> String? {
        let dto = try? JSONDecoder().decode(BackendErrorDTO.self, from: data)
        return dto?.message ?? dto?.error
    }

    private static func errorForStatus(_ statusCode: Int, data: Data) -> AppError {
        let msg = decodeErrorMessage(from: data)
        switch statusCode {
        case 400, 401:
            return .invalidInput(msg ?? "Dados inválidos.")
        case 403:
            return .permissionDenied
        case 404:
            return .dataNotFound
        default:
            return .network(msg ?? "Erro \(statusCode) no servidor.")
        }
    }

    private static func mapError(_ error: Error) -> AppError {
        if let appError = error as? AppError { return appError }
        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain {
            return .network("Sem conexão com a internet. Verifique sua rede.")
        }
        return .network(error.localizedDescription)
    }
}
