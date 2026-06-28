import Foundation

/// Centraliza valores que podem mudar por ambiente (dev/prod), feature flags etc.
struct AppEnvironment {
    let appName: String = "RDV WODBet"

    // ⚠️ ENTREGA ACADÊMICA: URL base do backend Java para autenticação por telefone.
    // Altere para o endereço real do servidor antes de testar.
    // Ex.: "http://192.168.1.10:8080" para rede local, ou a URL do servidor hospedado.
    let backendBaseURL: URL = URL(string: "http://localhost:8080")!
}
