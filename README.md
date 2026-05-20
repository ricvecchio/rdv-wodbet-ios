# 📱 RDV WODBet – App Mobile iOS (SwiftUI)

O **RDV WODBet** é um aplicativo mobile iOS desenvolvido em **SwiftUI**, focado em **apostas divertidas entre amigos do box de CrossFit**.  
Qualquer usuário autenticado pode criar uma aposta entre dois atletas com base no **WOD do dia** e definir um **prêmio simbólico** (água, gatorade, cerveja, shake ou "outro").

Todas as apostas ficam visíveis em um **feed público**, com status **Aberta**, **Finalizada**, **Cancelada**, **Em disputa** ou **Expirada**.  
O resultado só é validado quando **ambos os atletas confirmam o vencedor**, garantindo fair play e mantendo a brincadeira organizada.

---

## Conceito do Aplicativo

No **RDV WODBet**:

1. Um usuário se cadastra ou faz login com e-mail e senha
2. Cria uma aposta escolhendo **Atleta A vs Atleta B**
3. Define o **WOD do dia**
4. Define o **prêmio da aposta**

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
- iOS 16+

### Backend e infraestrutura
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
  - `AppDIContainer.swift` — Contêiner simples de dependências (repositórios, use cases, viewmodels).
  - `AppEnvironment.swift` — Variáveis de ambiente / flags centralizadas.
  - `FirebaseConfigurator.swift` — Inicialização do Firebase (`FirebaseApp.configure()`).
- `Data/` — Implementações de acesso a dados
  - `Firebase/` — Data sources (`FirebaseAuthDataSource.swift`, `FirestoreUserDataSource.swift`, `FirestoreBetDataSource.swift`).
  - `Repositories/` — Implementações de repositórios que adaptam os data sources para os protocolos de domínio.
  - `DTOs/`, `Mappers/` — DTOs e conversores para domínio/Firestore.
- `Domain/` — Entidades, protocolos e use cases
  - `Entities/` — `AppUser`, `Bet`, `BetStatus`, `PrizeType`.
  - `Protocols/` — `AuthRepository`, `UserRepository`, `BetRepository`.
  - `UseCases/` — Casos de uso (`CreateBetUseCase`, `ObserveBetsUseCase`, `CancelBetUseCase`, `ProposeWinnerUseCase`, `ConfirmWinnerUseCase`, `RejectWinnerUseCase`, `UpdateBetResultUseCase`, `VoteOnBetUseCase`, `ObserveAuthStateUseCase`).
- `Presentation/` — Views e ViewModels (SwiftUI)
  - `Auth/` — `AuthView`, `AuthViewModel`, `RegisterView`, `RegisterViewModel`, `DisplayNameOnboardingView`, `DisplayNameOnboardingViewModel`.
  - `Feed/`, `CreateBet/`, `BetDetail/`, `Root/` — telas e lógica UI.
- `Shared/` — Componentes, tema, utilitários (`Theme/`, `UIComponents/`, `Utils/`).
- `Resources/` — Assets e imagens (`Assets.xcassets`).

### Fluxo arquitetural

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

O projeto usa boas práticas para manter baixo acoplamento e alta testabilidade.

---

## Estrutura de Navegação

A navegação do aplicativo é centralizada no `RootView`.

### Fluxo de autenticação
- Usuário deslogado → tela de **Login**
- Usuário logado sem apelido → **Onboarding** (apelido do box)
- Usuário logado com perfil completo → **Feed**

### Fluxo funcional do app
```text
Login
├─ Esqueceu a senha? → Sheet de recuperação por e-mail
└─ Cadastro
       ↓
(Onboarding de apelido — somente se o perfil ainda não existir)
       ↓
Feed de apostas
       ↓
Criar aposta
       ↓
Detalhe da aposta
```

---

## Autenticação

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

### Campos do usuário (`AppUser`)
- `uid`
- `displayName` (apelido/nome)
- `photoURL` (opcional)
- `createdAt`

---

## Onboarding de Apelido (`DisplayNameOnboardingView`)

Exibido somente quando o usuário está autenticado mas ainda não tem perfil criado no Firestore (ex: login anônimo pela primeira vez).

- Campo de apelido (mín. 2 caracteres, validado por `Validators.validateDisplayName`)
- Botão **Continuar** — salva no Firestore e redireciona ao feed

---

## Feed de Apostas

Tela principal do aplicativo.

### Funcionalidades
- Exibição de apostas em **tempo real** via Firestore snapshot listener
- Atualização automática sem necessidade de refresh manual
- Ordenação por data (mais recentes primeiro)
- Estado vazio com CTA para criar a primeira aposta

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
| Nome do cadastro mínimo 2 chars | `RegisterViewModel.signUp()` |
| Senha mínimo 6 caracteres | `RegisterViewModel.signUp()` |
| E-mail e senha obrigatórios no login | `AuthViewModel.signInWithEmail()` |

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

## Dependências e como restaurar

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
  - ✅ **Email/Password** — necessário para login e cadastro
  - ✅ **Anonymous** — utilizado pelo login de desenvolvimento (`signInAnonymouslyForDev`)
- **Firestore** → criar base de dados (modo de teste para desenvolvimento; ajustar regras para produção).

O app já chama `FirebaseConfigurator.configure()` no `RDVWODBetApp` para inicialização.

> ⚠️ **Observação de segurança:** Não é recomendado commitar `GoogleService-Info.plist` em repositórios públicos. Considere adicionar ao `.gitignore` e distribuir o arquivo via canal seguro.

---

## Dicas de troubleshooting (comuns)

1. **Crash em `FirebaseApp.configure()`**
   - Verifique se o `GoogleService-Info.plist` está presente no bundle e se o Bundle ID confere com o app registrado no Firebase.

2. **Erro "insufficient permissions" ao acessar Firestore**
   - Ajuste as regras do Firestore para debug (modo de teste) e depois crie regras apropriadas para produção.

3. **Login retornando erro de autenticação**
   - Verifique se o provedor **Email/Password** está habilitado no Firebase Console em Authentication → Sign-in methods.

4. **Autenticação retornando nil**
   - Verifique se o provedor (Anonymous, Email/Password) está habilitado no Firebase e se o listener de auth está correto.

5. **Dependências não encontradas**
   - Adicione o SDK do Firebase via SwiftPM ou restaure pods se estiver usando CocoaPods.

---

## Arquivos notáveis para configuração e desenvolvimento

- `App/`:
  - `RDVWODBetApp.swift` — Entrypoint do app
  - `AppDIContainer.swift` — Montagem das dependências
  - `AppEnvironment.swift` — Configurações por ambiente (dev/prod)
  - `FirebaseConfigurator.swift` — Inicialização do Firebase
  - `GoogleService-Info.plist` — Configuração do Firebase (substituir pelo seu)
- `Data/Firebase/`:
  - `FirebaseAuthDataSource.swift` — signIn, signUp, sendPasswordReset, observeAuthState, signOut
  - `FirestoreUserDataSource.swift`
  - `FirestoreBetDataSource.swift`
- `Data/Repositories/`:
  - `FirebaseAuthRepository.swift`
  - `FirestoreUserRepository.swift`
  - `FirestoreBetRepository.swift`
- `Domain/Protocols/`:
  - `AuthRepository.swift` — `observeAuthState`, `signIn`, `signUp`, `sendPasswordReset`, `signInWithApple`, `signOut`, `currentUID`
- `Presentation/Auth/`:
  - `AuthView.swift` — Tela de login (e-mail, senha, esqueceu a senha, link cadastro)
  - `AuthViewModel.swift` — Estado de autenticação, login por e-mail, recuperação de senha
  - `RegisterView.swift` — Tela de cadastro (nome, e-mail, senha)
  - `RegisterViewModel.swift` — Criação de conta + perfil no Firestore
  - `DisplayNameOnboardingView.swift` — Onboarding de apelido para login anônimo/sem perfil
- `Shared/Utils/Validators.swift` — Validações centrais do domínio
- `Shared/UIComponents/AuthFieldStyle.swift` — Modifier de campo de texto + `ForgotPasswordSheet`

---

## Objetivo Acadêmico

Este projeto foi desenvolvido como **trabalho acadêmico de pós-graduação**, demonstrando:

- Clean Architecture
- MVVM
- Dependency Injection
- Design Patterns
- Firebase Integration
- SwiftUI moderno

---

## Autor

**Ricardo Vecchio**

---

## Assunções

1. Dependências do Firebase são gerenciadas via Swift Package Manager dentro do Xcode (não foi encontrado `Podfile` nem `Package.swift`).
2. O `GoogleService-Info.plist` presente no repositório pode ser um placeholder — substituir pelo seu arquivo do Firebase.
3. O Bundle ID do target precisa bater com o app registrado no Firebase.
4. O provedor **Email/Password** deve estar habilitado no Firebase Console para que login e cadastro funcionem.
5. O provedor **Anonymous** deve estar habilitado para uso do `signInAnonymouslyForDev()` em desenvolvimento.
6. O usuário que vai compilar o projeto tem Xcode (15+) instalado.

---
