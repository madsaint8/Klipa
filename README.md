# Klipa

<p align="center">
  <img src="assets/klipa-logo.png" alt="Klipa Logo" width="180"/>
</p>

<h3 align="center">A smarter digital wallet for everyday payments</h3>

<p align="center">
  Secure mobile payments, peer-to-peer transfers, digital wallets and Web3 connectivity.
</p>

---

## Overview

**Klipa** is a South African fintech platform designed to make digital payments and money movement more accessible, convenient and affordable.

The platform combines a **primary fiat wallet** for everyday financial activity with a separate **Web3 wallet** for blockchain-based assets and services.

Klipa is being developed to serve individuals, freelancers, students, small businesses, migrant families and other users who need simple digital payment and money-transfer capabilities without depending entirely on traditional banking infrastructure.

> **Project status:** Active development / pre-production

---

## Core Capabilities

### Digital Wallet

- User registration and authentication
- Personal ZAR wallet
- Wallet balance management
- Peer-to-peer transfers
- Beneficiary and contact payments
- Transaction history
- Payment references
- Account and profile management

### Payments

- Scan-to-Pay
- Merchant payments
- QR-based payment flows
- Wallet-funded payments
- Planned card payments
- EFT and instant funding integrations
- Planned cash funding support

### Web3

- Separate Web3 wallet
- Blockchain wallet address management
- ETH and supported digital assets
- Blockchain network connectivity
- Portfolio and asset valuation
- Secure private-key handling

### Future Capabilities

- Klipa payment cards
- ATM withdrawals
- Online card payments
- Smart stokvels
- Cross-border P2P payments
- Additional blockchain networks
- Financial education tools
- Additional merchant services
- Additional digital financial products

---

## Product Architecture

Klipa follows a modular architecture designed to separate presentation, business logic, data access and external integrations.

```text
┌─────────────────────────────────────────────┐
│                 Klipa App                   │
│                Flutter / Dart               │
├─────────────────────────────────────────────┤
│                 Presentation                 │
│       Screens • Widgets • Navigation         │
├─────────────────────────────────────────────┤
│             Riverpod State Layer             │
│        Providers • Notifiers • State         │
├─────────────────────────────────────────────┤
│              Repository Layer                │
│       Business-facing data operations        │
├─────────────────────────────────────────────┤
│               Service Layer                  │
│ Supabase • Payments • Web3 • External APIs  │
├─────────────────────────────────────────────┤
│                  Backend                    │
│          Supabase + Edge Functions           │
├─────────────────────────────────────────────┤
│              Data & Integrations              │
│ PostgreSQL • Auth • Storage • RPC • APIs    │
└─────────────────────────────────────────────┘
```

---

## Technology Stack

### Mobile Application

- **Flutter**
- **Dart**
- **Material 3**
- **Riverpod**
- Repository/service architecture
- Immutable application models

### Backend

- **Supabase**
- PostgreSQL
- Supabase Authentication
- Supabase Storage
- Row Level Security (RLS)
- PostgreSQL functions / RPC
- Supabase Edge Functions

### Web3

- Ethereum-compatible networks
- `web3dart`
- Secure wallet/key storage
- RPC providers
- Blockchain portfolio services

### Payment Infrastructure

Klipa is being designed to support multiple funding and payment providers rather than relying on a single infrastructure provider.

Planned/active integration areas include:

- EFT funding
- Instant payments
- Card funding
- Merchant payments
- Card issuing and processing
- Payment webhooks
- Transaction reconciliation

---

# Repository Structure

The application follows a feature-first structure.

```text
lib/
├── app/
│   ├── app.dart
│   ├── router/
│   └── theme/
│
├── core/
│   ├── errors/
│   ├── security/
│   ├── storage/
│   ├── network/
│   ├── constants/
│   └── utils/
│
├── features/
│   ├── auth/
│   │   ├── models/
│   │   ├── repositories/
│   │   ├── services/
│   │   ├── providers/
│   │   └── presentation/
│   │
│   ├── profile/
│   │
│   ├── wallet/
│   │
│   ├── transactions/
│   │
│   ├── contacts/
│   │
│   ├── payments/
│   │
│   ├── cards/
│   │
│   ├── funding/
│   │
│   ├── web3/
│   │
│   └── scan_to_pay/
│
└── main.dart

supabase/
├── functions/
│   ├── _shared/
│   │   ├── stitch/
│   │   ├── ledger/
│   │   └── security/
│   │
│   ├── funding-create/
│   ├── funding-status/
│   └── stitch-webhook/
│
├── migrations/
└── config.toml

assets/
├── images/
├── icons/
└── klipa-logo.png
```

---

# Application Architecture

Klipa uses a separation-of-concerns architecture.

```text
UI
 │
 ▼
Provider / Notifier
 │
 ▼
Repository
 │
 ▼
Service
 │
 ├── Supabase
 ├── Payment Provider
 ├── Blockchain RPC
 └── External API
 │
 ▼
Database / External System
```

### Presentation

Widgets and screens are responsible primarily for displaying state and collecting user interaction.

Business logic should not be embedded directly inside UI widgets.

### Providers

Riverpod providers manage:

- Application state
- Dependency injection
- Authentication state
- Wallet state
- Transaction state
- Web3 state
- Loading/error states
- Repository dependencies

### Repositories

Repositories provide a stable interface between application logic and external data sources.

For example:

```text
WalletScreen
    ↓
WalletProvider
    ↓
WalletRepository
    ↓
WalletService
    ↓
Supabase
```

This keeps provider and UI code independent from the underlying API implementation.

---

# Supabase Architecture

Supabase provides the core backend infrastructure.

```text
Flutter Application
        │
        ├── Supabase Auth
        │
        ├── PostgreSQL
        │
        ├── Storage
        │
        └── Edge Functions
                 │
                 ├── Payment Providers
                 ├── Funding Providers
                 └── Blockchain Services
```

Core database domains include:

- Users
- Profiles
- Accounts
- Account members
- Transactions
- Beneficiaries
- Contacts
- Wallet data
- Payment records
- Funding records
- Web3 wallet information

Sensitive operations should be performed through controlled backend services and server-side functions rather than trusting the client application.

---

# Security

Security is a core architectural requirement for Klipa because the platform handles financial information and payment operations.

Security controls include:

- Supabase Row Level Security
- Server-side validation
- Secure authentication
- Secure local storage
- Protected wallet credentials
- Private-key protection
- API key separation
- Environment configuration
- Input validation
- Transaction verification
- Webhook signature validation
- Idempotent payment processing
- Transaction reconciliation
- Principle of least privilege
- Release-build obfuscation
- Secure dependency management

### Important

Secrets must **never be committed to Git**.

Do not place production secrets directly inside Flutter source code.

Use environment-specific configuration and server-side secrets for credentials that must not be exposed to application users.

---

# Environment Configuration

Klipa uses environment-specific configuration.

Example development configuration:

```text
SUPABASE_URL=...
SUPABASE_ANON_KEY=...
```

Additional provider configuration may include:

```text
PAYMENT_PROVIDER_URL=...
PAYMENT_PROVIDER_KEY=...
RPC_URL=...
WEB3_NETWORK=...
```

Production secrets should be stored using appropriate secure infrastructure.

### Git

Sensitive files should be excluded through `.gitignore`.

Example:

```gitignore
.env
.env.*
*.key
*.pem
*.p12
*.jks
google-services.json
GoogleService-Info.plist
```

Do not assume that placing a secret in `.gitignore` makes an already-committed secret safe. If a secret was previously committed, rotate/revoke it.

---

# Local Development

## Prerequisites

Install:

- Flutter SDK
- Dart SDK
- Git
- Android Studio
- Android SDK
- Xcode for iOS development
- Supabase CLI where required

Verify Flutter:

```bash
flutter doctor
```

---

## Clone the Repository

```bash
git clone <repository-url>
cd klipa
```

---

## Install Dependencies

```bash
flutter pub get
```

---

## Configure Environment

Create the required local environment configuration.

Do **not** commit production credentials.

---

## Run the Application

```bash
flutter run
```

For a connected Android device:

```bash
flutter devices
flutter run -d <device-id>
```

---

# Supabase Development

Ensure the required Supabase project configuration is available before running backend-dependent features.

Database migrations should be version controlled.

Recommended workflow:

```text
Local Development
       │
       ▼
Database Migration
       │
       ▼
Testing
       │
       ▼
Staging
       │
       ▼
Production
```

Production database changes should not be made manually where a migration can be used instead.

---

# Edge Functions

Backend-only operations belong in:

```text
supabase/functions/
```

Shared backend modules should be placed under:

```text
supabase/functions/_shared/
```

For example:

```text
supabase/functions/
└── _shared/
    ├── stitch/
    │   ├── stitch_client.ts
    │   ├── stitch_config.ts
    │   └── stitch_types.ts
    │
    └── ledger/
        └── account_ledger_service.ts
```

Payment webhooks should validate the provider's signature, validate the event, prevent duplicate processing and reconcile the resulting transaction against the Klipa ledger.

---

# Payments and Ledger

Klipa follows a ledger-first approach for financial transactions.

```text
Payment Request
      │
      ▼
Validation
      │
      ▼
Provider Transaction
      │
      ▼
Webhook / Status Confirmation
      │
      ▼
Ledger Reconciliation
      │
      ▼
Account Balance
      │
      ▼
Transaction History
```

Client-side confirmation alone should not be treated as authoritative for financial settlement.

---

# Web3 Architecture

Klipa separates its normal financial wallet from its Web3 wallet.

```text
Klipa Account
     │
     ├── Fiat Wallet
     │    └── ZAR balance
     │
     └── Web3 Wallet
          ├── Blockchain Address
          ├── ETH
          └── Supported Tokens
```

This separation allows traditional payment functionality and blockchain functionality to evolve independently.

---

# Scan to Pay

Klipa supports QR-based payment flows.

Example payment payload:

```text
PAY|...
```

The scanning flow is designed to:

1. Scan the QR code.
2. Validate the payload.
3. Resolve the payment destination.
4. Display transaction details.
5. Require user confirmation.
6. Submit the transaction.
7. Verify the resulting transaction.
8. Display the final status.

Payment data should always be validated before a transaction is submitted.

---

# Card Infrastructure

Klipa's card architecture is designed around wallet-funded cards.

Potential card capabilities include:

- Physical cards
- Virtual cards
- Merchant payments
- Online payments
- ATM transactions
- Card funding
- Card-to-wallet settlement

```text
Klipa Wallet
      │
      ▼
Card Processing Infrastructure
      │
 ┌────┼────┐
 ▼    ▼    ▼
POS  Online ATM
```

Card-provider integration should be isolated behind provider services so that the core Klipa application is not tightly coupled to a single provider.

---

# Funding Infrastructure

Supported/planned funding methods include:

- EFT
- Instant payments
- Cards
- Cash
- Payment-provider integrations

Funding follows a controlled lifecycle:

```text
Created
   ↓
Pending
   ↓
Provider Confirmation
   ↓
Verified
   ↓
Ledger Posted
   ↓
Completed
```

Failed or cancelled transactions must not be credited to the user's available balance.

---

# State Management

Klipa uses Riverpod for dependency injection and application state management.

A typical feature follows:

```text
Model
  ↓
Service
  ↓
Repository
  ↓
Provider / Notifier
  ↓
Screen / Widget
```

Providers should expose appropriate states such as:

```text
AsyncLoading
AsyncData
AsyncError
```

Screens should handle loading, success, empty and error states explicitly.

---

# Development Standards

The project aims to maintain:

- Small focused files
- Feature-first organization
- Strong typing
- Immutable models
- Repository/service separation
- Reusable widgets
- Centralized error handling
- Centralized navigation
- Secure dependency injection
- Testable business logic
- Minimal business logic in widgets

Where practical, individual source files should remain reasonably focused rather than becoming large monolithic files.

---

# Testing

Run static analysis:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

Build the Android application:

```bash
flutter build apk
```

For a production release:

```bash
flutter build apk --release
```

Before releasing, verify:

- Authentication
- Wallet creation
- Wallet balance
- Transfers
- Transaction history
- QR payments
- Funding
- Payment webhooks
- RLS policies
- Error handling
- Secure storage
- Web3 wallet functionality
- Production API configuration

---

# Git Workflow

Recommended workflow:

```text
main
 │
 ├── feature/*
 ├── fix/*
 ├── security/*
 └── release/*
```

Example:

```bash
git checkout -b feature/wallet-improvements
```

Commit changes:

```bash
git add .
git commit -m "feat: improve wallet balance handling"
```

Push:

```bash
git push origin feature/wallet-improvements
```

Create a Pull Request for review before merging production changes.

---

# Branch Protection

The production branch should ideally require:

- Pull requests
- Successful CI checks
- Code review
- No committed secrets
- Passing tests
- Successful static analysis

GitHub recommends using repository security features alongside a README to protect repositories and communicate project expectations.

---

# Project Roadmap

## Phase 1 — Core Wallet

- [x] Flutter application foundation
- [x] Supabase integration
- [x] Authentication
- [x] User profiles
- [x] Internal wallet
- [x] Wallet balance
- [x] Transaction foundation
- [x] P2P transfer architecture

## Phase 2 — Payments

- [x] Contact/beneficiary architecture
- [x] QR payment architecture
- [ ] Merchant payments
- [ ] Production funding
- [ ] Payment-provider integration
- [ ] Transaction reconciliation

## Phase 3 — Cards

- [ ] Card provider integration
- [ ] Virtual cards
- [ ] Physical cards
- [ ] POS payments
- [ ] Online payments
- [ ] ATM support

## Phase 4 — Web3

- [x] Web3 wallet architecture
- [ ] Production blockchain infrastructure
- [ ] Multi-asset portfolio
- [ ] Asset pricing
- [ ] Additional network support
- [ ] Advanced wallet security

## Phase 5 — Financial Ecosystem

- [ ] Smart stokvels
- [ ] Cross-border P2P
- [ ] Expanded merchant ecosystem
- [ ] Financial education
- [ ] Additional financial products

---

# Security Reporting

Security vulnerabilities should **not** be disclosed publicly through ordinary GitHub issues.

Create a private security report through the project's designated security reporting process.

When reporting a vulnerability, provide:

- Affected component
- Severity
- Reproduction steps
- Potential impact
- Suggested mitigation, if known

Do not include real user financial information, credentials, private keys or other sensitive data.

---

# Contributing

Contributions should follow the project's development standards.

Before submitting changes:

```bash
flutter analyze
flutter test
```

For significant changes, include:

- Description of the change
- Reason for the change
- Testing performed
- Security considerations
- Database migration, if applicable
- API/provider impact, if applicable

---

# Documentation

Additional technical documentation should be maintained separately from this README where appropriate.

Recommended documentation structure:

```text
docs/
├── architecture/
│   ├── system-architecture.md
│   ├── database-architecture.md
│   └── security-architecture.md
│
├── payments/
│   ├── funding.md
│   ├── cards.md
│   └── merchant-payments.md
│
├── web3/
│   └── wallet-architecture.md
│
├── deployment/
│   └── production-deployment.md
│
└── security/
    └── security-strategy.md
```

Keep the README focused on getting developers oriented; detailed documentation can live under `docs/`. This follows GitHub's guidance that a README should provide essential repository information while longer documentation is better suited to dedicated documentation areas.

---

# Disclaimer

Klipa is a fintech application under active development.

Features, integrations and financial services described in this repository may be incomplete, unavailable or subject to regulatory, compliance and provider requirements.

The application should not be used with real funds in development or testing environments unless the relevant infrastructure has been explicitly configured and approved for production use.

---

# License

Copyright © 2026 Klipa.

All rights reserved unless otherwise specified.

The source code and associated assets are proprietary to the Klipa project. No permission is granted to copy, modify, distribute or commercially exploit the software without authorization.

---

# Maintainer

**Klipa**

South Africa

**Status:** Active development

---

<p align="center">
  <strong>Klipa — Simple. Secure. Connected.</strong>
</p>