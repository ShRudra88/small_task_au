# DummyJSON Products Store - Flutter App

A clean, modern Flutter application built against the public [DummyJSON API](https://dummyjson.com). It features user authentication with secure token storage, a paginated product catalog with pull-to-refresh, loading/empty/error state handling, and a rich product detail page.

---

## 🌟 Features

- 🔐 **Authentication**:
  - Sign in via `POST https://dummyjson.com/auth/login`.
  - Test credentials pre-filled for convenience (`emilys` / `emilyspass`).
  - Secure token storage using `flutter_secure_storage`.
  - Persistent authentication check on app launch.
  - Sign-out functionality with token cleanup.

- 🛍️ **Product Catalog (List)**:
  - Infinite scroll pagination (`skip` and `limit` query parameters).
  - Shimmer/Skeleton loading state.
  - Pull-to-refresh support (`RefreshIndicator`).
  - Error state with retry action.
  - Empty state fallback UI.
  - Interactive product card with thumbnail, pricing, discount badges, ratings, and stock indicator.

- 📦 **Product Details**:
  - Image gallery selector for multiple product images.
  - Discounted price & original price calculation.
  - Category and brand chips.
  - Star ratings and stock level indicator.
  - Detailed product description.

---

## 🏗️ Architecture & Architectural Decisions

This project strictly adheres to **Clean Architecture** principles and the **BLoC (Business Logic Component)** pattern for predictable state management and high testability.

### Layer Separation

```
lib/
├── core/                        # Core utilities, network client, storage & theme
│   ├── errors/                  # Custom Failure and Exception classes
│   ├── network/                 # ApiClient HTTP wrapper with header & auth token handling
│   ├── storage/                 # SecureStorageService abstraction (flutter_secure_storage)
│   ├── theme/                   # Material 3 custom AppTheme
│   └── utils/                   # Type-safe Result<T> functional error handling
│
└── features/
    ├── auth/                    # Auth Feature
    │   ├── data/                # DataSources, Models (UserModel, AuthResponseModel), RepositoryImpl
    │   ├── domain/              # Entities (User), Repositories (abstract), UseCases (Login, Logout, CheckAuth)
    │   └── presentation/        # AuthBloc, AuthEvent, AuthState, LoginScreen
    │
    └── products/                # Products Feature
        ├── data/                # ProductsRemoteDataSource, ProductModel, ProductsPaginatedResponseModel
        ├── domain/              # Entities (Product, ProductsPage), Repositories, UseCases
        └── presentation/        # ProductListBloc, ProductDetailBloc, Screens & Reusable Widgets
```

### Key Technical Decisions:

1. **Clean Architecture & Separation of Concerns**:
   - **Domain Layer**: Independent of Flutter and any third-party framework. Contains pure Dart business entities (`User`, `Product`) and Use Cases (`LoginUseCase`, `GetProductsUseCase`).
   - **Data Layer**: Responsible for retrieving remote API JSON payloads and mapping them into domain models.
   - **Presentation Layer**: Built with `flutter_bloc`. BLoC receives UI events, executes domain use cases, and emits immutable states (`ProductListLoaded`, `ProductListError`, `AuthFailureState`, etc.).

2. **Functional Error Handling (`Result<T>`)**:
   - Rather than relying on untyped `try-catch` in UI code or throwing unchecked exceptions, all repositories and use cases return a type-safe `Result<T>` (`Success<T>` or `FailureResult<T>`).
   - This eliminates null-pointer exceptions and makes error handling explicit across all layers.

3. **Secure Storage**:
   - `flutter_secure_storage` is used to store sensitive auth tokens (encrypted storage via Keychain on iOS / KeyStore on Android).

4. **Infinite Scroll Pagination & State Management**:
   - `ProductListBloc` manages paginated loading seamlessly using `skip` parameters.
   - Handles edge cases like network errors during pagination with inline retry affordances without losing already loaded products.

---

## 🧪 Unit & Widget Testing

Unit tests cover BLoC state transitions, Result wrappers, and repository interactions.

To run tests:
```bash
flutter test
```

To run static analysis:
```bash
flutter analyze
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `>=3.10.0`
- Dart SDK `>=3.0.0`

### Setup Instructions

1. **Clone the repository**:
   ```bash
   git clone <repository_url>
   cd small_task_au
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the application**:
   ```bash
   flutter run
   ```

4. **Test Credentials**:
   - **Username**: `emilys`
   - **Password**: `emilyspass`
