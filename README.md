# 📱 RDV WODBet – App Mobile iOS (SwiftUI)

O **RDV WODBet** é um aplicativo mobile iOS desenvolvido em **SwiftUI**, focado em **apostas divertidas entre amigos do box de CrossFit**.  
Qualquer usuário autenticado pode criar uma aposta entre dois atletas com base no **WOD do dia** e definir um **prêmio simbólico** (água, gatorade, cerveja, shake ou “outro”).

Todas as apostas ficam visíveis em um **feed público**, com status **Aberta**, **Finalizada**, **Cancelada** ou **Em disputa**.  
O resultado só é validado quando **ambos os atletas confirmam o vencedor**, garantindo fair play e mantendo a brincadeira organizada.

---

## Conceito do Aplicativo

No **RDV WODBet**:

1. Um usuário cria uma aposta  
2. Escolhe **Atleta A vs Atleta B**  
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
| ✅ Finalizada | O vencedor foi confirmado |
| ❌ Cancelada | A aposta foi cancelada |
| ⚔️ Em disputa | Houve discordância sobre o vencedor |

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
- Firebase Authentication
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
  - `Firebase/` — Data sources (ex.: `FirebaseAuthDataSource.swift`, `FirestoreUserDataSource.swift`, `FirestoreBetDataSource.swift`).
  - `Repositories/` — Implementações de repositórios que adaptam os data sources para os protocolos de domínio.
  - `DTOs/`, `Mappers/` — DTOs e conversores para domínio/Firestore.
- `Domain/` — Entidades, protocolos e use cases
  - `Entities/` — `AppUser`, `Bet`, etc.
  - `Protocols/` — `AuthRepository`, `UserRepository`, `BetRepository`.
  - `UseCases/` — Casos de uso (ex.: `CreateBetUseCase.swift`, `ObserveBetsUseCase.swift`).
- `Presentation/` — Views e ViewModels (SwiftUI)
  - `Auth/` — `AuthView.swift`, `AuthViewModel.swift`.
  - `Feed/`, `CreateBet/`, `BetDetail/`, `Root/` — telas e lógica UI.
- `Shared/` — Componentes, tema, utilitários (ex.: `Theme/`, `UIComponents/`, `Utils/`).
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
- Usuário deslogado → tela de login
- Usuário logado sem apelido → onboarding
- Usuário logado → feed

### Fluxo funcional do app
```text
Login
↓
Onboarding (apelido do box)
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
- Estrutura preparada para **Sign in with Apple** (ainda não implementado por completo)
- Durante o desenvolvimento foi utilizado **login anônimo**
- Cada usuário possui um **displayName** (apelido) único dentro do box

### Campos do usuário
- `uid`
- `displayName`
- `photoURL` (opcional)

---

## Feed de Apostas

Tela principal do aplicativo.

### Funcionalidades
- exibição de apostas em **tempo real**
- atualização automática via **Firestore snapshot listener**
- ordenação por data (mais recentes primeiro)

### Cada item do feed mostra
- atletas envolvidos
- WOD do dia
- prêmio
- status da aposta

Cada card permite acessar o **detalhe da aposta**.

---

## Criar Aposta

Qualquer usuário autenticado pode criar uma aposta.

### Campos obrigatórios
- Atleta A
- Atleta B
- WOD do dia
- Tipo de prêmio

### Tipos de prêmio disponíveis
- Água
- Gatorade
- Cerveja
- Shake
- Outro (com descrição exigida)

---

## Regras de Negócio

As regras estão centralizadas principalmente em `Shared/Utils/Validators.swift` e nos `UseCases`.

### Validações implementadas
- **Atletas diferentes** — Atleta A ≠ Atleta B
- **WOD obrigatório** — O WOD não pode ser vazio
- **Prêmio "Outro"** — Se selecionado, a descrição é obrigatória
- **Apelido do usuário** — Deve ter pelo menos 2 caracteres

---

## Confirmação de Resultado

O fluxo de confirmação segue estas etapas:

1. Um vencedor é proposto  
2. Ambos os atletas precisam confirmar  
3. Se ambos confirmarem → a aposta é finalizada

Caso haja discordância: status = `disputed`.

---

## Testes Unitários

O projeto inclui testes unitários focados principalmente na camada de domínio.

### Arquivos de teste
- `CancelBetUseCaseTests.swift`
- `ConfirmWinnerUseCaseTests.swift`
- `CreateBetUseCaseTests.swift`
- `ValidatorsCreateBetTests.swift`
- `ValidatorsDisplayNameTests.swift`

### Executar testes
- No Xcode: **Product → Test** (⌘U)
- Via linha de comando (xcodebuild):

```bash
xcodebuild test -scheme <SchemeName> -destination 'platform=iOS Simulator,name=iPhone 14'
```

Substitua `<SchemeName>` pelo esquema do seu projeto (verificar no Xcode).

---

## Dependências e como restaurar

O repositório não inclui `Podfile` nem `Package.swift` na raiz. As dependências do Firebase são esperadas via **Swift Package Manager** configuradas dentro do Xcode.

Passos sugeridos (SwiftPM):
1. Abra o projeto no Xcode.
2. Menu: File → Add Packages...
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
4. Substitua/adicione o arquivo `GoogleService-Info.plist` em `App/` (ex.: `rdvwodbet/App/GoogleService-Info.plist`). Ao arrastar para o Xcode, selecione “Copy items if needed” e verifique se o arquivo está adicionado ao target do app.

Observações de segurança:
- Não é recomendado commitar `GoogleService-Info.plist` em repositórios públicos. Considere adicionar ao `.gitignore` e distribuir o arquivo via canal seguro.

Serviços a habilitar no Firebase Console:
- Authentication → habilitar **Anonymous** para desenvolvimento e outros provedores conforme necessário (Apple Sign In).
- Firestore → criar base de dados (modo de teste para desenvolvimento; ajustar regras para produção).

O app já chama `FirebaseConfigurator.configure()` no `RDVWODBetApp` para inicialização.

---

## Dicas de troubleshooting (comuns)

1. Crash em `FirebaseApp.configure()`
   - Verifique se o `GoogleService-Info.plist` está presente no bundle e se o Bundle ID confere com o app registrado no Firebase.
2. Erro: “insufficient permissions” ao acessar Firestore
   - Ajuste as regras do Firestore para debug (modo de teste) e depois crie regras apropriadas para produção.
3. Autenticação retornando nil
   - Verifique se o provedor (Anonymous, Apple) está habilitado no Firebase e se o listener do auth está correto.
4. Dependências não encontradas
   - Adicione o SDK do Firebase via SwiftPM ou restaure pods se estiver usando CocoaPods.

---

## Arquivos notáveis para configuração e desenvolvimento

- `App/`:
  - `RDVWODBetApp.swift` — Entrypoint do app
  - `AppDIContainer.swift` — Montagem das dependências
  - `AppEnvironment.swift` — Configurações por ambiente (dev/prod)
  - `FirebaseConfigurator.swift` — Inicialização do Firebase
  - `GoogleService-Info.plist` — configuração do Firebase (substituir pelo seu)
- `Data/Firebase/`:
  - `FirebaseAuthDataSource.swift`
  - `FirestoreUserDataSource.swift`
  - `FirestoreBetDataSource.swift`
- `Data/Repositories/`:
  - `FirebaseAuthRepository.swift`
  - `FirestoreUserRepository.swift`
  - `FirestoreBetRepository.swift`
- `Presentation/Auth/AuthView.swift` — Tela de login usada para dev com `signInAnonymouslyForDev()`
- `Shared/Utils/Validators.swift` — validações centrais do domínio

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
4. O app usa autenticação anônima para desenvolvimento conforme `Presentation/Auth/AuthView.swift`.
5. O usuário que vai compilar o projeto tem Xcode (15+) instalado.

---
