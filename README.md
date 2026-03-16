# 📱 RDV WODBet -- App Mobile iOS (SwiftUI)

O **RDV WODBet** é um aplicativo mobile iOS desenvolvido em **SwiftUI**,
focado em **apostas divertidas entre amigos de um box de CrossFit**.

A ideia central do aplicativo é permitir que atletas do mesmo box criem
**apostas amistosas baseadas no WOD (Workout of the Day)**.

Qualquer usuário autenticado pode: - Criar apostas entre dois atletas -
Definir um prêmio simbólico - Acompanhar apostas no feed público -
Confirmar o vencedor do desafio

O objetivo é **estimular competição saudável entre amigos**, mantendo
tudo organizado dentro do aplicativo.

------------------------------------------------------------------------

# 📱 Conceito do Aplicativo

No RDV WODBet:

1️⃣ Um usuário cria uma aposta\
2️⃣ Escolhe **Atleta A vs Atleta B**\
3️⃣ Define o **WOD do dia**\
4️⃣ Define o **prêmio da aposta**

Exemplo de prêmios:

-   Água
-   Gatorade
-   Cerveja
-   Shake
-   Outro (customizado)

Todas as apostas aparecem em um **feed público**.

Status possíveis:

  Status          Significado
  --------------- -------------------------------------
  ⏳ Aberta       A aposta ainda não foi resolvida
  🏆 Finalizada   O vencedor foi confirmado
  ❌ Cancelada    A aposta foi cancelada
  ⚔️ Em disputa   Houve discordância sobre o vencedor

Uma aposta **só é finalizada quando ambos os atletas confirmam o
vencedor**.

------------------------------------------------------------------------

# 🚀 Tecnologias Utilizadas

-   Swift
-   SwiftUI
-   Combine
-   NavigationStack
-   SF Symbols
-   iOS 16+

Backend e infraestrutura:

-   Firebase Core
-   Firebase Authentication
-   Firebase Firestore

Gerenciamento de dependências:

-   Swift Package Manager

------------------------------------------------------------------------

# 🏗 Arquitetura do Projeto

O projeto foi desenvolvido utilizando **Clean Architecture + MVVM**.

A aplicação é dividida em três camadas principais:

Presentation\
Domain\
Data

Essa separação permite:

-   baixo acoplamento
-   maior testabilidade
-   facilidade de manutenção
-   evolução futura do projeto

------------------------------------------------------------------------

# 🧠 Padrão Arquitetural -- MVVM

O padrão **MVVM (Model View ViewModel)** é utilizado para separar
responsabilidades.

  Camada           Responsabilidade
  ---------------- -------------------------------
  View             Interface do usuário
  ViewModel        Lógica da tela
  Model (Domain)   Entidades e regras de negócio

Exemplo de fluxo:

View\
↓\
ViewModel\
↓\
UseCase\
↓\
Repository\
↓\
DataSource\
↓\
Firebase

------------------------------------------------------------------------

# 🧩 Design Patterns Utilizados

O projeto utiliza diversos **Design Patterns clássicos**.

## MVVM

Separação entre UI e lógica.

## Repository Pattern

Abstrai acesso a dados.

Exemplo:

BetRepository\
FirestoreBetRepository

Permite trocar Firebase por outra fonte de dados futuramente.

## Use Case Pattern

Cada regra de negócio é isolada em um **UseCase**.

Exemplos:

ObserveBetsUseCase\
CreateBetUseCase\
ProposeWinnerUseCase\
ConfirmWinnerUseCase\
CancelBetUseCase

Benefícios:

-   lógica isolada
-   código testável
-   responsabilidades claras

## Dependency Injection

O projeto utiliza **injeção de dependência manual** através do
container:

AppDIContainer

Ele centraliza a criação de:

-   DataSources
-   Repositories
-   UseCases

Exemplo:

createBetUseCase = CreateBetUseCase(betRepository: betRepository)

Benefícios:

-   baixo acoplamento
-   fácil substituição de dependências
-   melhor testabilidade

------------------------------------------------------------------------

# 🧭 Estrutura de Navegação

A navegação do app é centralizada no **RootView**.

Fluxo de autenticação:

Usuário deslogado → Tela de login

Usuário logado sem apelido → Onboarding

Usuário logado → Feed

Fluxo completo do app:

Login\
↓\
Onboarding (apelido do box)\
↓\
Feed de apostas\
↓\
Criar aposta\
↓\
Detalhe da aposta

------------------------------------------------------------------------

# 🔐 Autenticação

-   Autenticação via **Firebase Authentication**
-   Estrutura preparada para **Sign in with Apple**
-   Durante desenvolvimento foi utilizado **login anônimo**
-   Cada usuário possui um **apelido único** dentro do box

Campos do usuário:

UID\
DisplayName\
PhotoURL (opcional)

------------------------------------------------------------------------

# 🏠 Feed de Apostas

Tela principal do aplicativo.

Funcionalidades:

-   exibição de apostas em **tempo real**
-   atualização automática via **Firestore snapshot listener**
-   ordenação por data (mais recentes primeiro)

Cada item do feed mostra:

-   atletas envolvidos
-   WOD do dia
-   prêmio
-   status da aposta

Cada card permite acessar o **detalhe da aposta**.

------------------------------------------------------------------------

# ➕ Criar Aposta

Qualquer usuário autenticado pode criar uma aposta.

Campos obrigatórios:

Atleta A\
Atleta B\
WOD do dia\
Tipo de prêmio

Tipos de prêmio disponíveis:

-   Água
-   Gatorade
-   Cerveja
-   Shake
-   Outro

Se o prêmio for **Outro**, uma descrição é obrigatória.

------------------------------------------------------------------------

# 🧠 Regras de Negócio

As regras estão centralizadas no arquivo:

Validators.swift

Validações implementadas:

### Atletas diferentes

Atleta A ≠ Atleta B

### WOD obrigatório

O WOD não pode ser vazio.

### Prêmio "Outro"

Se selecionado:

Descrição obrigatória

### Apelido do usuário

Regras:

mínimo de 2 caracteres

------------------------------------------------------------------------

# 🏆 Confirmação de Resultado

O fluxo de confirmação segue estas etapas:

1️⃣ Um vencedor é proposto\
2️⃣ Ambos os atletas precisam confirmar\
3️⃣ Se ambos confirmarem → aposta finalizada

Caso haja discordância:

status = disputed

------------------------------------------------------------------------

# 🧪 Testes Unitários

O projeto inclui testes unitários focados na camada de domínio.

Exemplos de cenários testados:

Validators.validateCreateBet

-   Falha quando atletas são iguais
-   Falha quando WOD está vazio
-   Falha quando prêmio "Outro" não possui descrição

Validators.validateDisplayName

-   Falha quando nome possui menos de 2 caracteres

CreateBetUseCase

-   Criação de aposta com status inicial "open"

Esses testes garantem:

-   integridade das regras de negócio
-   previsibilidade do comportamento
-   facilidade de manutenção

------------------------------------------------------------------------

# 🗂 Estrutura Geral do Projeto

Cada camada possui responsabilidades bem definidas para garantir
organização e escalabilidade.

```
rdvwodbet/
├─ App/
│  ├─ RDVWODBetApp.swift
│  ├─ AppDIContainer.swift
│  ├─ AppEnvironment.swift
│  └─ FirebaseConfigurator.swift
│
├─ Presentation/
│  ├─ Auth/
│  │  ├─ AuthView.swift
│  │  ├─ AuthViewModel.swift
│  │  ├─ DisplayNameOnboardingView.swift
│  │  └─ DisplayNameOnboardingViewModel.swift
│  │
│  ├─ Feed/
│  │  ├─ FeedView.swift
│  │  ├─ FeedViewModel.swift
│  │  └─ BetCardView.swift
│  │
│  ├─ CreateBet/
│  │  ├─ CreateBetView.swift
│  │  └─ CreateBetViewModel.swift
│  │
│  ├─ BetDetail/
│  │  ├─ BetDetailView.swift
│  │  └─ BetDetailViewModel.swift
│  │
│  └─ Root/
│     └─ RootView.swift
│
├─ Domain/
│  ├─ Entities/
│  │  ├─ AppUser.swift
│  │  ├─ Bet.swift
│  │  ├─ PrizeType.swift
│  │  └─ BetStatus.swift
│  │
│  ├─ Protocols/
│  │  ├─ AuthRepository.swift
│  │  ├─ UserRepository.swift
│  │  └─ BetRepository.swift
│  │
│  └─ UseCases/
│     ├─ ObserveBetsUseCase.swift
│     ├─ CreateBetUseCase.swift
│     ├─ ProposeWinnerUseCase.swift
│     ├─ ConfirmWinnerUseCase.swift
│     ├─ RejectWinnerUseCase.swift
│     ├─ CancelBetUseCase.swift
│     └─ ObserveAuthStateUseCase.swift
│
├─ Data/
│  ├─ DTOs/
│  │  ├─ AppUserDTO.swift
│  │  └─ BetDTO.swift
│  │
│  ├─ Mappers/
│  │  ├─ AppUserMapper.swift
│  │  └─ BetMapper.swift
│  │
│  ├─ Repositories/
│  │  ├─ FirebaseAuthRepository.swift
│  │  ├─ FirestoreUserRepository.swift
│  │  └─ FirestoreBetRepository.swift
│  │
│  └─ Firebase/
│     ├─ FirebaseAuthDataSource.swift
│     ├─ FirestoreUserDataSource.swift
│     └─ FirestoreBetDataSource.swift
│
└─ Shared/
   ├─ UIComponents/
   │  ├─ PrimaryButton.swift
   │  └─ LoadingView.swift
   │
   ├─ Utils/
   │  ├─ AppError.swift
   │  ├─ Logger.swift
   │  └─ Validators.swift
   │
   └─ Extensions/
      └─ Date+Format.swift
      
rdvwodbetTests/
├─ Support/
│  └─ BetRepositorySpy.swift
│
├─ UseCases/
│  ├─ CancelBetUseCaseTests.swift
│  ├─ ConfirmWinnerUseCaseTests.swift
│  └─ CreateBetUseCaseTests.swift
│   
└─ Validators/
   ├─ ValidatorsCreateBetTests.swift
   └─ ValidatorsDisplayNameTests.swift
```

---

## 📋 Análise de Requisitos do Projeto

### ✅ Requisitos Atendidos

#### 1. Feed público em tempo real
- Implementado com **Firestore**
- Atualizações automáticas via **snapshot listener**

#### 2. Criação e validação de apostas
- Validações centralizadas
- **UseCases** isolando regras de negócio

#### 3. Confirmação dupla de resultado
- Evita fraudes
- Estados bem definidos:
  - `open`
  - `finished`
  - `disputed`
  - `canceled`

#### 4. Arquitetura limpa e escalável
- Separação clara entre **Presentation**, **Domain** e **Data**
- Fácil evolução para rankings, conquistas e histórico

---

## 🔧 Build / Execução

1. Abra o projeto no **Xcode 15+**
2. Adicione o arquivo `GoogleService-Info.plist` ao target do app
3. Instale o Firebase via **Swift Package Manager**
4. Execute em simulador ou dispositivo **iOS 16+**

---

## 🎯 Próximos Passos

- Finalizar **Sign in with Apple**
- Implementar transações Firestore para confirmação de vencedor
- Ranking de atletas
- Sistema de conquistas (*achievements*)
- Inventário de prêmios pendentes
- Notificações push
- Testes unitários e testes de UI

---

## 👨‍💻 Projeto focado em boas práticas

O **RDV WODBet** foi desenvolvido com foco em **organização, clareza e escalabilidade**, servindo como base real para evolução contínua e também como **projeto de portfólio profissional** em iOS com **SwiftUI**.



------------------------------------------------------------------------

# 🔧 Build / Execução

1.  Abrir o projeto no **Xcode 15+**
2.  Adicionar o arquivo `GoogleService-Info.plist`
3.  Instalar Firebase via **Swift Package Manager**
4.  Executar em simulador ou dispositivo **iOS 16+**

------------------------------------------------------------------------

# 🧪 Executar Testes

No Xcode:

Product → Test

ou

CMD + U

------------------------------------------------------------------------

# 🚧 Limitações da Fase Atual

O projeto representa a **Fase 1 do aplicativo**.

Limitações atuais:

-   Sign in with Apple ainda não implementado
-   não há ranking de atletas
-   não há histórico de apostas
-   não há notificações push

------------------------------------------------------------------------

# 🚀 Próximos Passos

Planejamento futuro:

-   Sign in with Apple
-   Ranking de atletas
-   Histórico de apostas
-   Sistema de conquistas
-   Notificações push
-   Inventário de prêmios pendentes
-   Estatísticas de performance

------------------------------------------------------------------------

# 🎯 Objetivo Acadêmico

Este projeto foi desenvolvido como **trabalho acadêmico de
pós-graduação**, demonstrando:

-   Clean Architecture
-   MVVM
-   Dependency Injection
-   Design Patterns
-   Firebase Integration
-   SwiftUI moderno

Além do contexto acadêmico, o projeto também serve como base para
evolução em um **produto real para comunidades de CrossFit**.

------------------------------------------------------------------------

# 👨‍💻 Autor

Ricardo Vecchio

Projeto acadêmico voltado para estudo de:

-   Arquitetura iOS
-   SwiftUI
-   Firebase
-   Engenharia de Software

