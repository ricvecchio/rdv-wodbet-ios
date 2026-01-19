# 📱 RDV WODBet – App Mobile iOS (SwiftUI)

O **RDV WODBet** é um aplicativo mobile iOS desenvolvido em **SwiftUI**, focado em **apostas divertidas entre amigos do box de CrossFit**.  
Qualquer usuário autenticado pode criar apostas entre dois atletas com base no **WOD do dia**, definindo um **prêmio simbólico** (água, gatorade, cerveja, shake ou “outro”).

Todas as apostas ficam visíveis em um **feed público**, com status **⏳ Aberta**, **🏆 Finalizada**, **❌ Cancelada** ou **⚔️ Em disputa**.  
O resultado só é validado quando **ambos os atletas confirmam o vencedor**, garantindo fair play e evitando conflitos.

---

## 🚀 Tecnologias Utilizadas

- Swift
- SwiftUI
- NavigationStack
- Combine
- SF Symbols
- iOS 16+
- Firebase
  - Firebase Core
  - Firebase Authentication (preparado)
  - Firestore (Realtime Database)

Arquitetura:
- MVVM
- Clean Architecture (UseCases + Repositories)
- Injeção de dependência via `AppDIContainer`

---

## 🧭 Estrutura de Navegação

A navegação do app é centralizada no **`RootView`**, que reage ao estado de autenticação do usuário:

- Usuário não autenticado → Login
- Usuário autenticado sem apelido → Onboarding
- Usuário autenticado → Feed de apostas

A navegação é feita com `NavigationStack`, sem router customizado, priorizando simplicidade e previsibilidade.

### Fluxo principal
- Login
- Onboarding (apelido do box)
- Feed de Apostas
- Criar Aposta
- Detalhe da Aposta

---

## 🔐 Autenticação

- Autenticação via **Firebase Authentication**
- Estrutura preparada para **Sign in with Apple**
- Durante desenvolvimento, login mockado para facilitar testes
- Cada usuário possui um **apelido único** usado no contexto do box

---

## 🏠 Feed de Apostas

Tela principal do app.

Funcionalidades:
- Exibição de todas as apostas em tempo real (Firestore)
- Ordenação por data (mais recentes primeiro)
- Visualização clara de:
  - Atletas envolvidos
  - WOD do dia
  - Prêmio
  - Status da aposta

Cada item do feed dá acesso ao **detalhe da aposta**.

---

## ➕ Criar Aposta

Qualquer usuário autenticado pode criar uma aposta.

Campos:
- Atleta A
- Atleta B
- WOD do dia
- Tipo de prêmio:
  - Água
  - Gatorade
  - Cerveja
  - Shake
  - Outro (com descrição obrigatória)

Validações:
- Atleta A ≠ Atleta B
- WOD obrigatório
- Descrição obrigatória quando o prêmio for “Outro”

---

## 🏆 Confirmação de Resultado

A confirmação do resultado segue regras claras:

- Apenas os atletas envolvidos podem confirmar
- Um vencedor é **proposto**
- Ambos os atletas precisam confirmar
- Se houver discordância:
  - A aposta entra em status **⚔️ Em disputa**
- A aposta só é finalizada quando há **dupla confirmação**

---

## 🧩 Componentes Reutilizáveis

Componentes compartilhados no projeto:
- `PrimaryButton` — botão principal reutilizável
- `LoadingView` — estados de carregamento
- Sistema centralizado de erros (`AppError`)
- Validações isoladas (`Validators`)

---

## 🗂 Estrutura Geral do App

```text
RDVWODBet/
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


