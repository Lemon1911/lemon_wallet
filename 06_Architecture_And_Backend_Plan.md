# Lemon Money: Architecture & Backend Recommendation

This document analyzes the requirements for the **Lemon Money** application and provides a comprehensive recommendation for the architecture, backend, database schema, and development roadmap.

## Backend Options Comparison

| Feature | ASP.NET Core + MonsterASP.NET | Firebase | Supabase |
| :--- | :--- | :--- | :--- |
| **Database Type** | Relational (SQL Server) | NoSQL (Firestore) | Relational (PostgreSQL) |
| **Family/Shared Wallets** | Excellent (Relational tables) | Poor (Requires data duplication) | **Excellent** (Relational tables) |
| **Analytics & Reporting** | Excellent (Complex SQL aggregations) | Poor (Expensive, hard to aggregate) | **Excellent** (Complex SQL aggregations) |
| **Cost Optimization** | Low (MonsterASP free tier is limited) | Medium (Free tier, but reads are costly) | **High** (Generous free tier, predictable) |
| **Scalability** | High | High | High |
| **OCR & SMS Processing**| Server-side (Costs compute/RAM) | Client-side (ML Kit) | Client-side / Edge Functions |
| **Vendor Lock-in** | None (Can host anywhere) | High | None (Open-source, self-hostable) |

### 🏆 Recommended Choice: Hybrid Approach (Supabase + On-Device Processing)

For a finance app requiring **shared family wallets** and **heavy analytics**, a relational database is absolutely mandatory. NoSQL databases like Firebase will become a nightmare to maintain and query as data grows.

**Why this hybrid approach?**
1. **Supabase (PostgreSQL)**: Handles Authentication, Database, and Storage. PostgreSQL is perfect for joining Users to Shared Wallets and running heavy financial aggregations efficiently.
2. **On-Device OCR & SMS**: Doing OCR (via Google ML Kit) and SMS parsing on the user's device means **zero server compute costs**. It's fast, free, and highly privacy-compliant.
3. **Offline Support**: By using a local database (`isar` or `sqflite`) synced with Supabase, users get offline capabilities with fast local reads.

---

## Setup Notes
> [!TIP]
> Since this is your first time using **Supabase**, don't worry! I will guide you step-by-step through setting up the project, configuring the database, and connecting it to Flutter when we reach that stage.

> [!NOTE]
> We will proceed with an **online-first approach with basic caching** for Phase 1 to speed up development, as requested.

---

## Recommended Architecture

### Flutter Architecture (Clean Architecture - Feature-First)
We will use a Feature-First Clean Architecture to ensure scalability and maintainability.

- **Presentation Layer**: Screens, Widgets, and State Management (`flutter_bloc`).
- **Domain Layer**: `entities`, `repo` (abstract repositories), and `usecase`.
- **Data Layer**: `datasource` (API/Supabase client, local caching), `models` (DTOs), and `repoimpl` (repository implementations).

### Backend Architecture (Supabase)
- **Auth**: Supabase Auth (Email/Password). Users will log in with their email and password for the first time. We will then activate `local_auth` (Fingerprint/Face ID) for all subsequent logins using a securely stored token.
- **Database**: PostgreSQL with Row Level Security (RLS). RLS ensures users can only see their own wallets and shared family wallets.
- **Storage Strategy**: Use the mobile gallery/camera to save receipt photos locally. We will extract the data via OCR on the device and *only* send the extracted transaction data to Supabase. This eliminates cloud storage costs and improves speed.

---

## Database Schema (PostgreSQL)

```sql
-- Users (managed by Supabase Auth)
CREATE TABLE users (
  id UUID REFERENCES auth.users PRIMARY KEY,
  full_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Wallets
CREATE TABLE wallets (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  currency TEXT NOT NULL DEFAULT 'USD',
  owner_id UUID REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Wallet Members (For Family Sharing)
CREATE TABLE wallet_members (
  wallet_id UUID REFERENCES wallets(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  role TEXT CHECK (role IN ('owner', 'admin', 'viewer')),
  PRIMARY KEY (wallet_id, user_id)
);

-- Categories
CREATE TABLE categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  wallet_id UUID REFERENCES wallets(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  icon TEXT,
  type TEXT CHECK (type IN ('income', 'expense')),
  is_default BOOLEAN DEFAULT false
);

-- Transactions
CREATE TABLE transactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  wallet_id UUID REFERENCES wallets(id) ON DELETE CASCADE,
  category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
  user_id UUID REFERENCES users(id), -- Who made the transaction
  amount DECIMAL(12,2) NOT NULL,
  type TEXT CHECK (type IN ('income', 'expense')),
  note TEXT,
  receipt_url TEXT,
  transaction_date TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## Folder Structure (Flutter)

```text
lib/
├── core/                       # App-wide shared code
│   ├── constants/              # Colors, styles, strings
│   ├── network/                # Supabase client wrapper
│   ├── database/               # Local SQLite setup
│   ├── error/                  # Failure handling
│   ├── router/                 # GoRouter configuration
│   └── theme/                  # Light/Dark mode themes
├── features/                   # Feature modules
│   ├── auth/                   # Login, Register, Biometrics
│   ├── wallet/                 # Wallet management & Shared wallets
│   ├── transactions/           # Adding/Editing expenses and income
│   ├── dashboard/              # Home screen & charts/analytics
│   └── scanner/                # OCR & SMS parsing
│       ├── data/
│       ├── domain/
│       └── presentation/
├── l10n/                       # Localization files (AR, EN)
└── main.dart                   # Entry point
```

---

## Recommended Packages/Libraries

**Core & UI:**
- `flutter_bloc`: State management.
- `go_router`: Navigation and deep linking.
- `get_it`: Dependency injection.
- `fl_chart`: Beautiful, customizable charts for analytics.
- `intl`: Localization and currency formatting.
- `flutter_localizations`: AR/EN support.

**Data & Backend:**
- `supabase_flutter`: Backend DB, Auth, Storage.
- `sqflite` / `isar`: Offline database caching.
- `shared_preferences`: Lightweight local storage.

**Device Features:**
- `local_auth`: Fingerprint / Face ID unlock.
- `google_mlkit_text_recognition`: On-device OCR for receipts (Free, private, fast).
- `image_picker`: Camera/Gallery for receipts.
- `telephony` / `flutter_sms_inbox`: Reading SMS for automated tracking.

---

## Development Roadmap

### Phase 1: Core Foundation & MVP (Weeks 1-3)
- **Version Control**: Initialize Git and connect to your GitHub repository.
- Setup Flutter project, Supabase, and Clean Architecture folders.
- Implement Theme (Light/Dark) and Localization (AR/EN).
- **Auth Feature**: Email/Password login, Fingerprint unlock.
- **Wallet & Categories**: Create personal wallets, add default categories.
- **Transactions**: CRUD operations for Income/Expenses.
- **Basic Dashboard**: Current balance and simple monthly list.

### Phase 2: Analytics & Syncing (Weeks 4-5)
- **Local DB Caching**: Implement basic online-first caching.
- **Analytics Feature**: Integrate `fl_chart` for spending by category, monthly trends.

### Phase 3: Family & Collaboration (Weeks 6-7)
- **Shared Wallets**: Invite users via email to join a wallet.
- **Role Management**: Admin vs Viewer permissions.
- **Combined Dashboard**: Filter spending by user.

### Phase 4: Smart Features (OCR & SMS) (Weeks 8-9)
- **OCR Scanner**: Integrate `google_mlkit_text_recognition` to extract amounts from receipt photos.
- **SMS Parser**: Read banking SMS to auto-suggest transactions.

### Phase 5: Polish & Launch (Week 10)
- End-to-end testing.
- UI/UX polish, animations, glassmorphism effects.
- App Store and Google Play release preparation.
