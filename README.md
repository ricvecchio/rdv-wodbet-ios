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
- Swift Package Manager

---

## Arquitetura do Projeto

O projeto foi desenvolvido utilizando **Clean Architecture + MVVM**.

A aplicação é dividida em três camadas principais:

- **Presentation**
- **Domain**
- **Data**

Essa separação permite:

- baixo acoplamento
- maior testabilidade
- facilidade de manutenção
- evolução futura do projeto

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

O projeto utiliza padrões clássicos de desenvolvimento para garantir organização, testabilidade e evolução futura.

### MVVM
Separação entre interface e lógica de apresentação.

### Repository Pattern
Abstrai o acesso aos dados.

**Exemplo**
- `BetRepository`
- `FirestoreBetRepository`

Isso permite trocar a implementação do Firebase por outra fonte no futuro sem alterar as regras de negócio.

### Use Case Pattern
Cada regra de negócio fica isolada em um caso de uso específico.

**Exemplos**
- `ObserveBetsUseCase`
- `CreateBetUseCase`
- `ProposeWinnerUseCase`
- `ConfirmWinnerUseCase`
- `RejectWinnerUseCase`
- `CancelBetUseCase`
- `VoteOnBetUseCase`

### Dependency Injection
O projeto utiliza **injeção de dependência manual** por meio do `AppDIContainer`.

O container centraliza a criação de:

- DataSources
- Repositories
- UseCases

**Exemplo**
```swift
lazy var createBetUseCase = CreateBetUseCase(betRepository: betRepository)
```

Benefícios:

- baixo acoplamento
- fácil substituição de dependências
- melhor testabilidade

---

## Estrutura de Navegação

A navegação do aplicativo é centralizada no **RootView**.

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
- Estrutura preparada para **Sign in with Apple**
- Durante o desenvolvimento foi utilizado **login anônimo**
- Cada usuário possui um **apelido único** dentro do box

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
- Outro

Se o prêmio for **Outro**, uma descrição é obrigatória.

---

## Regras de Negócio

As regras estão centralizadas principalmente em `Validators.swift` e nos `UseCases`.

### Validações implementadas
- **Atletas diferentes**  
  Atleta A ≠ Atleta B

- **WOD obrigatório**  
  O WOD não pode ser vazio

- **Prêmio "Outro"**  
  Se selecionado, a descrição é obrigatória

- **Apelido do usuário**  
  Deve ter pelo menos 2 caracteres

---

## Confirmação de Resultado

O fluxo de confirmação segue estas etapas:

1. Um vencedor é proposto  
2. Ambos os atletas precisam confirmar  
3. Se ambos confirmarem → a aposta é finalizada  

Caso haja discordância:

- status = `disputed`

---

## Testes Unitários

O projeto inclui testes unitários focados principalmente na camada de domínio.

### Arquivos de teste
- `CancelBetUseCaseTests.swift`
- `ConfirmWinnerUseCaseTests.swift`
- `CreateBetUseCaseTests.swift`
- `ValidatorsCreateBetTests.swift`
- `ValidatorsDisplayNameTests.swift`

### Exemplos de cenários testados
- falha quando os atletas são iguais
- falha quando o WOD está vazio
- falha quando o prêmio **Outro** não possui descrição
- falha quando o apelido tem menos de 2 caracteres
- criação de aposta com status inicial `open`

Esses testes ajudam a garantir:

- integridade das regras de negócio
- previsibilidade do comportamento
- facilidade de manutenção

---

## Estrutura Geral do Projeto

```text
rdvwodbet/
├─ App/
│  ├─ RDVWODBetApp.swift
│  ├─ AppDIContainer.swift
│  ├─ AppEnvironment.swift
│  └─ FirebaseConfigurator.swift
├─ Presentation/
│  ├─ Auth/
│  │  ├─ AuthView.swift
│  │  ├─ AuthViewModel.swift
│  │  ├─ DisplayNameOnboardingView.swift
│  │  └─ DisplayNameOnboardingViewModel.swift
│  ├─ Feed/
│  │  ├─ FeedView.swift
│  │  ├─ FeedViewModel.swift
│  │  └─ BetCardView.swift
│  ├─ CreateBet/
│  │  ├─ CreateBetView.swift
│  │  └─ CreateBetViewModel.swift
│  ├─ BetDetail/
│  │  ├─ BetDetailView.swift
│  │  └─ BetDetailViewModel.swift
│  └─ Root/
│     └─ RootView.swift
├─ Domain/
│  ├─ Entities/
│  │  ├─ AppUser.swift
│  │  ├─ Bet.swift
│  │  ├─ PrizeType.swift
│  │  └─ BetStatus.swift
│  ├─ Protocols/
│  │  ├─ AuthRepository.swift
│  │  ├─ UserRepository.swift
│  │  └─ BetRepository.swift
│  └─ UseCases/
│     ├─ ObserveBetsUseCase.swift
│     ├─ CreateBetUseCase.swift
│     ├─ ProposeWinnerUseCase.swift
│     ├─ ConfirmWinnerUseCase.swift
│     ├─ RejectWinnerUseCase.swift
│     ├─ CancelBetUseCase.swift
│     ├─ VoteOnBetUseCase.swift
│     └─ ObserveAuthStateUseCase.swift
├─ Data/
│  ├─ DTOs/
│  │  ├─ AppUserDTO.swift
│  │  └─ BetDTO.swift
│  ├─ Mappers/
│  │  ├─ AppUserMapper.swift
│  │  └─ BetMapper.swift
│  ├─ Repositories/
│  │  ├─ FirebaseAuthRepository.swift
│  │  ├─ FirestoreUserRepository.swift
│  │  └─ FirestoreBetRepository.swift
│  └─ Firebase/
│     ├─ FirebaseAuthDataSource.swift
│     ├─ FirestoreUserDataSource.swift
│     └─ FirestoreBetDataSource.swift
├─ Shared/
│  ├─ UIComponents/
│  │  ├─ PrimaryButton.swift
│  │  └─ LoadingView.swift
│  ├─ Utils/
│  │  ├─ AppError.swift
│  │  ├─ Logger.swift
│  │  └─ Validators.swift
│  └─ Extensions/
│     └─ Date+Format.swift

rdvwodbetTests/
├─ Support/
│  └─ BetRepositorySpy.swift
├─ UseCases/
│  ├─ CancelBetUseCaseTests.swift
│  ├─ ConfirmWinnerUseCaseTests.swift
│  └─ CreateBetUseCaseTests.swift
└─ Validators/
   ├─ ValidatorsCreateBetTests.swift
   └─ ValidatorsDisplayNameTests.swift
```

---

## Atendimento aos Requisitos Acadêmicos

### 1. Clean Code
O projeto foi organizado com foco em legibilidade e manutenção:

- separação por camadas
- responsabilidades bem definidas
- nomenclatura clara de arquivos e classes
- regras de negócio fora da interface
- validações centralizadas

### 2. Arquitetura de Software
Foi adotada uma arquitetura baseada em:

- **Clean Architecture**
- **MVVM**

A interface fica desacoplada das regras de negócio e do acesso aos dados.

### 3. Injeção de Dependência
A injeção de dependência é feita manualmente no `AppDIContainer`, responsável por instanciar e conectar:

- DataSources
- Repositories
- UseCases
- ViewModels

### 4. Testes Unitários
O projeto possui **pelo menos 5 testes unitários**, cobrindo principalmente regras de domínio e validações.

### 5. Design Patterns
Padrões aplicados:

- MVVM
- Repository
- Use Case
- Dependency Injection

### 6. Interface com pelo menos 3 telas funcionais
O aplicativo possui, no mínimo, as seguintes telas funcionais:

- Login
- Onboarding
- Feed de apostas
- Criar aposta
- Detalhe da aposta

---

## Roteiro Sugerido para Apresentação em Vídeo (até 15 minutos)

### 1. Introdução do projeto (1–2 min)
Explique o problema resolvido pelo app e o contexto do CrossFit.

### 2. Demonstração funcional (3–4 min)
Mostre:
- login
- onboarding
- feed
- criação de aposta
- detalhe da aposta

### 3. Arquitetura e organização do código (3 min)
Mostre as camadas:
- Presentation
- Domain
- Data

Explique rapidamente o fluxo:
View → ViewModel → UseCase → Repository → DataSource

### 4. Dependency Injection e padrões (2 min)
Abra `AppDIContainer.swift` e explique como as dependências são montadas.

### 5. Regras de negócio (2 min)
Mostre `Validators.swift` e `CreateBetUseCase.swift`.

### 6. Testes unitários (2 min)
Mostre a pasta `rdvwodbetTests` e comente os cenários cobertos.

### 7. Encerramento (1 min)
Conclua reforçando que o projeto atende aos requisitos acadêmicos e está preparado para evolução futura.

---

## Build / Execução

1. Abra o projeto no **Xcode 15+**
2. Adicione o arquivo `GoogleService-Info.plist` ao target do app
3. Instale o Firebase via **Swift Package Manager**
4. Execute em simulador ou dispositivo **iOS 16+**

---

## Executar Testes

No Xcode:

- **Product → Test**
- ou **⌘ + U**

---

## Limitações da Fase Atual

O projeto representa a **Fase 1** do aplicativo.

### Limitações atuais
- Sign in with Apple ainda não implementado
- não há ranking de atletas
- não há histórico de apostas
- não há notificações push

---

## Próximos Passos

Planejamento futuro:

- Sign in with Apple
- ranking de atletas
- histórico de apostas
- sistema de conquistas
- notificações push
- inventário de prêmios pendentes
- estatísticas de performance

---

## Objetivo Acadêmico

Este projeto foi desenvolvido como **trabalho acadêmico de pós-graduação**, demonstrando:

- Clean Architecture
- MVVM
- Dependency Injection
- Design Patterns
- Firebase Integration
- SwiftUI moderno

Além do contexto acadêmico, o projeto também serve como base para evolução em um **produto real para comunidades de CrossFit**.

---

## Autor

**Ricardo Vecchio**

Projeto acadêmico voltado para estudo de:

- Arquitetura iOS
- SwiftUI
- Firebase
- Engenharia de Software

