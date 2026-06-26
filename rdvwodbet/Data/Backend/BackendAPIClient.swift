import Foundation
import Combine

// ⚠️ ENTREGA ACADÊMICA: cliente HTTP compartilhado para chamadas ao backend Java.
// Centraliza URLSession, cabeçalho de autorização e conversão de falhas de rede.
final class BackendAPIClient {
    private let baseURL: URL
    private let session: URLSession
    private let authTokenProvider: () -> String?

    init(
        baseURL: URL,
        session: URLSession = .shared,
        authTokenProvider: @escaping () -> String? = { nil }
    ) {
        self.baseURL = baseURL
        self.session = session
        self.authTokenProvider = authTokenProvider
    }

    func request(
        path: String,
        method: String,
        body: Data? = nil,
        headers: [String: String] = [:]
    ) -> AnyPublisher<(Data, HTTPURLResponse), AppError> {
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }

        if let token = authTokenProvider()?.trimmingCharacters(in: .whitespacesAndNewlines), !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        return session.dataTaskPublisher(for: request)
            .tryMap { output -> (Data, HTTPURLResponse) in
                guard let http = output.response as? HTTPURLResponse else {
                    throw AppError.network("Resposta inválida do servidor.")
                }
                return (output.data, http)
            }
            .mapError { error in
                Self.mapError(error)
            }
            .eraseToAnyPublisher()
    }

    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        do {
            return try JSONDecoder.backendDecoder.decode(T.self, from: data)
        } catch {
            throw AppError.network("Não foi possível interpretar a resposta do servidor.")
        }
    }

    func decodeCollection<T: Decodable>(_ type: T.Type, from data: Data) throws -> [T] {
        if let array = try? JSONDecoder.backendDecoder.decode([T].self, from: data) {
            return array
        }

        if let envelope = try? JSONDecoder.backendDecoder.decode(BackendCollectionEnvelope<T>.self, from: data),
           let resolved = envelope.resolvedItems {
            return resolved
        }

        throw AppError.network("Não foi possível interpretar a lista retornada pelo servidor.")
    }

    static func error(for statusCode: Int) -> AppError {
        switch statusCode {
        case 400:
            return .invalidInput("Dados inválidos.")
        case 401:
            return .notAuthenticated
        case 403:
            return .permissionDenied
        case 404:
            return .dataNotFound
        case 500:
            return .network("Erro interno do servidor.")
        default:
            return .network("Erro inesperado no servidor.")
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

private struct BackendCollectionEnvelope<Element: Decodable>: Decodable {
    let items: [Element]?
    let content: [Element]?
    let data: [Element]?
    let results: [Element]?

    var resolvedItems: [Element]? {
        items ?? content ?? data ?? results
    }
}

private extension JSONDecoder {
    static var backendDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        return decoder
    }
}
