import Foundation
import Combine

// ⚠️ ENTREGA ACADÊMICA: DataSource de rede para autenticação via telefone (backend Java).
// Utiliza URLSession + Combine (via Future). Não contém lógica de negócio.

// Resultado bruto da rota POST /users/login antes do mapeamento de domínio.
enum PhoneLoginRawResult {
    case loggedIn(AuthServerSessionDTO)
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

    func confirmPhone(phone: String, uuid: String, code: String) -> AnyPublisher<AuthServerSessionDTO, AppError> {
        let url = baseURL.appendingPathComponent("users/confirm")
        let body = PhoneConfirmRequestDTO(phone: phone, uuid: uuid, code: code)

        return makeRequest(url: url, method: "POST", body: body)
            .tryMap { (data, response) -> AuthServerSessionDTO in
                try Self.parseAuthSessionResponse(data: data, response: response)
            }
            .mapError(Self.mapError)
            .eraseToAnyPublisher()
    }

    // MARK: - PUT /users/{id}

    func updateUserProfile(
        userId: String,
        name: String,
        description: String?,
        phone: String?,
        photoUrl: String?
    ) -> AnyPublisher<BackendUserDTO, AppError> {
        let url = baseURL.appendingPathComponent("users/\(userId)")
        let body = UpdateUserProfileRequestDTO(name: name, description: description, phone: phone, photoUrl: photoUrl)

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
            return .loggedIn(try parseAuthSessionResponse(data: data, response: response))
        case 202:
            return .codeRequired
        default:
            throw errorForStatus(http.statusCode, data: data)
        }
    }

    private static func parseAuthSessionResponse(data: Data, response: URLResponse) throws -> AuthServerSessionDTO {
        guard let http = response as? HTTPURLResponse else {
            throw AppError.network("Resposta inválida do servidor.")
        }
        guard http.statusCode == 200 else {
            throw errorForStatus(http.statusCode, data: data)
        }

        let authResponse = try decodeAuthResponse(from: data)
        let jwtFromHeader = extractJWTFromAuthorizationHeader(http)
        guard let jwt = (authResponse.resolvedToken ?? jwtFromHeader)?.trimmingCharacters(in: .whitespacesAndNewlines),
              !jwt.isEmpty
        else {
            throw AppError.network("Resposta de autenticação inválida.")
        }

        guard let user = authResponse.resolvedUser else {
            throw AppError.network("Dados do usuário não foram retornados.")
        }

        return AuthServerSessionDTO(jwt: jwt, user: user)
    }

    private static func parseUserResponse(data: Data, response: URLResponse) throws -> BackendUserDTO {
        guard let http = response as? HTTPURLResponse else {
            throw AppError.network("Resposta inválida do servidor.")
        }
        switch http.statusCode {
        case 200:
            return try decodeUser(from: data)
        case 400:
            throw AppError.invalidInput("Dados inválidos.")
        case 401:
            throw AppError.invalidInput("Credenciais inválidas.")
        case 404:
            throw AppError.dataNotFound
        case 500:
            throw AppError.network("Erro interno do servidor.")
        default:
            throw errorForStatus(http.statusCode, data: data)
        }
    }

    private static func decodeAuthResponse(from data: Data) throws -> AuthServerResponseDTO {
        do {
            return try JSONDecoder().decode(AuthServerResponseDTO.self, from: data)
        } catch {
            throw AppError.network("Não foi possível interpretar a resposta de autenticação.")
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
        switch statusCode {
        case 400:
            return .invalidInput("Dados inválidos.")
        case 401:
            return .invalidInput("Credenciais inválidas.")
        case 403:
            return .permissionDenied
        case 404:
            return .dataNotFound
        case 500:
            return .network("Erro interno do servidor.")
        default:
            let msg = decodeErrorMessage(from: data)
            return .network(msg ?? "Erro \(statusCode) no servidor.")
        }
    }

    private static func extractJWTFromAuthorizationHeader(_ response: HTTPURLResponse) -> String? {
        guard let rawValue = response.value(forHTTPHeaderField: "Authorization") else { return nil }
        let prefix = "Bearer "
        if rawValue.hasPrefix(prefix) {
            return String(rawValue.dropFirst(prefix.count))
        }
        return rawValue
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
