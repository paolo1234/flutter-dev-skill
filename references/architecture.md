# Architecture Reference — Feature-First + Clean Architecture

## Project Structure

```
lib/
├── main.dart                          # Entry point, bootstrap
├── main_dev.dart                      # Entry point per flavor dev
├── main_staging.dart                  # Entry point per flavor staging  
├── main_prod.dart                     # Entry point per flavor prod
├── app.dart                           # MaterialApp.router widget
├── bootstrap.dart                     # Inizializzazione: providers, error handlers
├── core/                              # Infrastruttura condivisa (NON feature-specific)
│   ├── constants/                     # App-wide constants
│   │   ├── app_constants.dart
│   │   └── api_endpoints.dart
│   ├── env/                           # Environment configuration
│   │   └── env_config.dart
│   ├── errors/                        # Error handling centralizzato
│   │   ├── app_exception.dart         # Sealed class hierarchy
│   │   ├── error_handler.dart         # Global error handler
│   │   └── failure.dart               # Failure type per Result pattern
│   ├── extensions/                    # Extension methods Dart/Flutter
│   │   ├── context_extensions.dart
│   │   ├── string_extensions.dart
│   │   └── date_extensions.dart
│   ├── network/                       # Networking layer
│   │   ├── dio_client.dart            # Dio singleton con interceptors
│   │   ├── api_interceptor.dart       # Auth token interceptor
│   │   ├── error_interceptor.dart     # Error mapping interceptor
│   │   ├── logging_interceptor.dart   # Request/response logger
│   │   └── connectivity_service.dart  # Online/offline detection
│   ├── router/                        # Navigation
│   │   ├── app_router.dart            # GoRouter configuration
│   │   ├── route_names.dart           # Named routes constants
│   │   └── auth_guard.dart            # Auth redirect logic
│   ├── theme/                         # Theming
│   │   ├── app_theme.dart             # ThemeData light + dark
│   │   ├── app_colors.dart            # Color constants
│   │   ├── app_typography.dart        # Text styles
│   │   └── app_spacing.dart           # Spacing constants (8pt grid)
│   └── utils/                         # Utility functions
│       ├── validators.dart            # Form validators
│       ├── formatters.dart            # Number, date, currency formatters
│       └── debouncer.dart             # Debounce utility
├── features/                          # Feature modules (auto-contenute)
│   ├── auth/
│   ├── onboarding/
│   ├── home/
│   ├── settings/
│   └── [feature_name]/
└── shared/                            # Widget e utilities condivisi tra feature
    ├── widgets/                        # Widget riutilizzabili
    │   ├── app_button.dart
    │   ├── app_text_field.dart
    │   ├── app_card.dart
    │   ├── skeleton_loader.dart
    │   ├── empty_state_widget.dart
    │   ├── error_state_widget.dart
    │   └── async_value_widget.dart     # Helper per AsyncValue (Riverpod)
    ├── models/                        # Modelli condivisi tra feature
    │   └── pagination.dart
    └── utils/
        └── haptic_utils.dart
```

## Feature Structure

Every feature follows the **presentation/domain/data** pattern:

```
lib/features/[feature_name]/
├── presentation/                      # UI Layer — depends on domain
│   ├── pages/                         # Full-screen pages/screens
│   │   ├── [feature]_page.dart
│   │   └── [feature]_detail_page.dart
│   ├── widgets/                       # Feature-specific widgets
│   │   ├── [feature]_card.dart
│   │   ├── [feature]_list_tile.dart
│   │   └── [feature]_form.dart
│   ├── providers/                     # Riverpod providers (if using Riverpod)
│   │   ├── [feature]_provider.dart
│   │   └── [feature]_state.dart       # State classes (if not using freezed)
│   └── blocs/                         # BLoC/Cubit (if using BLoC)
│       ├── [feature]_bloc.dart
│       ├── [feature]_event.dart
│       └── [feature]_state.dart
├── domain/                            # Business Logic Layer — NO external dependencies
│   ├── models/                        # Domain models (freezed)
│   │   └── [feature]_model.dart
│   └── repositories/                  # Abstract repository interfaces
│       └── [feature]_repository.dart
└── data/                              # Data Layer — depends on domain
    ├── datasources/                   # Concrete data access
    │   ├── [feature]_remote_datasource.dart   # API calls
    │   └── [feature]_local_datasource.dart    # Local DB/cache
    └── repositories/                  # Concrete repository implementations
        └── [feature]_repository_impl.dart
```

## Dependency Rules (INVIOLABLE)

```
presentation → domain ✅
data → domain ✅
domain → nothing ✅ (domain is pure)
presentation → data ❌ (NEVER import data layer in UI)
feature A → feature B ❌ (NEVER cross-import between features)
any → core ✅ (core is shared infrastructure)
any → shared ✅ (shared widgets/utils are available to all)
```

### How Features Communicate
- Through `core/` services (event bus, shared providers/blocs)
- Through navigation (GoRouter params/extra)
- Through shared state in `core/` (e.g., auth state)
- **NEVER** by importing each other's files directly

## File Size Limits

| Element | Max Lines | Action if exceeded |
|---|---|---|
| Any `.dart` file | 200 | Extract into multiple files |
| Widget `build()` method | 50 | Extract sub-widgets |
| Any method | 30 | Extract helper methods |
| Any class | 150 | Split by responsibility |

## Error Handling Architecture

### AppException Sealed Class
```dart
sealed class AppException implements Exception {
  const AppException({required this.message, this.code});
  final String message;
  final String? code;
}

class NetworkException extends AppException {
  const NetworkException({required super.message, super.code});
}

class ServerException extends AppException {
  const ServerException({required super.message, super.code, this.statusCode});
  final int? statusCode;
}

class AuthException extends AppException {
  const AuthException({required super.message, super.code});
}

class ValidationException extends AppException {
  const ValidationException({required super.message, super.code, this.errors});
  final Map<String, List<String>>? errors;
}

class CacheException extends AppException {
  const CacheException({required super.message, super.code});
}

class UnknownException extends AppException {
  const UnknownException({super.message = 'Si è verificato un errore inaspettato', super.code});
}
```

### Result Pattern
```dart
typedef Result<T> = ({T? data, AppException? error});

extension ResultX<T> on Result<T> {
  bool get isSuccess => data != null && error == null;
  bool get isFailure => error != null;
  
  R when<R>({
    required R Function(T data) success,
    required R Function(AppException error) failure,
  }) {
    if (isSuccess) return success(data as T);
    return failure(error!);
  }
}
```

## Bootstrap Pattern

```dart
// bootstrap.dart
Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Global error handling
  FlutterError.onError = (details) {
    // Log to crashlytics / error tracking
    debugPrint('Flutter error: ${details.exceptionAsString()}');
  };
  
  PlatformDispatcher.instance.onError = (error, stack) {
    // Log platform errors
    debugPrint('Platform error: $error');
    return true;
  };
  
  // Initialize services
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  
  runApp(await builder());
}

// main.dart (production)
void main() => bootstrap(() => const App());

// main_dev.dart
void main() => bootstrap(() => const App(flavor: Flavor.dev));
```

## Naming Conventions Summary

| Element | Convention | Example |
|---|---|---|
| Files | `snake_case` | `user_profile_page.dart` |
| Classes | `PascalCase` | `UserProfilePage` |
| Variables / Functions | `camelCase` | `currentUser`, `fetchData()` |
| Constants | `camelCase` | `defaultPadding`, `maxRetries` |
| Private | `_camelCase` | `_internalState` |
| Enums | `PascalCase` | `LoadingStatus.idle` |
| Providers (Riverpod) | `camelCase` + `Provider` suffix | `userProfileProvider` |
| BLoCs | `PascalCase` + `Bloc/Cubit` suffix | `UserProfileBloc` |
| Extensions | `PascalCase` + `X` or descriptive | `StringX`, `BuildContextExtensions` |
| Test files | `_test.dart` suffix | `user_profile_page_test.dart` |
| Generated files | `.g.dart`, `.freezed.dart` | auto-generated, never edit |
