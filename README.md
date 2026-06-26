# 📱 RDV WODBet – App Mobile iOS (SwiftUI)

O **RDV WODBet** é um aplicativo mobile iOS desenvolvido em **SwiftUI**, focado em **apostas divertidas entre amigos do box de CrossFit**.  
Qualquer usuário autenticado pode criar uma aposta entre dois atletas com base no **WOD do dia** e definir um **prêmio simbólico** (água, gatorade, cerveja, shake ou "outro").

Todas as apostas ficam visíveis em um **feed público**, com status **Aberta**, **Finalizada**, **Cancelada**, **Em disputa** ou **Expirada**.  
O resultado só é validado quando **ambos os atletas confirmam o vencedor**, garantindo fair play e mantendo a brincadeira organizada.

> ⚠️ **Entrega Acadêmica — Backend Java no fluxo principal:** o app continua com os arquivos Firebase/Firestore preservados no projeto, mas o fluxo principal após o login passou a consumir **users**, **participants** e **bets** diretamente do backend Java. O Firebase ficou isolado/comentado para possível retorno futuro.

---

## Migração do fluxo principal para o backend Java

Após a autenticação por telefone + UUID, o app passa a usar a URL base configurada em `AppEnvironment.backendBaseURL` para consumir os dados principais do backend Java.

### Endpoints utilizados no fluxo atual

- **Usuários**
  - `GET /users`
  - `GET /users/{id}`
  - `GET /users/{id}/raw`
  - `PUT /users/{id}`
- **Participantes**
  - `GET /participants`
  - `GET /participants/{id}`
  - `POST /participants`
  - `PATCH /participants/{id}`
- **Apostas / Bets**
  - `GET /bets`
  - `GET /bets/{id}`
  - `POST /bets`
  - `PUT /bets/{id}/vote`
  - `PUT /bets/{id}/winner`
  - `PUT /bets/{id}/confirm`
  - `PUT /bets/{id}/reject`
  - `PUT /bets/{id}/cancel`
  - `PUT /bets/{id}/result`

### Estrutura de dados usada no app

- `AppUser` representa o usuário logado e a lista de usuários exibida no feed/criação de aposta.
- `Bet` continua sendo o modelo de domínio usado pela UI do feed e dos detalhes.
- `Participant` foi adicionado como preparo para futuras telas/listas de participantes.

### Configuração da URL base

- **Simulador iOS:** `http://localhost:8080`
- **Dispositivo físico:** use o IP do Mac na rede local, por exemplo `http://192.168.1.10:8080`
- **Servidor remoto:** use a URL pública/HTTPS do backend, se disponível

> A configuração principal fica em `App/AppEnvironment.swift`.

---

## Conceito do Aplicativo

No **RDV WODBet**:

1. Um usuário faz login informando seu **número de telefone**
2. Se o telefone + uuid do dispositivo já forem conhecidos, o acesso é imediato
3. Caso contrário, um **código de confirmação** é enviado por SMS (ou simulado via log no ambiente acadêmico)
4. Após confirmar o código, o usuário define um **apelido no box**
5. Cria uma aposta escolhendo **Atleta A vs Atleta B**
6. Define o **WOD do dia**
7. Define o **prêmio da aposta**

### Exemplos de prêmio
- Água
- Gatorade
- Cerveja
- Shake
- Outro (customizado)

### Status possíveis

| Status | Significado |
|---|---|
| ⏳ Aberta | A aposta ainda não foi resolvida |
| 🏁 Finalizada | O vencedor foi confirmado |
| ❌ Cancelada | A aposta foi cancelada |
| ⚔️ Disputa | Houve discordância sobre o vencedor |
| ⌛ Expirada | A aposta passou da data de expiração sem resolução |

> Uma aposta **só é finalizada quando ambos os atletas confirmam o vencedor**.

---

## Tecnologias Utilizadas

### Aplicação
- Swift
- SwiftUI
- Combine
- NavigationStack
- SF Symbols
- UIKit (`UIDevice.identifierForVendor`)
- iOS 16+

### Backend e infraestrutura — Entrega Acadêmica (ativo)
- Backend Java (REST API)
  - `POST /users/login` — login por telefone + uuid
  - `POST /users/confirm` — confirmação de código SMS
  - `PUT /users/{id}` — atualização de perfil
- `URLSession` + Combine para as chamadas HTTP
- `UserDefaults` — sessão local encapsulada em `SessionManager`

### Backend e infraestrutura — Firebase (preservado, temporariamente inativo)
- Firebase Core
- Firebase Authentication (Email/Password, Anônimo)
- Firebase Firestore

### Gerenciamento de dependências
- Swift Package Manager (preferido)
- Suporte a CocoaPods se preferir (não incluído no repositório)

---

## Arquitetura do Projeto

O projeto foi desenvolvido utilizando **Clean Architecture + MVVM**.

A aplicação é dividida em camadas, facilitando testes e evolução:

- `App/` — Entrypoint e configuração global
  - `RDVWODBetApp.swift` — App principal; chama o configurador do Firebase.
  - `AppDIContainer.swift` — Contêiner de dependências; inclui dependências do backend (ativas) e do Firebase (comentadas/preservadas).
  - `AppEnvironment.swift` — Variáveis de ambiente / flags centralizadas; inclui `backendBaseURL`.
  - `FirebaseConfigurator.swift` — Inicialização do Firebase (`FirebaseApp.configure()`).
- `Data/` — Implementações de acesso a dados
  - `Firebase/` — Data sources Firebase (`FirebaseAuthDataSource.swift`, `FirestoreUserDataSource.swift`, `FirestoreBetDataSource.swift`) — **preservados**.
  - `Backend/` — ⚠️ *Novo (entrega acadêmica)*:
    - `PhoneAuthRemoteDataSource.swift` — autenticação por telefone (`/users/login`, `/users/confirm`, `/users/{id}`).
    - `BackendUserRemoteDataSource.swift` — consumo de usuários (`/users`).
    - `BackendParticipantRemoteDataSource.swift` — consumo de participantes (`/participants`).
    - `BackendBetRemoteDataSource.swift` — consumo de apostas (`/bets` e ações de aposta).
    - `BackendAPIClient.swift` — cliente HTTP compartilhado + decode tolerante de coleções (array/envelope).
  - `Session/` — ⚠️ *Novo (entrega acadêmica)* — `SessionManager.swift` — persistência de sessão local via `UserDefaults`.
  - `Repositories/` — Implementações de repositórios backend e Firebase; inclui `PhoneAuthRepository.swift`, `BackendUserRepository.swift`, `BackendParticipantRepository.swift`, `BackendBetRepository.swift`.
  - `DTOs/` — `AppUserDTO`, `BetDTO` (Firebase) + `BackendUserDTO`, `ParticipantBackendDTO`, `BetBackendDTO`, `PhoneLoginRequestDTO`, `PhoneConfirmRequestDTO`, `UpdateUserProfileRequestDTO` (novos).
  - `Mappers/` — `AppUserMapper` (Firebase/Firestore) + `BackendUserMapper`, `ParticipantBackendMapper`, `BetBackendMapper`.
- `Domain/` — Entidades, protocolos e use cases
  - `Entities/` — `AppUser` (campo `phone: String?` adicionado), `Bet`, `BetStatus`, `PrizeType`.
  - `Protocols/` — `AuthRepository`, `UserRepository`, `BetRepository` (Firebase, preservados) + `PhoneAuthRepositoryProtocol` (novo).
  - `UseCases/` — Use cases de apostas (`ObserveBetsUseCase`, `CreateBetUseCase`, `ProposeWinnerUseCase`, `ConfirmWinnerUseCase`, `RejectWinnerUseCase`, `CancelBetUseCase`, `UpdateBetResultUseCase`, `VoteOnBetUseCase`) + `LoginWithPhoneUseCase`, `ConfirmPhoneLoginUseCase`, `UpdateUserProfileUseCase`.
- `Presentation/` — Views e ViewModels (SwiftUI)
  - `Auth/` — `AuthView`, `AuthViewModel`, `RegisterView`, `RegisterViewModel`, `DisplayNameOnboardingView`, `DisplayNameOnboardingViewModel` — **preservados, atualmente não exibidos**.
  - `PhoneAuth/` — ⚠️ *Novo (entrega acadêmica)* — `PhoneAuthView`, `PhoneAuthViewModel`, `BackendDisplayNameOnboardingView`, `BackendDisplayNameOnboardingViewModel`.
  - `Feed/`, `CreateBet/`, `BetDetail/`, `Root/` — telas e lógica UI (apostas inalteradas; `RootView` e `FeedView` adaptados).
- `Shared/` — Componentes, tema, utilitários (`Theme/`, `UIComponents/`, `Utils/`).
- `Resources/` — Assets e imagens (`Assets.xcassets`).

### Fluxo arquitetural — Backend Java (ativo)

```text
PhoneAuthView
↓
PhoneAuthViewModel
↓
LoginWithPhoneUseCase / ConfirmPhoneLoginUseCase / UpdateUserProfileUseCase
↓
PhoneAuthRepositoryProtocol
↓
PhoneAuthRepository
↓
PhoneAuthRemoteDataSource
↓
URLSession → Backend Java REST API
           ↓
      SessionManager (UserDefaults)
           ↓
      RootView (observa currentUser)
```

### Fluxo arquitetural — Firebase (preservado, temporariamente inativo)

```text
View
↓
ViewModel
↓
UseCase
↓
Repository
↓
DataSource
↓
Firebase
```

---

## Design Patterns Utilizados

- MVVM
- Repository Pattern
- Use Case Pattern
- Dependency Injection (injeção manual via `AppDIContainer`)
- Protocol-Oriented Programming (contratos separados para Firebase e backend)

O projeto usa boas práticas para manter baixo acoplamento e alta testabilidade.

---

## Estrutura de Navegação

A navegação do aplicativo é centralizada no `RootView`.

### Fluxo de autenticação — Entrega Acadêmica (ativo)

- Usuário deslogado → tela de **Login por Telefone**
- Usuário logado sem apelido → **Onboarding** (apelido do box via backend)
- Usuário logado com perfil completo → **Feed**

```text
PhoneAuthView (etapa: inserir telefone)
↓ Acessar → POST /users/login
├─ HTTP 200 (uuid conhecido) → Feed direto
└─ HTTP 202 (uuid desconhecido)
         ↓ PhoneAuthView (etapa: inserir código)
         ↓ Confirmar → POST /users/confirm
         └─ HTTP 200 → salva sessão local (SessionManager)
                  ↓
         (Onboarding de apelido — se displayName estiver vazio)
                  ↓
         Feed de apostas
```

### Fluxo de autenticação — Firebase (preservado para retorno futuro)

```text
Login (e-mail + senha)
├─ Esqueceu a senha? → Sheet de recuperação por e-mail
└─ Cadastro
       ↓
(Onboarding de apelido — somente se o perfil ainda não existir no Firestore)
       ↓
Feed de apostas
```

### Fluxo funcional do app (apostas — inalterado)

```text
Feed de apostas
       ↓
Criar aposta
       ↓
Detalhe da aposta
```

---

## Autenticação por Telefone

> ⚠️ **Entrega Acadêmica:** fluxo ativo nesta versão.

### Tela de Login por Telefone (`PhoneAuthView`)

| Campo / Elemento | Descrição |
|---|---|
| Campo Telefone | Placeholder `+55 11 99999-9999`, teclado numérico de telefone |
| Botão **Acessar** | Envia `POST /users/login` com `phone` + `uuid` do dispositivo |
| Campo Código | Aparece após HTTP 202; teclado numérico |
| Botão **Confirmar** | Envia `POST /users/confirm` com `phone`, `uuid` e `code` |
| Botão **Voltar** | Retorna à etapa de telefone |
| Mensagens de erro | Em português, cobrindo todos os cenários de falha |

### UUID do dispositivo

O app obtém o identificador do dispositivo conforme especificado:

```swift
UIDevice.current.identifierForVendor?.uuidString
```

### Rotas do backend utilizadas

| Rota | Método | Comportamento |
|---|---|---|
| `/users/login` | POST | `phone` + `uuid` → HTTP 200 (login direto) ou HTTP 202 (código necessário) |
| `/users/confirm` | POST | `phone` + `uuid` + `code` → HTTP 200 (usuário criado/ativado) |
| `/users/{id}` | PUT | Atualiza nome / descrição do usuário |

### Tratamento de respostas HTTP

| Código | Comportamento no app |
|---|---|
| 200 | Salva sessão local com o usuário (com ou sem JWT) e navega para o Feed |
| 202 | Exibe campo de código + mensagem "Enviamos um código de confirmação para seu telefone." |
| 400 / 401 | Exibe mensagem do backend ou "Código inválido. Verifique e tente novamente." |
| 404 | Exibe "Nenhum código de confirmação foi encontrado para este telefone." |
| Erro de rede | Exibe "Sem conexão com a internet. Verifique sua rede." |

### Sessão local (`SessionManager`)

A sessão é persistida via `UserDefaults` com os seguintes campos:

| Chave | Descrição |
|---|---|
| `session_isLoggedIn` | Flag booleana de sessão ativa |
| `session_userId` | ID do usuário retornado pelo backend |
| `session_phone` | Número de telefone |
| `session_name` | Apelido/nome de exibição |
| `session_description` | Descrição/bio do usuário |
| `session_photoURL` | URL da foto de perfil |
| `session_uuid` | UUID do dispositivo |
| `session_createdAt` | Data de criação (timestamp Unix) |
| `session_jwt` | Token JWT (opcional; salvo apenas quando o backend retorna token/header Authorization) |

- `SessionManager.save(user:)` — persiste e publica o usuário logado
- `SessionManager.save(authSession:)` — persiste JWT + dados completos da sessão após login/confirm
- `SessionManager.updateDisplayName(_:)` — atualiza apenas o nome (após onboarding)
- `SessionManager.clear()` — remove a sessão (logout)
- `SessionManager.authToken` — getter do JWT usado nos requests autenticados
- `SessionManager.storedUUID` — getter do UUID persistido em sessão

### Onboarding de Apelido — Backend (`BackendDisplayNameOnboardingView`)

Exibido quando o usuário logado ainda não tem `displayName` preenchido.

- Campo de apelido (mín. 2 caracteres, validado por `Validators.validateDisplayName`)
- Botão **Continuar** — chama `PUT /users/{id}` via `UpdateUserProfileUseCase`, salva na sessão e redireciona ao feed

### Fluxo detalhado do Auth Server (RDV WODBet)

Esta versão utiliza temporariamente o backend **RDV WODBet Auth Server** para autenticação por telefone, mantendo toda a infraestrutura Firebase no projeto para retorno futuro.

### Arquitetura utilizada

```text
PhoneAuthView
-> PhoneAuthViewModel
-> LoginWithPhoneUseCase / ConfirmPhoneLoginUseCase / UpdateUserProfileUseCase
-> PhoneAuthRepositoryProtocol
-> PhoneAuthRepository
-> PhoneAuthRemoteDataSource
-> Auth Server REST API (/users/login, /users/confirm, /users/{id})
-> SessionManager (UserDefaults)
```

### Fluxo completo de login

1. Usuário informa apenas `phone`.
2. App coleta `uuid` do dispositivo.
3. App envia `POST /users/login`.
4. Se HTTP `200`: aceita resposta `token + user` **ou** usuário direto, salva sessão local e navega para o Feed.
5. Se HTTP `202`: navega automaticamente para confirmação e mantém `phone` + `uuid` em memória.

**Request:**

```json
{
  "phone": "+5511999999999",
  "uuid": "A1B2C3D4-E5F6-4711-8A9B-CCDDEEFF0011"
}
```

**Response HTTP 200 (exemplo):**

```json
{
  "token": "<jwt>",
  "user": {
    "id": "123",
    "name": "Ricardo",
    "description": "Atleta do box",
    "phone": "+5511999999999",
    "photoUrl": "https://..."
  }
}
```

**Response HTTP 200 (alternativo, usuário direto):**

```json
{
  "id": "123",
  "name": "Ricardo",
  "description": "Atleta do box",
  "phone": "+5511999999999",
  "photoUrl": "https://..."
}
```

**Response HTTP 202:** sem sessão autenticada; app exibe etapa de código.

### Fluxo de confirmação

1. Usuário informa `code`.
2. App reutiliza `phone` + `uuid` mantidos em memória (não solicita novamente).
3. App envia `POST /users/confirm`.
4. Se HTTP `200`: decodifica usuário confirmado (sem exigir JWT), salva sessão local e navega para o Feed.
5. Se HTTP `404`: exibe mensagem amigável **"Código inválido ou expirado."**.

**Request:**

```json
{
  "phone": "+5511999999999",
  "uuid": "A1B2C3D4-E5F6-4711-8A9B-CCDDEEFF0011",
  "code": "123456"
}
```

**Response HTTP 200 (formato atual do backend):**

```json
{
  "id": "123",
  "name": "Ricardo",
  "description": "Atleta do box",
  "phone": "+5511999999999",
  "photoUrl": "https://..."
}
```

**Response HTTP 200 (formato alternativo aceito):**

```json
{
  "token": "<jwt>",
  "user": {
    "id": "123",
    "name": "Ricardo",
    "description": "Atleta do box",
    "phone": "+5511999999999",
    "photoUrl": "https://..."
  }
}
```

### Atualização de perfil

Endpoint utilizado: `PUT /users/{id}`

Campos suportados:
- `name`
- `description`
- `phone`
- `photoUrl`

**Request:**

```json
{
  "name": "Ricardo Vecchio",
  "description": "Coach",
  "phone": "+5511999999999",
  "photoUrl": "https://..."
}
```

### Códigos HTTP esperados e mensagens

| HTTP | Mensagem no app |
|---|---|
| 400 | Dados inválidos. |
| 401 | Credenciais inválidas. |
| 404 | Código inválido ou expirado. |
| 500 | Erro interno do servidor. |

### Persistência da sessão

Após autenticação (login 200 ou confirmação 200), o app persiste localmente via `SessionManager`:

- JWT (opcional)
- id do usuário
- telefone
- uuid
- nome
- descrição

Na abertura do app, se existir sessão local válida com `userId`, o login não é exibido e o usuário segue para o fluxo autenticado. Se existir JWT, ele também é validado por expiração.

---

## Autenticação Firebase (preservada para retorno futuro)

> ℹ️ Todos os arquivos abaixo permanecem **intactos** no projeto e podem ser reativados.

- Autenticação via **Firebase Authentication**
- Provedor principal: **E-mail e Senha**
- Estrutura preparada para **Sign in with Apple** (stub implementado, não finalizado)
- Login anônimo mantido como utilitário de desenvolvimento (`signInAnonymouslyForDev`)

### Tela de Login (`AuthView`)

| Campo / Elemento | Descrição |
|---|---|
| Campo E-mail | Placeholder `email@teste.com`, teclado de e-mail |
| Campo Senha | Campo seguro (`SecureField`) |
| Link "Esqueceu a senha?" | Abre sheet de recuperação de senha |
| Botão **Acessar** | Autentica via `signIn(email:password:)` no Firebase |
| Link **Cadastre-se** | Navega para a tela de cadastro |

### Tela de Cadastro (`RegisterView`)

| Campo / Elemento | Descrição |
|---|---|
| Campo Nome | Nome de exibição do atleta (mín. 2 caracteres) |
| Campo E-mail | E-mail para criação da conta Firebase |
| Campo Senha | Senha com mínimo de 6 caracteres |
| Botão **Criar Conta** | Cria conta no Firebase Auth + salva perfil no Firestore |
| Link **Já tenho conta — Voltar ao login** | Retorna à tela de login |

> Após o cadastro, o perfil do usuário (nome) é salvo diretamente no Firestore, evitando a tela de onboarding de apelido.

### Recuperação de Senha (`ForgotPasswordSheet`)

Sheet que abre ao tocar em "Esqueceu a senha?":
- Campo de e-mail (pré-preenchido se já digitado na tela de login)
- Botão **Enviar** — dispara `sendPasswordReset(withEmail:)` do Firebase
- Mensagem de confirmação em caso de sucesso

### Como restaurar o fluxo Firebase

1. Em `AppDIContainer.swift`: descomentar os blocos `// MARK: Firebase DataSources`, `// MARK: Firebase Repositories` e `// MARK: Firebase UseCases`.
2. Em `RootView.swift`: substituir o bloco `SessionManager` pelo bloco `AuthViewModel` (comentado no arquivo).
3. Em `FeedView.swift`: alterar o logout de `container.sessionManager.clear()` de volta para `try? container.authRepository.signOut()`.
4. Todo o restante da camada de apresentação Firebase (`AuthView`, `RegisterView`, etc.) já está preservado e funciona sem alterações adicionais.

---

## Onboarding de Apelido — Firebase (`DisplayNameOnboardingView`)

> ℹ️ Preservado. Exibido somente quando o fluxo Firebase estiver ativo e o usuário estiver autenticado mas ainda não tiver perfil criado no Firestore (ex: login anônimo pela primeira vez).

- Campo de apelido (mín. 2 caracteres, validado por `Validators.validateDisplayName`)
- Botão **Continuar** — salva no Firestore via `userRepository.createUserIfNeeded` e redireciona ao feed

---

## Feed de Apostas

Tela principal do aplicativo.

### Funcionalidades
- Exibição de apostas carregadas via `GET /bets` no backend Java
- Recarregamento do feed ao reabrir a tela ou após ações que alterem o estado da aposta
- Ordenação por data (mais recentes primeiro)
- Estado vazio com CTA para criar a primeira aposta

### Compatibilidade de payload no `GET /bets`

O parse de apostas no app está tolerante ao formato retornado pelo backend Java:

- Aceita resposta como **array puro** (`[BetBackendDTO]`) ou **envelope** com `items`, `content`, `data` ou `results`
- Também resolve envelope aninhado (ex.: paginação Spring com `content`)
- `id` e IDs relacionados podem vir como string ou número
- Campos opcionais ausentes usam defaults seguros (`votesByUserId = [:]`, `athleteAConfirmed = false`, `athleteBConfirmed = false`)
- `status` e `prizeType` desconhecidos fazem fallback seguro no mapper (`.open` e `.water`)
- Datas inválidas/ausentes não quebram o parse

Quando o decode de coleção falha, `BackendAPIClient.decodeCollection` imprime temporariamente o body bruto para debug.

### Cada card do feed mostra
- Atletas envolvidos
- WOD do dia
- Prêmio
- Status da aposta
- Barra visual de votação com percentual por atleta
- Nome do vencedor (quando finalizada)

### Votação no card
Qualquer usuário autenticado pode votar em qual atleta vencerá enquanto a aposta estiver **Aberta** ou **Em disputa**.  
O resultado da votação é exibido em tempo real com cores indicativas (verde para líder, vermelho para perdendo).

---

## Criar Aposta (`CreateBetView`)

Qualquer usuário autenticado pode criar uma aposta.

### Campos obrigatórios
- **Atleta A** — seleção via menu (lista de usuários cadastrados)
- **Atleta B** — seleção via menu (diferente do Atleta A)
- **WOD do dia** — texto livre
- **Tipo de prêmio** — seleção via menu
- **Data de expiração** — via `DatePicker` (calendário gráfico)

### Tipos de prêmio disponíveis
- Água
- Gatorade
- Cerveja
- Shake
- Outro (com campo de descrição obrigatório)

---

## Detalhe da Aposta (`BetDetailView`)

### Informações exibidas
- Confronto: Atleta A vs Atleta B
- Status atual
- WOD, prêmio, data de criação, data de expiração
- Resultado per atleta (quando disponível)
- Vencedor proposto / confirmado

### Ações disponíveis

| Ação | Quem pode executar |
|---|---|
| **Cancelar aposta** | Criador da aposta (status Aberta ou Em disputa) |
| **Salvar resultado** | Criador da aposta (registra tempos + propõe vencedor) |
| Confirmação de vencedor | Atletas envolvidos (via `ConfirmWinnerUseCase`) |
| Rejeição de vencedor | Atletas envolvidos (via `RejectWinnerUseCase`) |

---

## Regras de Negócio

Centralizadas em `Shared/Utils/Validators.swift` e nos `UseCases`.

### Validações implementadas

| Validação | Local |
|---|---|
| Atletas diferentes (A ≠ B) | `Validators.validateCreateBet` |
| WOD não pode ser vazio | `Validators.validateCreateBet` |
| Prêmio "Outro" exige descrição | `Validators.validateCreateBet` |
| Apelido do usuário mínimo 2 chars | `Validators.validateDisplayName` |
| Telefone não pode ser vazio (mín. 8 chars) | `PhoneAuthViewModel.requestCode()` |
| Código de confirmação não pode ser vazio | `PhoneAuthViewModel.confirmCode()` |
| Nome do cadastro mínimo 2 chars | `RegisterViewModel.signUp()` (Firebase) |
| Senha mínimo 6 caracteres | `RegisterViewModel.signUp()` (Firebase) |
| E-mail e senha obrigatórios no login | `AuthViewModel.signInWithEmail()` (Firebase) |

---

## Confirmação de Resultado

O fluxo de confirmação segue estas etapas:

1. O criador da aposta registra os resultados e propõe um vencedor (`ProposeWinnerUseCase`)
2. Ambos os atletas precisam confirmar o vencedor proposto (`ConfirmWinnerUseCase`)
3. Se ambos confirmarem → aposta é **finalizada** (`status = .finished`)
4. Se um atleta rejeitar → status vai para **Em disputa** (`status = .disputed`)

---

## Testes Unitários

O projeto inclui testes unitários focados principalmente na camada de domínio.

### Arquivos de teste
- `CancelBetUseCaseTests.swift`
- `ConfirmWinnerUseCaseTests.swift`
- `CreateBetUseCaseTests.swift`
- `ValidatorsCreateBetTests.swift`
- `ValidatorsDisplayNameTests.swift`

### Suporte
- `BetRepositorySpy.swift` — spy/mock para `BetRepository` utilizado nos testes

### Executar testes
- No Xcode: **Product → Test** (⌘U)
- Via linha de comando:

```bash
xcodebuild test -scheme rdvwodbet -destination 'platform=iOS Simulator,name=iPhone 16'
```

---

## Configuração do Backend Java (Entrega Acadêmica)

1. Inicie o servidor Java localmente ou em um host acessível pelo dispositivo.
2. Abra `App/AppEnvironment.swift` e ajuste `backendBaseURL` para o endereço correto:

```swift
// Simulador (servidor local no Mac)
let backendBaseURL: URL = URL(string: "http://localhost:8080")!

// Dispositivo físico — use o IP do Mac na rede local
let backendBaseURL: URL = URL(string: "http://192.168.1.10:8080")!

// Servidor hospedado
let backendBaseURL: URL = URL(string: "https://meu-servidor.com")!
```

3. Se estiver testando no simulador com servidor local, use `http://localhost:8080` (o simulador compartilha a rede do Mac).
4. Se estiver testando em um **dispositivo físico**, use o IP da máquina na rede local.

> ⚠️ **Atenção ATS (App Transport Security):** para URLs `http://` (não HTTPS), adicione a exceção no `Info.plist`:
>
> ```xml
> <key>NSAppTransportSecurity</key>
> <dict>
>   <key>NSAllowsArbitraryLoads</key>
>   <true/>
> </dict>
> ```

---

## Dependências e como restaurar (Firebase)

O repositório não inclui `Podfile` nem `Package.swift` na raiz. As dependências do Firebase são gerenciadas via **Swift Package Manager** dentro do Xcode.

Passos (SwiftPM):
1. Abra o projeto no Xcode.
2. Menu: **File → Add Packages...**
3. Cole a URL: `https://github.com/firebase/firebase-ios-sdk`
4. Selecione os pacotes necessários: `FirebaseCore`, `FirebaseAuth`, `FirebaseFirestore`.

Se preferir CocoaPods:
1. Crie um `Podfile` com as dependências desejadas (`Firebase/Auth`, `Firebase/Firestore`, etc.).
2. Rode `pod install` e abra o `.xcworkspace`.

---

## Configuração do Firebase

1. Crie um projeto no Firebase Console (https://console.firebase.google.com).
2. Adicione um app iOS ao projeto informando o **Bundle ID** do seu target (verificar em Xcode > Target > General > Bundle Identifier).
3. Baixe o `GoogleService-Info.plist` gerado pelo Firebase.
4. Substitua/adicione o arquivo `GoogleService-Info.plist` em `App/` (ex.: `rdvwodbet/App/GoogleService-Info.plist`). Ao arrastar para o Xcode, selecione "Copy items if needed" e verifique se o arquivo está adicionado ao target do app.

### Serviços a habilitar no Firebase Console
- **Authentication → Sign-in methods**:
  - ✅ **Email/Password** — necessário para login e cadastro (fluxo Firebase)
  - ✅ **Anonymous** — utilizado pelo login de desenvolvimento (`signInAnonymouslyForDev`)
- **Firestore** → criar base de dados (modo de teste para desenvolvimento; ajustar regras para produção).

O app já chama `FirebaseConfigurator.configure()` no `RDVWODBetApp` para inicialização.

> ⚠️ **Observação de segurança:** Não é recomendado commitar `GoogleService-Info.plist` em repositórios públicos. Considere adicionar ao `.gitignore` e distribuir o arquivo via canal seguro.

---

## Dicas de troubleshooting (comuns)

### Backend Java

1. **Erro de rede "Sem conexão com a internet"**
   - Verifique se o servidor Java está rodando e acessível no endereço configurado em `AppEnvironment.backendBaseURL`.
   - Verifique a exceção ATS no `Info.plist` se estiver usando `http://`.

2. **Resposta inválida do servidor / erro de decodificação**
   - Confirme que o backend retorna JSON com os campos `id`, `name`, `phone` (e `uuid`, `active`, `createdAt` opcionais) nas rotas de login e confirmação.

3. **Código de confirmação sempre retorna 404**
   - O backend pode não ter código gerado para esse telefone + uuid. Tente refazer o fluxo desde o início com o mesmo número.

### Firebase

4. **Crash em `FirebaseApp.configure()`**
   - Verifique se o `GoogleService-Info.plist` está presente no bundle e se o Bundle ID confere com o app registrado no Firebase.

5. **Erro "insufficient permissions" ao acessar Firestore**
   - Ajuste as regras do Firestore para debug (modo de teste) e depois crie regras apropriadas para produção.

6. **Login Firebase retornando erro de autenticação**
   - Verifique se o provedor **Email/Password** está habilitado no Firebase Console em Authentication → Sign-in methods.

7. **Dependências não encontradas**
   - Adicione o SDK do Firebase via SwiftPM ou restaure pods se estiver usando CocoaPods.

---

## Arquivos notáveis para configuração e desenvolvimento

- `App/`:
  - `RDVWODBetApp.swift` — Entrypoint do app
  - `AppDIContainer.swift` — Montagem das dependências (backend ativo + Firebase comentado/preservado)
  - `AppEnvironment.swift` — Configurações por ambiente (`backendBaseURL`, `appName`)
  - `FirebaseConfigurator.swift` — Inicialização do Firebase
  - `GoogleService-Info.plist` — Configuração do Firebase (substituir pelo seu)
- `Data/Backend/` — ⚠️ *Novo*:
  - `PhoneAuthRemoteDataSource.swift` — HTTP via `URLSession` + Combine; rotas `POST /users/login`, `POST /users/confirm`, `PUT /users/{id}`; define enum `PhoneLoginRawResult`
  - `BackendUserRemoteDataSource.swift` — HTTP de usuários (`GET /users`, `GET /users/{id}`, `PUT /users/{id}`)
  - `BackendParticipantRemoteDataSource.swift` — HTTP de participantes (`GET`, `POST`, `PATCH`)
  - `BackendBetRemoteDataSource.swift` — HTTP de apostas (`GET /bets`, criação, voto, confirmação, disputa, cancelamento, resultado)
  - `BackendAPIClient.swift` — cliente HTTP compartilhado e decode de coleções (`array`, `items`, `content`, `data`, `results`)
- `Data/Session/` — ⚠️ *Novo*:
  - `SessionManager.swift` — Sessão local via `UserDefaults`; métodos `save(user:)`, `save(authSession:)`, `updateDisplayName(_:)`, `clear()`
- `Data/DTOs/` — *Novos*:
  - `BackendUserDTO.swift` — Resposta JSON do backend (id, name, phone, uuid, active, createdAt)
  - `ParticipantBackendDTO.swift` — DTO de participantes no backend Java
  - `BetBackendDTO.swift` — DTO de apostas com decode tolerante (string/número, campos opcionais, `athleteA`/`athleteB` objeto)
  - `PhoneLoginRequestDTO.swift` — Body do `POST /users/login`
  - `PhoneConfirmRequestDTO.swift` — Body do `POST /users/confirm`
  - `UpdateUserProfileRequestDTO.swift` — Body do `PUT /users/{id}`
- `Data/Mappers/` — *Novo*:
  - `BackendUserMapper.swift` — Converte `BackendUserDTO` → `AppUser`
  - `ParticipantBackendMapper.swift` — Converte `ParticipantBackendDTO` → `Participant`
  - `BetBackendMapper.swift` — Converte `BetBackendDTO` → `Bet` com fallbacks seguros
- `Data/Repositories/` — *Novo*:
  - `PhoneAuthRepository.swift` — Implementa `PhoneAuthRepositoryProtocol`; mapeia DTOs para entidades de domínio
  - `BackendUserRepository.swift`, `BackendParticipantRepository.swift`, `BackendBetRepository.swift` — repositórios REST para o fluxo ativo
- `Data/Firebase/` — *Preservados*:
  - `FirebaseAuthDataSource.swift` — signIn, signUp, sendPasswordReset, observeAuthState, signOut
  - `FirestoreUserDataSource.swift`
  - `FirestoreBetDataSource.swift`
- `Domain/Protocols/` — *Novo*:
  - `PhoneAuthRepositoryProtocol.swift` — contratos `loginWithPhone`, `confirmPhone`, `updateUserProfile`; enum `PhoneLoginResult`
- `Domain/UseCases/` — *Novos*:
  - `LoginWithPhoneUseCase.swift`
  - `ConfirmPhoneLoginUseCase.swift`
  - `UpdateUserProfileUseCase.swift`
  - `UpdateBetResultUseCase.swift` — atualização de resultado da aposta no backend
- `Presentation/PhoneAuth/` — ⚠️ *Novo*:
  - `PhoneAuthView.swift` — Tela com etapas de telefone e código de confirmação
  - `PhoneAuthViewModel.swift` — Estados `.enterPhone` / `.enterCode`; usa `UIDevice.identifierForVendor`
  - `BackendDisplayNameOnboardingView.swift` — Onboarding de apelido para o fluxo backend
  - `BackendDisplayNameOnboardingViewModel.swift` — Salva nome via `UpdateUserProfileUseCase` + `SessionManager`
- `Presentation/Auth/` — *Preservados (não exibidos nesta entrega)*:
  - `AuthView.swift`, `AuthViewModel.swift`, `RegisterView.swift`, `RegisterViewModel.swift`
  - `DisplayNameOnboardingView.swift`, `DisplayNameOnboardingViewModel.swift`
- `Presentation/Root/RootView.swift` — Fluxo backend ativo (`SessionManager`); fluxo Firebase comentado
- `Presentation/Feed/FeedView.swift` — Logout via `container.sessionManager.clear()`
- `Shared/Utils/Validators.swift` — Validações centrais do domínio
- `Shared/UIComponents/AuthFieldStyle.swift` — Modifier de campo de texto + `ForgotPasswordSheet`

---

## Objetivo Acadêmico

Este projeto foi desenvolvido como **trabalho acadêmico de pós-graduação**, demonstrando:

- Clean Architecture
- MVVM
- Dependency Injection
- Design Patterns
- Protocol-Oriented Programming
- Firebase Integration (preservado)
- Integração com API REST (backend Java — Login por Telefone)
- SwiftUI moderno
- Gestão de sessão local com `UserDefaults`

---

## Autor

**Ricardo Vecchio**

---

## Assunções

1. Dependências do Firebase são gerenciadas via Swift Package Manager dentro do Xcode (não foi encontrado `Podfile` nem `Package.swift`).
2. O `GoogleService-Info.plist` presente no repositório pode ser um placeholder — substituir pelo seu arquivo do Firebase.
3. O Bundle ID do target precisa bater com o app registrado no Firebase.
4. O provedor **Email/Password** deve estar habilitado no Firebase Console para que login e cadastro (fluxo Firebase) funcionem após restauração.
5. O provedor **Anonymous** deve estar habilitado para uso do `signInAnonymouslyForDev()` em desenvolvimento (fluxo Firebase).
6. O usuário que vai compilar o projeto tem Xcode (15+) instalado.
7. Para a entrega acadêmica (Login por Telefone), o backend Java deve estar acessível no endereço configurado em `AppEnvironment.backendBaseURL`.
8. O backend Java deve responder com JSON contendo ao menos os campos `id`, `name` e `phone` nas rotas `/users/login` (HTTP 200) e `/users/confirm` (HTTP 200).

---
