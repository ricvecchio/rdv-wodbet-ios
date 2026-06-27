import Foundation
import Combine

// ⚠️ ENTREGA ACADÊMICA: DataSource HTTP para apostas no backend Java.
// Substitui Firestore no feed, criação, votação e finalização das apostas.
final class BackendBetRemoteDataSource {
    private let client: BackendAPIClient

    init(baseURL: URL, authTokenProvider: @escaping () -> String? = { nil }, session: URLSession = .shared) {
        self.client = BackendAPIClient(baseURL: baseURL, session: session, authTokenProvider: authTokenProvider)
    }

    func fetchBets() -> AnyPublisher<[BetBackendDTO], AppError> {
        client.request(path: "bets", method: "GET")
            .tryMap { data, response -> [BetBackendDTO] in
                print("GET /bets status: \(response.statusCode)")
                print(String(data: data, encoding: .utf8) ?? "sem body")

                let raw = String(data: data, encoding: .utf8)?
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                print("GET /bets raw:", raw ?? "nil")

                // Tratar status 204 (No Content) como sucesso com lista vazia
                if response.statusCode == 204 {
                    return []
                }

                guard response.statusCode == 200 else {
                    throw BackendAPIClient.error(for: response.statusCode)
                }

                if raw == "[]" || raw == "" || raw == "null" || raw == "{}" {
                    return []
                }

                // Tentativa de decodificar diretamente como array vazio
                if data.isEmpty {
                    return []
                }

                // Verify if response is an error object from backend (contains error fields)
                if let errorObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   errorObject["error"] != nil || errorObject["message"] != nil {
                    // Backend returned an error response, not an array
                    if let message = errorObject["message"] as? String {
                        throw AppError.network("Erro do servidor: \(message)")
                    }
                    throw AppError.network("Erro ao carregar apostas.")
                }

                return try self.client.decodeCollection(BetBackendDTO.self, from: data)
            }
            .mapError { $0 as? AppError ?? AppError.network("Não foi possível carregar as apostas.") }
            .eraseToAnyPublisher()
    }

    func createBet(_ bet: Bet) -> AnyPublisher<Void, AppError> {
        let body = BackendBetMapper.toCreateRequest(bet)
        return performVoid(path: "bets", method: "POST", body: body)
    }

    func voteOnBet(betId: String, voterUserId: String, votedAthleteUserId: String) -> AnyPublisher<Void, AppError> {
        performVoid(
            path: "bets/\(betId)/vote",
            method: "PUT",
            body: BackendVoteOnBetRequestDTO(voterUserId: voterUserId, votedAthleteUserId: votedAthleteUserId)
        )
    }

    func proposeWinner(betId: String, requesterUserId: String, proposedWinnerUserId: String) -> AnyPublisher<Void, AppError> {
        performVoid(
            path: "bets/\(betId)/winner",
            method: "PUT",
            body: BackendProposeWinnerRequestDTO(
                requesterUserId: requesterUserId,
                proposedWinnerUserId: proposedWinnerUserId
            )
        )
    }

    func confirmWinner(betId: String, confirmerUserId: String) -> AnyPublisher<Void, AppError> {
        performVoid(
            path: "bets/\(betId)/confirm",
            method: "PUT",
            body: BackendConfirmWinnerRequestDTO(confirmerUserId: confirmerUserId)
        )
    }

    func rejectWinner(betId: String, rejectorUserId: String) -> AnyPublisher<Void, AppError> {
        performVoid(
            path: "bets/\(betId)/reject",
            method: "PUT",
            body: BackendRejectWinnerRequestDTO(rejectorUserId: rejectorUserId)
        )
    }

    func cancelBet(betId: String, requesterUserId: String) -> AnyPublisher<Void, AppError> {
        performVoid(
            path: "bets/\(betId)/cancel",
            method: "PUT",
            body: BackendCancelBetRequestDTO(requesterUserId: requesterUserId)
        )
    }

    func updateBetResult(
        betId: String,
        requesterUserId: String,
        athleteAResult: String,
        athleteBResult: String,
        winnerUserId: String
    ) -> AnyPublisher<Void, AppError> {
        performVoid(
            path: "bets/\(betId)/result",
            method: "PUT",
            body: BackendUpdateBetResultRequestDTO(
                requesterUserId: requesterUserId,
                athleteAResult: athleteAResult,
                athleteBResult: athleteBResult,
                winnerUserId: winnerUserId
            )
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

